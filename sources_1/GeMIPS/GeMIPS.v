/******************************************************************************
*   
*   文件名称：GeMIPS.v
*   文件说明：这个文件是GeMIPS的顶层模块，负责输入输出  
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module GeMIPS (
           input     wire               rst,          ///< 重置
           input     wire               clk,          ///< 时钟信号

           /// 指令取
           output    wire[31:0]         rom_addr_o,   ///< 读取指令的地址
           output    wire               ce_o,         ///< 使能信号
           input     wire[31:0]         rom_data_i,    ///< 获取到的指令

           /// 为了方便，命名存储数据的线，前缀为ram2
           input    wire[31:0]          ram2_data_i,
           output   wire[31:0]          ram2_addr_o,
           output   wire[31:0]          ram2_data_o,
           output   wire                ram2_we_o,
           output   wire[3:0]           ram2_sel_o,
           output   wire                ram2_ce_o
       );

/******************************************************************************
*   流水线暂停， STOPS
******************************************************************************/

wire id_stop,           
     mem_stop_end,
     if_stop;


STOPS STOPS_1 (
          .clk              (clk         ),
          .rst              (rst         ),
          .id_stop          (id_stop     ),
          .mem_stop_end     (mem_stop_end),
          .if_stop          (if_stop     )
      );


/******************************************************************************
*   IF 级
******************************************************************************/
wire[31:0] pc_addr;         ///< 程序计数器地址
assign rom_addr_o = pc_addr;

wire         pc_branch_flag_i;
wire[31:0]   pc_branch_address_i ;

pc_reg pc_reg_1(
           .rst     (rst),
           .clk     (clk),

           .pc      (pc_addr),
           .ce      (ce_o),

           // 跳转
           .branch_flag_i               (pc_branch_flag_i),
           .branch_address_i            (pc_branch_address_i),

           .stops_stop              (if_stop)
       );

wire[31:0] id_pc;
wire[31:0] id_inst;

if_id if_id_1 (
          .rst      (rst),
          .clk      (clk),

          .if_pc    (pc_addr),
          .if_inst  (rom_data_i),

          .id_pc    (id_pc),
          .id_inst  (id_inst),

          .stops_stop              (if_stop)
      );

/******************************************************************************
*   ID 级
******************************************************************************/

wire[4:0]   reg_waddr_i;
wire[31:0]  reg_wdata_i;
wire        reg_we_i;

wire[4:0]   reg_raddr_1_i;
wire        reg_re_1_i;
wire[31:0]  reg_wdata_1_o;

wire[4:0]   reg_raddr_2_i;
wire        reg_re_2_i;
wire[31:0]  reg_wdata_2_o;

regfile regfile_1(
            .rst        (rst),
            .clk        (clk),

            .waddr      (reg_waddr_i),
            .wdata      (reg_wdata_i),
            .we         (reg_we_i),

            .raddr_1    (reg_raddr_1_i),
            .re_1       (reg_re_1_i),
            .rdata_1    (reg_wdata_1_o),

            .raddr_2    (reg_raddr_2_i),
            .re_2       (reg_re_2_i),
            .rdata_2    (reg_wdata_2_o)
        );

wire[7:0]   id_aluop_o;
wire[3:0]   id_alusel_o;

wire[31:0]  id_reg_1_o;
wire[31:0]  id_reg_2_o;

wire[4:0]   id_waddr_o;
wire        id_we_o;

/// ex级别
wire [31:0]  ex_wdata_o;
wire [4:0]   ex_waddr_o;
wire         ex_we_o;
wire[31:0]   id_link_addr_o;

/// mem级别
wire         mem_we_o;
wire[4:0]    mem_waddr_o;
wire[31:0]   mem_wdata_o;

/// 分支
wire[31:0]   id_inst_o;

id id_1 (
       .rst                 (rst),
       .clk                 (clk),

       .pc                  (id_pc),
       .inst                (id_inst),

       .raddr_1             (reg_raddr_1_i),
       .re_1                (reg_re_1_i),
       .rdata_1             (reg_wdata_1_o),

       .raddr_2             (reg_raddr_2_i),
       .re_2                (reg_re_2_i),
       .rdata_2             (reg_wdata_2_o),

       .aluop               (id_aluop_o),
       .alusel              (id_alusel_o),

       .reg_1               (id_reg_1_o),
       .reg_2               (id_reg_2_o),

       .waddr               (id_waddr_o),
       .we                  (id_we_o),

       .ex_we_i             (ex_we_o),
       .ex_waddr_i          (ex_waddr_o),
       .ex_wdata_i          (ex_wdata_o),

       .mem_we_i            (mem_we_o),
       .mem_waddr_i         (mem_waddr_o),
       .mem_wdata_i         (mem_wdata_o),

       /// 分支
       .branch_flag_o       (pc_branch_flag_i),
       .target_address_o    (pc_branch_address_i),
       .link_addr_o         (id_link_addr_o),

       /// 存储
       .inst_o              (id_inst_o),

       .is_stop             (id_stop)
   );

wire[3:0]   id_ex_alusel_o;
wire[7:0]   id_ex_aluop_o;

wire[31:0]  id_ex_reg_1_o;
wire[31:0]  id_ex_reg_2_o;

wire[4:0]   id_ex_waddr_o;
wire        id_ex_we_o;

wire[31:0]  id_ex_link_addr_o;

wire[31:0]  id_ex_inst_o;

id_ex id_ex_1 (
          .rst          (rst),
          .clk          (clk),

          .id_alusel    (id_alusel_o),
          .id_aluop     (id_aluop_o),

          .id_reg_1     (id_reg_1_o),
          .id_reg_2     (id_reg_2_o),

          .id_waddr     (id_waddr_o),
          .id_we        (id_we_o),

          .ex_alusel    (id_ex_alusel_o),
          .ex_aluop     (id_ex_aluop_o),

          .ex_reg_1     (id_ex_reg_1_o),
          .ex_reg_2     (id_ex_reg_2_o),

          .ex_waddr     (id_ex_waddr_o),
          .ex_we        (id_ex_we_o),

          .id_link_addr_i   (id_link_addr_o),
          .ex_link_addr_o   (id_ex_link_addr_o),

          .id_inst          (id_inst_o),
          .ex_inst          (id_ex_inst_o)
      );

/******************************************************************************
*   EX 级
******************************************************************************/

// 储存
wire[7:0]    mem_op;
wire[31:0]   mem_addr_o;
wire[31:0]   mem_data_o;

ex ex_1(
       .rst         (rst),
       .clk         (clk),

       .alusel      (id_ex_alusel_o),
       .aluop       (id_ex_aluop_o),

       .reg_1       (id_ex_reg_1_o),
       .reg_2       (id_ex_reg_2_o),

       .waddr       (id_ex_waddr_o),
       .we          (id_ex_we_o),

       .wdata_o     (ex_wdata_o),
       .waddr_o     (ex_waddr_o),
       .we_o        (ex_we_o),

       .link_addr_i (id_ex_link_addr_o),

       .inst_i      (id_ex_inst_o),
       .mem_op      (mem_op),
       .mem_addr_o  (mem_addr_o),
       .mem_data_o  (mem_data_o)
   );


wire        ex_mem_we_o;
wire[4: 0]  ex_mem_waddr_o;
wire[31:0]  ex_mem_wdata_o;

wire[7:0]  mem_mem_op;
wire[31:0]  mem_mem_addr_o;
wire[31:0]  mem_mem_data_o;

ex_mem ex_mem_1(
           .rst         (rst),
           .clk         (clk),

           .ex_we       (ex_we_o),
           .ex_waddr    (ex_waddr_o),
           .ex_wdata    (ex_wdata_o),

           .mem_we      (ex_mem_we_o),
           .mem_waddr   (ex_mem_waddr_o),
           .mem_wdata   (ex_mem_wdata_o),

           .ex_mem_op       (mem_op),
           .ex_mem_addr_i   (mem_addr_o),
           .ex_mem_data_i   (mem_data_o),

           .mem_mem_op      (mem_mem_op),
           .mem_mem_addr_o  (mem_mem_addr_o),
           .mem_mem_data_o  (mem_mem_data_o)
       );

/******************************************************************************
*   MEM 级
******************************************************************************/



mem mem_1(
        .rst        (rst),
        .clk        (clk),

        .we_i       (ex_mem_we_o),
        .waddr_i    (ex_mem_waddr_o),
        .wdata_i    (ex_mem_wdata_o),

        .we_o       (mem_we_o),
        .waddr_o    (mem_waddr_o),
        .wdata_o    (mem_wdata_o),

        /// 存储相关
        .mem_op         (mem_mem_op),
        .mem_addr_i     (mem_mem_addr_o),
        .mem_data_i     (mem_mem_data_o),

        .ram_data_i     (ram2_data_i), ///< 来自存储器
        .mem_addr_o     (ram2_addr_o),
        .mem_data_o     (ram2_data_o),
        .mem_we_o       (ram2_we_o), ///< 是否为写操作
        .mem_sel_o      (ram2_sel_o),
        .mem_ce_o       (ram2_ce_o),    ///< 使能信号

        .stop_end       (mem_stop_end)
    );

wire        mem_wb_we_o;
wire[4:0]   mem_wb_waddr_o;
wire[31:0]  mem_wb_wdata_o;

mem_wb mem_wb_1 (
           .rst             (rst),
           .clk             (clk),

           .mem_we_i        (mem_we_o),
           .mem_waddr_i     (mem_waddr_o),
           .mem_wdata_i     (mem_wdata_o),

           .wb_we_o         (mem_wb_we_o),
           .wb_waddr_o      (mem_wb_waddr_o),
           .wb_wdata_o      (mem_wb_wdata_o)
       );

/******************************************************************************
*   WB 级
******************************************************************************/

wb wb_1(
       .rst         (rst),
       .clk         (clk),

       .wd_i        (mem_wb_we_o),
       .waddr_i     (mem_wb_waddr_o),
       .wdata_i     (mem_wb_wdata_o),

       .wd_o        (reg_we_i),
       .waddr_o     (reg_waddr_i),
       .wdata_o     (reg_wdata_i)
   );

endmodule
