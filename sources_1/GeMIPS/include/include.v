/******************************************************************************
*   
*   文件名称：GeMIPS.v
*   文件说明：这个文件是GeMIPS的宏定义模块 
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

/*****************************************************************************/
/*      用来识别不同的指令类型（不包括R型指令）                                    */      
/*****************************************************************************/

`define     R_OP            6'b000000       ///< R型指令的OP

`define     R_ADDU_OP       6'b000000       ///< ADDU
`define     I_ADDIU_OP      6'b001001       ///< ADDIU
`define     R_MUL_OP        6'b011100       ///< MUL

`define     R_AND_OP        6'b000000       ///< AND
`define     I_ANDI_OP       6'b001100       ///< ANDI
`define     I_LUI_OP        6'b001111       ///< LUI
`define     R_OR_OP         6'b000000       ///< LUI
`define     I_ORI_OP        6'b001101       ///< ORI
`define     R_XOR_OP        6'b000000       ///< XOR
`define     I_XORI_OP       6'b001110       ///< XORI

`define     R_SLL_OP        6'b000000       ///< SLL
`define     R_SRL_OP        6'b000000       ///< SRL

`define     I_BEQ_OP        6'b000100       ///< BEQ
`define     I_BNE_OP        6'b000101       ///< BNE
`define     I_BGTZ_OP       6'b000111       ///< BGTZ
`define     J_J_OP          6'b000010       ///< J
`define     J_JAL_OP        6'b000011       ///< JAL
`define     R_JR_OP         6'b000000       ///< JR

`define     I_LB_OP         6'b100000       ///< LB
`define     I_LW_OP         6'b100011       ///< LW
`define     I_SB_OP         6'b101000       ///< SB
`define     I_SW_OP         6'b101011       ///< SW

/*****************************************************************************/
/*      用来识别不同的指令类型（仅包括R型指令）                                    */      
/*****************************************************************************/

`define     R_SLL_FUNC      6'b000000       ///< SLL
`define     R_MUL_FUNC      6'b000010       ///< MUL
`define     R_SRL_FUNC      6'b000010       ///< SRL
`define     R_SRA_FUNC      6'b000011       ///< SRA
`define     R_SLLV_FUNC     6'b000100       ///< SLLV
`define     R_SRLV_FUNC     6'b000110       ///< SRLV
`define     R_SRAV_FUNC     6'b000111       ///< SRAV
`define     R_JR_FUNC       6'b001000       ///< JR
`define     R_JALR_FUNC     6'b001001       ///< JALR
`define     R_MFHI_FUNC     6'b010000       ///< MFHI
`define     R_MULT_FUNC     6'b011000       ///< MULT
`define     R_MULTU_FUNC    6'b011001       ///< MULTU
`define     R_DIV_FUNC      6'b011010       ///< DIV
`define     R_DIVU_FUNC     6'b011011       ///< DIVU
`define     R_MFLO_FUNC     6'b010010       ///< MFLO
`define     R_MTHI_FUNC     6'b010001       ///< MTHI
`define     R_MTLO_FUNC     6'b010011       ///< MTLO
`define     R_ADD_FUNC      6'b100000       ///< ADD
`define     R_ADDU_FUNC     6'b100001       ///< ADDU
`define     R_SUB_FUNC      6'b100010       ///< SUB
`define     R_SUBU_FUNC     6'b100011       ///< SUBU
`define     R_AND_FUNC      6'b100100       ///< AND
`define     R_OR_FUNC       6'b100101       ///< OR
`define     R_XOR_FUNC      6'b100110       ///< XOR
`define     R_NOR_FUNC      6'b100111       ///< NOR
`define     R_SLT_FUNC      6'b101010       ///< SLT
`define     R_SLTU_FUNC     6'b101011       ///< SLTU

/*****************************************************************************/
/*      用来识别不同的操作                                                      */      
/*****************************************************************************/

`define     ALU_SEL_NOP     4'b0000         ///< 空
`define     ALU_SEL_LOGIC   4'b0001         ///< 逻辑运算

`define     ALU_OP_NOP      8'b00000000     ///< 空
`define     ALU_OP_AND      8'b00000001     ///< 按位与
`define     ALU_OP_OR       8'b00000010     ///< 按位或
`define     ALU_OP_NOT      8'b00000011     ///< 按位非
`define     ALU_OP_NOR      8'b00000100     ///< 按位或非
`define     ALU_OP_XOR      8'b00000101     ///< 按位异或

`define     ALU_OP_SLL      8'b00000110     ///< 逻辑左移
`define     ALU_OP_SRL      8'b00000111    ///< 逻辑右移

`define     ALU_OP_ADD      8'b00001000     ///< 加
`define     ALU_OP_SUB      8'b00001010     ///< 减
`define     ALU_OP_MUL      8'b00001011     ///< 有符号乘法
`define     ALU_OP_DIV      8'b00001100     ///< 除

`define     ALU_OP_LUI      8'b00001101     ///< LUI
`define     ALU_OP_JAR      8'b00001110     ///< JAR

/*****************************************************************************/
/*      用来告诉mem级如何操作                                                   */      
/*****************************************************************************/

`define     MEM_NOP         8'b00000000     ///< NOP
`define     MEM_LB          8'b00000001     ///< LB
`define     MEM_LW          8'b00000010     ///< LW
`define     MEM_SB          8'b00000011     ///< SB
`define     MEM_SW          8'b00000100     ///< SW

/*****************************************************************************/
/*                                                                           */      
/*****************************************************************************/
