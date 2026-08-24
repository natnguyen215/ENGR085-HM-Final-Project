module top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite
);
  logic [31:0] ReadData;

  riscvmulti riscv (
      .clk      (clk),
      .reset    (reset),
      .MemWrite (MemWrite),
      .Adr      (DataAdr),
      .WriteData(WriteData),
      .ReadData (ReadData)
  );

  memory mem (
      .clk(clk),
      .we (MemWrite),
      .a  (DataAdr),
      .wd (WriteData),
      .rd (ReadData)
  );
endmodule

