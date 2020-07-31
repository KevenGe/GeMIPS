/******************************************************************************
*   
*   文件名称：mem_wb.v
*   文件说明：这个文件是GeMIPS的访存级到下一级的缓冲寄存器
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module mem_wb (
           input    wire        rst,            ///< 重置
           input    wire        clk,            ///< 时钟信号

           input    wire        mem_we_i,
           input    wire[4:0]   mem_waddr_i,
           input    wire[31:0]  mem_wdata_i,

           output    reg        wb_we_o,
           output    reg[4:0]   wb_waddr_o,
           output    reg[31:0]  wb_wdata_o
       );

always@(posedge clk) begin
    if(rst) begin
        wb_we_o <= 1'b0;
        wb_waddr_o <= 5'b00000;
        wb_wdata_o <= 32'h00000000;
    end
    else begin
        wb_we_o    <= mem_we_i;
        wb_waddr_o <= mem_waddr_i;
        wb_wdata_o <= mem_wdata_i;
    end
end

endmodule
