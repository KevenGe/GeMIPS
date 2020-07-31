/******************************************************************************
*   
*   文件名称：wb.v
*   文件说明：这个文件是GeMIPS的写回级主要文件
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module wb (
           input        wire        rst,    ///< 重置
           input        wire        clk,    ///< 时钟信号

           input        wire        wd_i,
           input        wire[4:0]   waddr_i,
           input        wire[31:0]  wdata_i,

           output       reg         wd_o,
           output       reg[4:0]    waddr_o,
           output       reg[31:0]   wdata_o
       );

always@(*) begin
    if(rst) begin
        wd_o <= 1'b0;
        waddr_o <= 5'b00000;
        wdata_o <= 32'h00000000;
    end
    else begin
        wd_o    <= wd_i;
        waddr_o <= waddr_i;
        wdata_o <= wdata_i;
    end
end

endmodule
