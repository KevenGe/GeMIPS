module rom (
           input    wire[31:0]    rom_addr_i,   ///< 读坖指令的地�?
           input    wire           ce_i,         ///< 使能信坷
           output   reg [31:0]    rom_data_o    ///< 获坖到的指令
       );

reg[31:0] rom[65536:0];

initial begin
    $readmemh("isnt_rom.bin.data", rom);
end

always@(*) begin
    if(ce_i) begin
        rom_data_o <= rom[rom_addr_i[17:2]];
    end
end

endmodule
