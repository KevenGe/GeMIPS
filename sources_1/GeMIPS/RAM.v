/******************************************************************************
*   
*   文件名称：ex.v
*   文件说明：这个文件是GeMIPS的处理地址映射的模块
* 
*   作者：葛启丰
*   时间：2020-07-07
*
*   虚拟内存空间为0X80000000~0×807FFF，共8MB。其中
*            0X80000000~0X803FFFF   映射到 BaseRAM，      指令空间
*            0×80400000~0×807FFFF   映射到 EXtRAM，       数据空间
*
******************************************************************************/

`define SerialStat 32'hBFD003FC
`define SerialDate 32'hBFD003F8

module RAM (
           input wire clk_50M,           //50MHz 时钟输入

           /// 取指令
           input    wire[31:0]  rom_addr_i,     ///< 读取指令的地址
           input    wire        ce_i,           ///< 使能信号
           output   wire [31:0] rom_data_o,     ///< 获取到的指令

           /// 为了方便，命名存储数据的线，前缀为ram2
           output   reg[31:0]   ram2_data_o,
           (*mark_debug = "true"*)input    wire[31:0]  ram2_addr_i,
           (*mark_debug = "true"*)input    wire[31:0]  ram2_data_i,
           (*mark_debug = "true"*)input    wire        ram2_we_i,              ///< 写使能，低有效
           input    wire[3:0]   ram2_sel_i,
           input    wire        ram2_ce_i,

           //直连串口信号
           output    wire       txd,  //直连串口发送端
           input     wire       rxd,  //直连串口接收端

           //BaseRAM信号
           inout    wire[31:0]  base_ram_data,          //BaseRAM数据，低8位与CPLD串口控制器共享
           output   reg [19:0]  base_ram_addr,          //BaseRAM地址
           output   reg [3:0]   base_ram_be_n,          //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
           output   reg         base_ram_ce_n,          //BaseRAM片选，低有效
           output   reg         base_ram_oe_n,          //BaseRAM读使能，低有效
           output   reg         base_ram_we_n,          //BaseRAM写使能，低有效

           //ExtRAM信号
           inout    wire[31:0]  ext_ram_data,           //ExtRAM数据
           output   reg [19:0]  ext_ram_addr,           //ExtRAM地址
           output   reg [3:0]   ext_ram_be_n,           //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
           output   reg         ext_ram_ce_n,           //ExtRAM片选，低有效
           output   reg         ext_ram_oe_n,           //ExtRAM读使能，低有效
           output   reg         ext_ram_we_n            //ExtRAM写使能，低有效
       );

/*****************************************************************************
 串口通信模块
*****************************************************************************/

(*mark_debug = "true"*)wire [7:0]  ext_uart_rx;             ///< 接收到的数据线路
(*mark_debug = "true"*)reg  [7:0]  ext_uart_buffer,         ///< 保存数据的位置
     ext_uart_tx;                    ///< 发送数据的线路
(*mark_debug = "true"*)wire        ext_uart_ready,          ///< 接收器收到数据完成之后，置为1
            ext_uart_busy;           ///< 发送器状态是否忙碌，1为忙碌，0为不忙碌
(*mark_debug = "true"*)reg         ext_uart_start,          ///< 传递给发送器，为1时，代表可以发送，为0时，代表不发送
            ext_uart_clear,          ///< 置1，在下次时钟有效的时候，会清楚接收器的标志位
            ext_uart_avai;           ///< 代表缓冲区是否可用，是否存有数据

reg  [7:0]  ext_uart_buffer_recive,     ///< 接受数据缓冲区
     ext_uart_buffer_send;              ///< 发送数据缓冲区

reg         ext_uart_buffer_send_ok;    ///< 发送数据缓冲区已经可以发送，1为可以，0为不可以

assign number = ext_uart_buffer;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
               ext_uart_r(
                   .clk(clk_50M),                       //外部时钟信号
                   .RxD(rxd),                           //外部串行信号输入
                   .RxD_data_ready(ext_uart_ready),     //数据接收到标志
                   .RxD_clear(ext_uart_clear),          //清除接收标志
                   .RxD_data(ext_uart_rx)               //接收到的一字节数据
               );

// assign ext_uart_clear = ext_uart_ready;                 //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中

// always @(posedge clk_50M) begin                         //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready) begin
//         ext_uart_buffer_recive <= ext_uart_rx;
//     end
// end

// always @(posedge clk_50M) begin                         //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy && ext_uart_buffer_send_ok) begin
//         ext_uart_tx <= ext_uart_buffer_send;
//         ext_uart_start <= 1;
//     end
//     else begin
//         ext_uart_start <= 0;
//     end
// end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
                  ext_uart_t(
                      .clk(clk_50M),                  //外部时钟信号
                      .TxD(txd),                      //串行信号输出
                      .TxD_busy(ext_uart_busy),       //发送器忙状态指示
                      .TxD_start(ext_uart_start),     //开始发送信号
                      .TxD_data(ext_uart_tx)          //待发送的数据
                  );


/*****************************************************************************
 CPU 连接协同模块
*****************************************************************************/

///< 管理获取指令
assign base_ram_data = 32'hzzzzzzzz;
assign rom_data_o = base_ram_data;

always @(*) begin
    base_ram_addr <= rom_addr_i[21:2];
    base_ram_be_n <= 4'b0000;
    base_ram_ce_n <= 1'b0;
    base_ram_oe_n <= 1'b0;
    base_ram_we_n <= 1'b1;
end

///< 管理指令或者数据的存取
wire [31:0] ram2_data_o_tmp;     ///< 主要用来临时存储串口数据
assign ext_ram_data = (ram2_we_i) ? 32'hzzzzzzzz : ram2_data_i;
assign ram2_data_o_tmp = ext_ram_data;

always @(*) begin
    if(ram2_addr_i == `SerialDate) begin
        /// 获取（或发送）串口数据
        if(ram2_we_i) begin
            /// 读数据，即接收串口数据
            ram2_data_o <= {24'h000000, ext_uart_rx};
            ext_uart_clear <= 1'b1;
            ext_uart_start <= 1'b0;
        end
        else begin
            /// 写数据，即发送串口数据
            ext_uart_tx <= ram2_data_i[7:0];
            ext_uart_start <= 1'b1;
            ext_uart_clear <= 1'b0;
        end
    end
    else if (ram2_addr_i ==  `SerialStat) begin
        /// 获取串口状态
        ram2_data_o <= {{30{1'b0}}, {ext_uart_ready, !ext_uart_busy}};

        ext_uart_clear <= 1'b0;
        ext_uart_start <= 1'b0;
    end
    else begin
        ext_ram_addr <= ram2_addr_i[21:2];
        ext_ram_be_n <= ram2_sel_i;
        ext_ram_ce_n <= 1'b0;
        ext_ram_oe_n <= !ram2_we_i;
        ext_ram_we_n <= ram2_we_i;

        ram2_data_o <= ram2_data_o_tmp;

        ext_uart_clear <= 1'b0;
        ext_uart_start <= 1'b0;
    end
end

endmodule
