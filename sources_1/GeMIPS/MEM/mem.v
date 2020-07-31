/******************************************************************************
*   
*   文件名称：mem.v
*   文件说明：这个文件是GeMIPS的执行模块
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

// `include "../include/include.v";

module mem (
           input        wire        rst,        ///< 重置
           input        wire        clk,        ///< 时钟信号

           input        wire        we_i,       ///< 从EX级来的写使能信号
           input        wire[4:0]   waddr_i,    ///< 从EX级来的写地址
           input        wire[31:0]  wdata_i,    ///< 从EX级来的写数据

           output       reg         we_o,       ///< 到WB级的写使能信号
           output       reg[4:0]    waddr_o,    ///< 到WB级的写地址
           output       reg[31:0]   wdata_o,    ///< 到WB级的写数据

           /// 存储相关
           input        wire[7:0]   mem_op,     ///< 存储操作
           input        wire[31:0]  mem_addr_i, ///< 存储需要进行操作的地址
           input        wire[31:0]  mem_data_i, ///< 存储需要进行操作的数据

           input      wire[31:0]    ram_data_i,  ///< 来自存储器
           output      reg[31:0]    mem_addr_o,  ///< 存储需要进行操作的地址
           output      reg[31:0]    mem_data_o,  ///< 存储需要进行操作的数据
           output      reg          mem_we_o,    ///< 是否为写操作
           output      reg[3:0]     mem_sel_o,   ///< 存储器内部的字节使能信号
           output      reg          mem_ce_o,     ///< 使能信号

           /// 暂停信号
           output      reg          stop_end
       );

always@(*) begin
    if(rst) begin
        we_o <= 1'b0;
        waddr_o <= 5'b00000;
        wdata_o <= 32'h00000000;
        mem_addr_o <= 32'b00000000;
        mem_data_o <= 32'b00000000;
        mem_we_o <= 1'b0;
        mem_sel_o <= 4'b0000;
        mem_ce_o <= 1'b0;
    end
    else begin
        we_o <= we_i;
        waddr_o <= waddr_i;
        case (mem_op)
            `MEM_LB:  begin
                mem_addr_o <= mem_addr_i;
                mem_data_o <= 32'b00000000;
                mem_we_o <= 1'b1;
                mem_sel_o <= 4'b1110;
                mem_ce_o <= 1'b1;
                wdata_o <= ram_data_i;
            end
            `MEM_LW:  begin
                mem_addr_o <= mem_addr_i;
                mem_data_o <= 32'b00000000;
                mem_we_o <= 1'b1;
                mem_sel_o <= 4'b0000;
                mem_ce_o <= 1'b1;
                wdata_o <= ram_data_i;
            end
            `MEM_SB:  begin
                mem_addr_o <= mem_addr_i;
                mem_data_o <= mem_data_i;
                mem_we_o <= 1'b0;
                mem_sel_o <= 4'b1110;
                mem_ce_o <= 1'b1;
                wdata_o <= 32'b00000000;
            end
            `MEM_SW:  begin
                mem_addr_o <= mem_addr_i;
                mem_data_o <= mem_data_i;
                mem_we_o <= 1'b0;
                mem_sel_o <=  4'b0000;
                mem_ce_o <= 1'b1;
                wdata_o <= 32'b00000000;
            end
            default: begin
                wdata_o <= wdata_i;
                mem_addr_o <= 32'b00000000;
                mem_data_o <= 32'b00000000;
                mem_we_o <= 1'b0;
                mem_sel_o <= 4'b0000;
                mem_ce_o <= 1'b0;
            end
        endcase
    end
end

always@(*) begin
    if(rst) begin
        stop_end <= 0'b0;
    end
    else begin
        case (mem_op)
            `MEM_LB,
            `MEM_LW:  begin
                stop_end <= 0'b1;
            end
            default: begin
                stop_end <= 0'b0;
            end
        endcase
    end
end


endmodule
