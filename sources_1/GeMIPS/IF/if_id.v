/******************************************************************************
*   
*   文件名称：if_id.v
*   文件说明：这个文件是GeMIPS的的流水线的IF级传递给下一级的的暂存寄存器。  
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module if_id (
           input    wire        rst,            ///< 重置信号
           input    wire        clk,            ///< 时钟信号

           input    wire[31:0]  if_pc,          ///< 地址
           input    wire[31:0]  if_inst,        ///< 指令

           output   reg [31:0]  id_pc,          ///< 地址
           output   reg [31:0]  id_inst,        ///< 指令

           input    wire        stops_stop      ///< 暂停信号
       );

/**
 * 根据时钟的上升沿进行传递数据至下一级
 */
always @(posedge clk) begin
    if(rst) begin
        id_pc <= 32'h00000000;
        id_inst <= 32'h00000000;
    end
    else if (stops_stop) begin
        id_pc = 32'h00000000;
        id_inst = 32'h00000000;
    end
    else begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end

endmodule
