/******************************************************************************
*   
*   文件名称：ex.v
*   文件说明：这个文件是GeMIPS的执行模�?
* 
*   作�?�：葛启�?
*   时间�?2020-07-07
*
******************************************************************************/

// `include "../include/include.v";

module ex (
           input   wire        rst,    ///< 重置
           input   wire        clk,    ///< 时钟信号

           input   wire[3:0]   alusel,
           input   wire[7:0]   aluop,

           input   wire[31:0]  reg_1,
           input   wire[31:0]  reg_2,

           input   wire[4:0]   waddr,
           input   wire        we,

           output  reg [31:0]  wdata_o,
           output  reg [4:0]   waddr_o,
           output  reg         we_o,

           // 分支指令
           input   wire[31:0]  link_addr_i,

           // 存储相关
           input    wire[31:0]  inst_i,         ///< 传�?�来的指�?

           output   reg[7:0]    mem_op,         ///< 存储类型
           output   reg[31:0]   mem_addr_o,     ///< �?要进行更改的存储的地�?
           output   reg[31:0]   mem_data_o      ///< �?要进行存储的数据
       );

wire [31:0]     multiplier;                     ///< 乘数
wire [31:0]     multiplicand;                   ///< 被乘数
wire [63:0]     mul_tmp;                        ///< 储存临时计算的结果

assign multiplier = reg_1[31] ? (~reg_1 +1'b1) : reg_1;
assign multiplicand = reg_2[31] ? (~reg_2 +1'b1) : reg_2;
assign mul_tmp = multiplier * multiplicand;

/**
 *  计算输出的元素
 */
always@(*) begin
    if(rst) begin
        wdata_o <= 32'h00000000;
        waddr_o <= 5'b00000;
        we_o <= 1'b0;
    end
    else begin
        waddr_o <= waddr;
        we_o <= we;
        case (aluop)
            `ALU_OP_OR: begin
                wdata_o <= reg_1 | reg_2;
            end
            `ALU_OP_AND: begin
                wdata_o <= reg_1 & reg_2;
            end
            `ALU_OP_NOT: begin
                wdata_o <= ~reg_1;
            end
            `ALU_OP_ADD: begin
                wdata_o <= reg_1 + reg_2;
            end
            `ALU_OP_MUL: begin
                if(reg_1[31] * reg_2[31] == 1'b1) begin
                    wdata_o <= ~mul_tmp+1;
                end
                else begin
                    wdata_o <= mul_tmp;
                end
            end
            `ALU_OP_LUI: begin
                wdata_o <= { reg_1[15:0], {16{1'b0}}};
            end
            `ALU_OP_XOR: begin
                wdata_o <= reg_1 ^ reg_2;
            end
            `ALU_OP_SLL: begin
                wdata_o <= reg_1 << reg_2;
            end
            `ALU_OP_SRL: begin
                wdata_o <= reg_1 >> reg_2;
            end
            `ALU_OP_JAR: begin
                wdata_o <= link_addr_i;
            end
            default: begin
                wdata_o <= 32'h00000000;
            end
        endcase
    end
end

/**
 *  专门处理存储相关的操作
 */
wire[5:0] opcode       = inst_i[31:26];
wire[4:0] rs           = inst_i[25:21];
wire[4:0] rt           = inst_i[20:16];
wire[15:0] immediate   = inst_i[15:0];
wire[25:0] instr_index = inst_i[25:0];
wire[4:0] rd           = inst_i[15:11];
wire[4:0] sa           = inst_i[10:6];
wire[5:0] func         = inst_i[5:0];
wire[15:0] offset      = inst_i[15:0];

wire[31:0] immu = {16'b0000_0000_0000_0000, immediate};   ///< 无符号扩展
wire[31:0] imms = {{16{immediate[15]}}, immediate};        ///< 有符号扩展

always@(*) begin
    if(rst) begin
        mem_op <= `MEM_NOP;
        mem_addr_o <= 32'b0000_0000;
        mem_data_o <= 32'b0000_0000;
    end
    else begin
        case (opcode)
            `I_LB_OP: begin
                mem_op <= `MEM_LB;
                mem_addr_o <= reg_1 + {{16{immediate[15]}}, immediate};
                mem_data_o <= 32'b0000_0000;
            end
            `I_LW_OP: begin
                mem_op <= `MEM_LW;
                mem_addr_o <= reg_1 + imms;
                mem_data_o <= 32'b0000_0000;
            end
            `I_SB_OP: begin
                mem_op <= `MEM_SB;
                mem_addr_o <= reg_1 + imms;
                mem_data_o <= {24'h000000, reg_2[7:0]};
            end
            `I_SW_OP: begin
                mem_op <= `MEM_SW;
                mem_addr_o <= reg_1 + imms;
                mem_data_o <= reg_2;
            end
            default: begin
                mem_op <= `MEM_NOP;
                mem_addr_o <= 32'b0000_0000;
                mem_data_o <= 32'b0000_0000;
            end
        endcase
    end
end

endmodule
