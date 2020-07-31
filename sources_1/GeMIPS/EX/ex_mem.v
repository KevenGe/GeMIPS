/******************************************************************************
*   
*   文件名称：ex_mem.v
*   文件说明：这个文件是GeMIPS的的流水线的ex级传递给下一级的的暂存寄存器�?  
* 
*   作�?�：葛启�?
*   时间�?2020-07-07
*
******************************************************************************/

module ex_mem (
           input    wire        rst,        ///< 重置
           input    wire        clk,        ///< 时钟信号

           input    wire        ex_we,
           input    wire[4:0]   ex_waddr,
           input    wire[31:0]  ex_wdata,

           output   reg        mem_we,
           output   reg[4:0]   mem_waddr,
           output   reg[31:0]  mem_wdata,

           // for store
           input    wire[7:0]    ex_mem_op,
           input    wire[31:0]   ex_mem_addr_i,
           input    wire[31:0]   ex_mem_data_i,

           output    reg[7:0]    mem_mem_op,
           output    reg[31:0]   mem_mem_addr_o,
           output    reg[31:0]   mem_mem_data_o
       );

always@(posedge clk) begin
    if (rst) begin
        mem_we <= 1'b0;
        mem_waddr <= 5'b00000;
        mem_wdata <= 32'h00000000;

        mem_mem_op <= `MEM_NOP;
        mem_mem_addr_o <= 32'h00000000;
        mem_mem_data_o <= 32'h00000000;
    end
    else begin
        mem_we <= ex_we;
        mem_waddr <= ex_waddr;
        mem_wdata <= ex_wdata;

        mem_mem_op <= ex_mem_op;
        mem_mem_addr_o <= ex_mem_addr_i;
        mem_mem_data_o <= ex_mem_data_i;
    end
end

endmodule
