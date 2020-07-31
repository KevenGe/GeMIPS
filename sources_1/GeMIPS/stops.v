/******************************************************************************
*   
*   文件名称：ex.v
*   文件说明：这个文件是GeMIPS的暂停流水线的模块
* 
*   作者：葛启丰
*   时间：2020-07-28
*   
*   这里，主要是接受LW与LB指令的ID级的暂停信号，然后使得在IF以前的信号全部暂停，直到成功加载信号
*
******************************************************************************/

module STOPS (
           input    wire    clk,            ///< 时钟信号
           input    wire    rst,

           input    wire    id_stop,        ///< 来自ID级别的暂停信号   1代表暂停，0代表不暂停
           input    wire    mem_stop_end,       ///< 来自MEM级别的暂停信号  0代表继续暂停，1代表停止暂停（继续流水线）

           output   reg     if_stop         ///< 传递给IF级别的暂停信号 1代表暂停，0代表不暂停

       );

always @(posedge id_stop or posedge mem_stop_end) begin
    if(mem_stop_end) begin
        if_stop <= 1'b0;
    end
    else begin
        if(id_stop) begin
            if_stop <= 1'b1;
        end
        else begin
            if_stop <= 1'b0;
        end
    end
end

endmodule
