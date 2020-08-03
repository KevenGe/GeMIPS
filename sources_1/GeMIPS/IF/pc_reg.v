/******************************************************************************
*   
*   文件名称：pc_reg.v
*   文件说明： 这个文件是GeMIPS的PC，用于取指令，传递指令地址
* 
*   作者：葛启丰
*   时间：2020-07-07
*
******************************************************************************/

module pc_reg (
           input    wire        rst,    ///< 重置
           input    wire        clk,    ///< 时钟

           output   reg [31:0]  pc,     ///< 地址
           output   reg         ce,      ///< 使能（读）

           /// 分支跳转
           input     wire       branch_flag_i,
           input    wire[31:0]  branch_address_i,

           (*mark_debug = "true"*)input    wire        stops_stop      ///< 暂停信号
       );


reg [31:0] next_pc;

// 在时钟上升沿出发
// 设定使能信号以及地址
always@(posedge clk) begin
    if(rst) begin
        ce <= 1'b0;
        pc <= 32'h8000_0000;
        next_pc <= 32'h8000_0000 + 4'b0100;
    end
    else begin
        if (stops_stop) begin
            /// 流水线暂停，保持原有状态
            ce <= ce;
            next_pc <= next_pc;
            pc <= pc;
        end
        else if(branch_flag_i) begin
            ce <= 1'b1;
            next_pc <= branch_address_i + 4'b0100;
            pc <= branch_address_i;
        end
        else begin
            ce <= 1'b1;
            next_pc <= next_pc + 4'b0100;
            pc <= next_pc;
        end
    end
end

endmodule
