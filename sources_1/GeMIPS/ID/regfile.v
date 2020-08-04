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


reg[31:0] regs[0:31]; ///< 32个32位通用寄存器

/// DEBUG REGS
(*mark_debug = "true"*)wire[31:0] debug_regs_zero_0 = regs[0];
(*mark_debug = "true"*)wire[31:0] debug_regs_at_1 = regs[1];
(*mark_debug = "true"*)wire[31:0] debug_regs_v0_2 = regs[2];
(*mark_debug = "true"*)wire[31:0] debug_regs_v1_3 = regs[3];
(*mark_debug = "true"*)wire[31:0] debug_regs_a0_4 = regs[4];
(*mark_debug = "true"*)wire[31:0] debug_regs_a1_5 = regs[5];
(*mark_debug = "true"*)wire[31:0] debug_regs_a2_6 = regs[6];
(*mark_debug = "true"*)wire[31:0] debug_regs_a3_7 = regs[7];
(*mark_debug = "true"*)wire[31:0] debug_regs_t0_8 = regs[8];
(*mark_debug = "true"*)wire[31:0] debug_regs_t1_9 = regs[9];
(*mark_debug = "true"*)wire[31:0] debug_regs_t2_10 = regs[10];
(*mark_debug = "true"*)wire[31:0] debug_regs_t3_11 = regs[11];
(*mark_debug = "true"*)wire[31:0] debug_regs_t4_12 = regs[12];
(*mark_debug = "true"*)wire[31:0] debug_regs_t5_13 = regs[13];
(*mark_debug = "true"*)wire[31:0] debug_regs_t6_14 = regs[14];
(*mark_debug = "true"*)wire[31:0] debug_regs_t7_15 = regs[15];
(*mark_debug = "true"*)wire[31:0] debug_regs_s0_16 = regs[16];
(*mark_debug = "true"*)wire[31:0] debug_regs_s1_17 = regs[17];
(*mark_debug = "true"*)wire[31:0] debug_regs_s2_18 = regs[18];
(*mark_debug = "true"*)wire[31:0] debug_regs_s3_19 = regs[19];
(*mark_debug = "true"*)wire[31:0] debug_regs_s4_20 = regs[20];
(*mark_debug = "true"*)wire[31:0] debug_regs_s5_21 = regs[21];
(*mark_debug = "true"*)wire[31:0] debug_regs_s6_22 = regs[22];
(*mark_debug = "true"*)wire[31:0] debug_regs_s7_23 = regs[23];
(*mark_debug = "true"*)wire[31:0] debug_regs_t8_24 = regs[24];
(*mark_debug = "true"*)wire[31:0] debug_regs_t9_25 = regs[25];
(*mark_debug = "true"*)wire[31:0] debug_regs_26 = regs[26];
(*mark_debug = "true"*)wire[31:0] debug_regs_27 = regs[27];
(*mark_debug = "true"*)wire[31:0] debug_regs_gp_28 = regs[28];
(*mark_debug = "true"*)wire[31:0] debug_regs_sp_29 = regs[29];
(*mark_debug = "true"*)wire[31:0] debug_regs_fp_30 = regs[30];
(*mark_debug = "true"*)wire[31:0] debug_regs_ra_31 = regs[31];


/**
 *  写入操作行为
 */
integer i;
always@(negedge clk) begin
    if(rst) begin
        for ( i= 0;i < 32;i = i+1 ) begin
            regs[i] <= 32'h00000000;
        end
    end
    else begin
        if(we == 1'b1) begin
            if(waddr != 5'b00000) begin
                regs[waddr] <= wdata;
            end
            else begin
                for ( i= 0;i < 32;i = i+1 ) begin
                    regs[i] <= regs[i];
                end
            end
        end
        else begin
            for ( i= 0;i < 32;i = i+1 ) begin
                regs[i] <= regs[i];
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
