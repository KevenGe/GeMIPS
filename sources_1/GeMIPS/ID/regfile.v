/******************************************************************************
*   
*   文件名称：regfile.v
*   文件说明：这个文件是GeMIPS的通用寄存器组，内部通过组合逻辑电路实现，因此行为描述均采用(*)。
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module regfile (
           input    wire        rst,    ///< 重置
           input    wire        clk,    ///< 时钟信号

           input    wire[4:0]   waddr,  ///< 写地址
           input    wire[31:0]  wdata,  ///< 写数据
           input    wire        we,     ///< 写使能

           input    wire[4:0]   raddr_1,///< 读地址
           input    wire        re_1,   ///< 读使能
           output   reg [31:0]  rdata_1,///< 读数据

           input    wire[4:0]   raddr_2,///< 读地址
           input    wire        re_2,   ///< 读使能
           output   reg [31:0]  rdata_2 ///< 读数据
       );


reg[31:0] regs[31:0]; ///< 32个32位通用寄存器

/**
 *  写入操作行为
 */
always@(*) begin
    if(rst) begin
        for (integer i = 0;i < 32;i = i+1 ) begin
            regs[i] <= 32'h00000000;
        end
    end
    else begin
        if(we == 1'b1) begin
            if(waddr != 5'b00000) begin
                regs[waddr] <= wdata;
            end
        end
    end
end

/**
 *  读出操作1行为
 */
always @(*) begin
    if(rst) begin
        rdata_1 <= 32'h00000000;
    end
    else begin
        if(re_1) begin
            if(raddr_1 == 5'b00000) begin
                rdata_1 <= 32'h00000000;
            end
            else if (raddr_1 == waddr) begin
                rdata_1 <= wdata;
            end
            else begin
                rdata_1 <= regs[raddr_1];
            end
        end
        else begin
            rdata_1 <= 32'h00000000;
        end
    end
end

/**
 *  读出操作2行为
 */
always @(*) begin
    if(rst) begin
        rdata_2 <= 32'h00000000;
    end
    else begin
        if(re_2) begin
            if(raddr_2 == 5'b00000) begin
                rdata_2 <= 32'h00000000;
            end
            else if (raddr_2 == waddr) begin
                rdata_2 <= wdata;
            end
            else begin
                rdata_2 <= regs[raddr_2];
            end
        end
        else begin
            rdata_2 <= 32'h00000000;
        end
    end
end

endmodule
