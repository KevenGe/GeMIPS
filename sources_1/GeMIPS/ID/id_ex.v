/******************************************************************************
*   
*   文件名称：if_id.v
*   文件说明：这个文件是GeMIPS的的流水线的ID级传递给下一级的的暂存寄存器。  
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

//  `include "../include/include.v";

module id_ex (
           input    wire        rst,        ///< 重置
           input    wire        clk,        ///< 时钟信号

           input    wire[3:0]   id_alusel,
           input    wire[7:0]   id_aluop,

           input    wire[31:0]  id_reg_1,
           input    wire[31:0]  id_reg_2,

           input    wire[4:0]   id_waddr,
           input    wire        id_we,

           output   reg [3:0]   ex_alusel,
           output   reg [7:0]   ex_aluop,

           output   reg [31:0]  ex_reg_1,
           output   reg [31:0]  ex_reg_2,

           output   reg [4:0]   ex_waddr,
           output   reg         ex_we,

           // 分支跳转存储
           input    wire[31:0]      id_link_addr_i,
           output   reg[31:0]       ex_link_addr_o,

           // 存储相关
           input    wire[31:0]      id_inst,
           output   reg[31:0]       ex_inst
       );

always @(posedge clk) begin
    if(rst) begin
        ex_alusel <= `ALU_SEL_NOP;
        ex_aluop <= `ALU_OP_NOP;
        ex_reg_1 <= 32'h00000000;
        ex_reg_2 <= 32'h00000000;
        ex_waddr <= 5'b00000;
        ex_we <= 1'b0;
        ex_link_addr_o  <= 32'h00000000;
        ex_inst <= 32'h00000000;
    end
    else begin
        ex_alusel <= id_alusel;
        ex_aluop <= id_aluop;
        ex_reg_1 <= id_reg_1;
        ex_reg_2 <= id_reg_2;
        ex_waddr <= id_waddr;
        ex_we <= id_we;
        ex_link_addr_o  <= id_link_addr_i;
        ex_inst <= id_inst;
    end
end

endmodule
