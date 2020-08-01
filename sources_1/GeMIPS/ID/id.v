/******************************************************************************
*   
*   文件名称：id.v
*   文件说明：这个文件是GeMIPS的译指级别的主要模块�?
* 
*   作�?�：葛启�?
*   时间�?2020-07-07
*
******************************************************************************/

// `include "../include/include.v";

module id (
           input    wire        rst,            ///< 重置
           input    wire        clk,            ///< 时钟信号

           input    wire[31:0]  pc,             ///< 指令的地址
           input    wire[31:0]  inst,           ///< 指令编码

           output   reg [4:0]   raddr_1,        ///< 读寄存器的地址
           output   reg         re_1,           ///< 读寄存器的使能
           input    wire[31:0]  rdata_1,        ///< 读寄存器获取的数据

           output   reg [4:0]   raddr_2,        ///< 读寄存器的地�?
           output   reg         re_2,           ///< 读寄存器的使�?
           input    wire[31:0]  rdata_2,        ///< 读寄存器获取的数�?

           output   reg [7:0]   aluop,          ///< 子操�?
           output   reg [3:0]   alusel,         ///< 操作

           output   reg [31:0]  reg_1,          ///< 源操作数1
           output   reg [31:0]  reg_2,          ///< 源操作数2

           output   reg [4:0]   waddr,          ///< �?要写入的寄存器的地址
           output   reg         we,             ///< �?要吸入的使能

           /// 数据前推
           input    wire        ex_we_i,        ///< 执行�? 写使�?
           input    wire[4:0]   ex_waddr_i,     ///< 执行�? 写地�?
           input    wire[31:0]  ex_wdata_i,     ///< 执行�? 写数�?

           input    wire        mem_we_i,       ///< 访存级别 写使�?
           input    wire[4:0]   mem_waddr_i,    ///< 访存级别 写地�?
           input    wire[31:0]  mem_wdata_i,     ///< 访存级别 写数�?

           /// 分支跳转
           output   reg         branch_flag_o,
           output   reg[31:0]   target_address_o,
           output   reg[31:0]   link_addr_o,

           /// 存储相关
           output  wire[31:0]   inst_o,           ///< 用于传�?�指令给ex级计算地�?

           /// 暂停信号
           output   reg         is_stop
       );

assign inst_o = inst;

wire[5:0] opcode       = inst[31:26];
wire[4:0] rs           = inst[25:21];
wire[4:0] rt           = inst[20:16];
wire[15:0] immediate   = inst[15:0];
wire[25:0] instr_index = inst[25:0];
wire[4:0] rd           = inst[15:11];
wire[4:0] sa           = inst[10:6];
wire[5:0] func         = inst[5:0];
wire[15:0] offset      = inst[15:0];

wire[31:0] immu = {16'b0000_0000_0000_0000, immediate};   ///< 无符号扩�?
wire[31:0] imms = {{16{immediate[15]}}, immediate};        ///< 有符号扩�?

/// 用来确定是符号扩展还是无符号扩展
/// 1'b0    无符号扩展
/// 1'b1    有符号扩展
reg       uos;

/// 用来确定是使 sa 还是 imm
/// 1'b0    imm
/// 1'b1    sa
reg       use_sa;

/**
 *  确定是否需要跳转？
 */
always @(*) begin
    if(rst) begin
        branch_flag_o <= 1'b0;
        target_address_o <= 32'h00000000;
        link_addr_o <= 32'h0000_0000;
    end
    else begin
        case (opcode)
            `R_OP: begin
                case (func)
                    `R_JR_FUNC: begin
                        branch_flag_o <= 1'b1;
                        target_address_o <= reg_1;
                        link_addr_o <= 32'h0000_0000;
                    end
                    default : begin
                        branch_flag_o <= 1'b0;
                        target_address_o <= 32'h00000000;
                        link_addr_o <= 32'h0000_0000;
                    end
                endcase
            end
            `I_BEQ_OP: begin
                if( reg_1 == reg_2) begin
                    branch_flag_o <= 1'b1;
                    target_address_o <= pc + {{14{offset[15]}},{offset[15:0], 2'b00}} + 32'h000000004;
                    link_addr_o <= 32'h0000_0000;
                end
                else begin
                    branch_flag_o <= 1'b0;
                    target_address_o <= 32'h00000000;
                    link_addr_o <= 32'h0000_0000;
                end
            end
            `I_BNE_OP: begin
                if( reg_1 != reg_2) begin
                    branch_flag_o <= 1'b1;
                    target_address_o <= pc + {{14{offset[15]}},{offset[15:0], 2'b00}} + 32'h000000004;
                    link_addr_o <= 32'h0000_0000;
                end
                else begin
                    branch_flag_o <= 1'b0;
                    target_address_o <= 32'h00000000;
                    link_addr_o <= 32'h0000_0000;
                end
            end
            `I_BGTZ_OP: begin
                if( reg_1 > 0) begin
                    branch_flag_o <= 1'b1;
                    target_address_o <= pc + {{14{offset[15]}},{offset[15:0], 2'b00}};
                    link_addr_o <= 32'h0000_0000;
                end
                else begin
                    branch_flag_o <= 1'b0;
                    target_address_o <= 32'h00000000;
                    link_addr_o <= 32'h0000_0000;
                end
            end
            `J_J_OP: begin
                branch_flag_o <= 1'b1;
                target_address_o <= {pc[31:28], {instr_index, 2'b00}};
                link_addr_o <= 32'h0000_0000;
            end
            `J_JAL_OP: begin
                branch_flag_o <= 1'b1;
                target_address_o <= {pc[31:28], {instr_index, 2'b00}};
                link_addr_o <= pc + 8;
            end
            default : begin
                branch_flag_o <= 1'b0;
                target_address_o <= 32'h00000000;
                link_addr_o <= 32'h0000_0000;
            end
        endcase
    end
end


/**
 * 处理暂停信号
 */
always @(*) begin
    if(rst) begin
        is_stop <= 1'b0;
    end
    else begin
        case (opcode)
            `I_LW_OP,
            `I_LB_OP: begin
                is_stop <= 1'b1;
            end
            default: begin
                is_stop <= 1'b0;
            end
        endcase
    end
end


/**
 *  确定是否写入寄存器以及写入的地址
 */
always @(*) begin
    if(rst) begin
        waddr <= 5'b00000;
        we <= 1'b0;
    end
    else begin
        case (opcode)
            `R_OP : begin
                case (func)
                    `R_JR_FUNC: begin
                        waddr <= rd;
                        we <= 1'b0;
                    end
                    default : begin
                        waddr <= rd;
                        we <= 1'b1;
                    end
                endcase
            end
            `I_LW_OP,
            `I_LB_OP,
            `I_XORI_OP,
            `I_LUI_OP,
            `I_ADDIU_OP,
            `I_ANDI_OP,
            `I_ORI_OP: begin
                waddr <= rt;
                we <= 1'b1;
            end
            `J_JAL_OP: begin
                waddr <= 5'b11111;
                we <= 1'b1;
            end
            `R_MUL_OP: begin
                waddr <= rd;
                we <= 1'b1;
            end
            default : begin
                waddr <= 5'b00000;
                we <= 1'b0;
            end
        endcase
    end
end

/**
 *  确定操作以及子操作
 */
always @(*) begin
    if(rst) begin
        alusel <= `ALU_SEL_NOP;
        aluop <= `ALU_OP_NOP;
    end
    else begin
        alusel <= `ALU_SEL_NOP;
        case (opcode)
            `R_OP : begin
                case (func)
                    `R_ADDU_FUNC: begin
                        aluop <= `ALU_OP_ADD;
                    end
                    `R_AND_FUNC: begin
                        aluop <= `ALU_OP_AND;
                    end
                    `R_OR_FUNC: begin
                        aluop <= `ALU_OP_OR;
                    end
                    `R_XOR_FUNC: begin
                        aluop <= `ALU_OP_XOR;
                    end
                    `R_SLL_FUNC: begin
                        aluop <= `ALU_OP_SLL;
                    end
                    `R_SRL_FUNC: begin
                        aluop <= `ALU_OP_SRL;
                    end
                    default: begin
                        aluop <= `ALU_OP_NOP;
                    end
                endcase
            end
            `I_ORI_OP: begin
                aluop <= `ALU_OP_OR;
            end
            `I_ADDIU_OP: begin
                aluop <= `ALU_OP_ADD;
            end
            `I_ANDI_OP: begin
                aluop <= `ALU_OP_AND;
            end
            `I_LUI_OP: begin
                aluop <= `ALU_OP_LUI;
            end
            `I_XORI_OP: begin
                aluop <= `ALU_OP_XOR;
            end
            `J_JAL_OP: begin
                aluop <= `ALU_OP_JAR;
            end
            `R_MUL_OP: begin
                if(func == `R_MUL_FUNC) begin
                    aluop <= `ALU_OP_MUL;
                end
                else begin
                    aluop <= `ALU_OP_NOP;
                end
            end
            default: begin
                aluop <= `ALU_OP_NOP;
            end
        endcase
    end
end

/**
 * 确定相关操作数的地址
 */
always @(*) begin
    if(rst) begin
        raddr_1 <= 5'b00000;
        re_1 <= 1'b0;
        raddr_2 <= 5'b00000;
        re_2 <= 1'b0;
    end
    else begin
        case (opcode)
            `R_OP : begin
                case (func)
                    `R_JR_FUNC,
                    `R_XOR_FUNC,
                    `R_OR_FUNC,
                    `R_ADDU_FUNC,
                    `R_AND_FUNC: begin
                        raddr_1 <= rs;
                        re_1 <= 1'b1;
                        raddr_2 <= rt;
                        re_2 <= 1'b1;
                    end
                    `R_SRL_FUNC,
                    `R_SLL_FUNC: begin
                        raddr_1 <= rt;
                        re_1 <= 1'b1;
                        raddr_2 <= 5'b00000;
                        re_2 <= 1'b0;
                    end
                    default : begin
                        raddr_1 <= rs;
                        re_1 <= 1'b1;
                        raddr_2 <= rt;
                        re_2 <= 1'b1;
                    end
                endcase
            end
            `I_BGTZ_OP,
            `I_ADDIU_OP,
            `I_ANDI_OP,
            `I_XORI_OP,
            `I_ORI_OP: begin
                raddr_1 <= rs;
                re_1 <= 1'b1;
                raddr_2 <= rs;
                re_2 <= 1'b0;
            end
            `I_LUI_OP: begin
                raddr_1 <= rs;
                re_1 <= 1'b0;
                raddr_2 <= rs;
                re_2 <= 1'b0;
            end
            `I_SW_OP,
            `I_SB_OP,
            `I_BNE_OP,
            `I_BEQ_OP: begin
                raddr_1 <= rs;
                re_1 <= 1'b1;
                raddr_2 <= rt;
                re_2 <= 1'b1;
            end
            `I_LW_OP,
            `I_LB_OP: begin
                raddr_1 <= rs;
                re_1 <= 1'b1;
                raddr_2 <= rt;
                re_2 <= 1'b0;
            end
            `R_MUL_OP: begin
                if(func == `R_MUL_FUNC) begin
                    raddr_1 <= rs;
                    re_1 <= 1'b1;
                    raddr_2 <= rt;
                    re_2 <= 1'b1;
                end
                else begin
                    raddr_1 <= 5'b00000;
                    re_1 <= 1'b0;
                    raddr_2 <= 5'b00000;
                    re_2 <= 1'b0;
                end
            end
            default: begin
                raddr_1 <= 5'b00000;
                re_1 <= 1'b0;
                raddr_2 <= 5'b00000;
                re_2 <= 1'b0;
            end
        endcase
    end
end

/**
 *  确定有符号扩展还是无符号扩展
 *      /// 1'b0    无符号扩展
 *      /// 1'b1    有符号扩展
 */
always @(*) begin
    if(rst) begin
        uos <= 1'b0;
    end
    else begin
        case (opcode)
            `I_LUI_OP,
            `I_ANDI_OP,
            `I_XORI_OP,
            `I_ORI_OP: begin
                uos <= 1'b0;        /// 1'b0    无符号扩展
            end
            `I_LB_OP,
            `I_ADDIU_OP: begin
                uos <= 1'b1;        /// 1'b1    有符号扩展
            end
            default: begin
                uos <= 1'b0;
            end
        endcase
    end
end

/// 用来确定是使用 sa 还是 imm
/// 1'b0    imm
/// 1'b1    sa
always @(*) begin
    if(rst) begin
        use_sa <= 1'b0;
    end
    else begin
        case (opcode)
            `R_OP: begin
                case (func)
                    `R_SRL_FUNC,
                    `R_SLL_FUNC: begin
                        use_sa <= 1'b1;
                    end
                    default: begin
                        use_sa <= 1'b0;
                    end
                endcase
            end
            default: begin
                use_sa <= 1'b0;
            end
        endcase
    end
end



/**
 *  确定操作数1
 */
always @(*) begin
    if(rst) begin
        reg_1 <= 32'h00000000;
    end
    else begin
        if ((re_1 == 1'b1 && ex_we_i==1'b1) &&
                (raddr_1 == ex_waddr_i)) begin
            reg_1 <= ex_wdata_i;
        end
        else if ((re_1 == 1'b1 && mem_we_i==1'b1) &&
                 (raddr_1 == mem_waddr_i)) begin
            reg_1 <= mem_wdata_i;
        end
        else if (re_1 == 1'b1) begin
            reg_1 <= rdata_1;
        end
        else if (re_1 == 1'b0) begin
            // reg_1 <= uos ? imms : immu;
            if(use_sa) begin
                reg_1 <= {{28{1'b0}}, sa};
            end
            else if(uos) begin
                reg_1 <= imms;
            end
            else begin
                reg_1 <= immu;
            end
        end
        else begin
            reg_1 <= 32'h00000000;
        end
    end
end

/**
 *  确定操作数2
 */
always @(*) begin
    if(rst) begin
        reg_2 <= 32'h00000000;
    end
    else begin
        if ((re_2 == 1'b1 && ex_we_i==1'b1) &&
                (raddr_2 == ex_waddr_i)) begin
            reg_2 <= ex_wdata_i;
        end
        else if ((re_2 == 1'b1 && mem_we_i==1'b1) &&
                 (raddr_2 == mem_waddr_i)) begin
            reg_2 <= mem_wdata_i;
        end
        else if (re_2 == 1'b1) begin
            reg_2 <= rdata_2;
        end
        else if (re_2 == 1'b0) begin
            // reg_2 <= uos ? imms : immu;
            if(use_sa) begin
                reg_2 <= {{28{1'b0}}, sa};
            end
            else if(uos) begin
                reg_2 <= imms;              ///< 符号扩展的操作数
            end
            else begin
                reg_2 <= immu;              ///< 无符号扩展的操作数
            end
        end
        else begin
            reg_2 <= 32'h00000000;
        end
    end
end


endmodule
