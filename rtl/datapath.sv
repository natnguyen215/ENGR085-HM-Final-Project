module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic        PCWrite,
    input  logic        AdrSrc,
    input  logic        IRWrite,
    input  logic        RegWrite,
    input  logic [1:0]  ResultSrc,
    input  logic [1:0]  ImmSrc,
    input  logic [1:0]  ALUSrcA,
    input  logic [1:0]  ALUSrcB,
    input  logic [2:0]  ALUControl,
    input  logic [31:0] ReadData,
    output logic        Zero,
    output logic [31:0] Instr,
    output logic [31:0] Adr,
    output logic [31:0] WriteData
);
  logic [31:0] PC, OldPC, A;
  logic [31:0] RD1, RD2;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;
  logic [31:0] ALUResult;
  logic [31:0] Data;
  logic [31:0] ALUOut;

  enflopr #(32) pcreg (
      .clk  (clk),
      .reset(reset),
      .en   (PCWrite),
      .d    (Result),
      .q    (PC)
  );

  mux2 #(32) adrmux (
      .d0(PC),
      .d1(Result),
      .s (AdrSrc),
      .y (Adr)
  );

  enflopr #(32) instrreg (
      .clk  (clk),
      .reset(reset),
      .en   (IRWrite),
      .d    (ReadData),
      .q    (Instr)
  );

  enflopr #(32) oldpcreg (
      .clk  (clk),
      .reset(reset),
      .en   (IRWrite),
      .d    (PC),
      .q    (OldPC)
  );

  flopr #(32) datareg (
      .clk  (clk),
      .reset(reset),
      .d    (ReadData),
      .q    (Data)
  );

  regfile rf (
      .clk(clk),
      .we3(RegWrite),
      .a1 (Instr[19:15]),
      .a2 (Instr[24:20]),
      .a3 (Instr[11:7]),
      .wd3(Result),
      .rd1(RD1),
      .rd2(RD2)
  );

  extend ext (
      .instr (Instr[31:7]),
      .immsrc(ImmSrc),
      .immext(ImmExt)
  );

  flopr #(32) areg (
      .clk  (clk),
      .reset(reset),
      .d    (RD1),
      .q    (A)
  );

  flopr #(32) writedatareg (
      .clk  (clk),
      .reset(reset),
      .d    (RD2),
      .q    (WriteData)
  );

  mux3 #(32) srcbmux (
      .d0(WriteData),
      .d1(ImmExt),
      .d2(32'd4),
      .s (ALUSrcB),
      .y (SrcB)
  );

  mux3 #(32) srcamux (
      .d0(PC),
      .d1(OldPC),
      .d2(A),
      .s (ALUSrcA),
      .y (SrcA)
  );

  alu alu_unit (
      .a         (SrcA),
      .b         (SrcB),
      .alucontrol(ALUControl),
      .result    (ALUResult),
      .zero      (Zero)
  );

  flopr #(32) aluoutreg (
      .clk  (clk),
      .reset(reset),
      .d    (ALUResult),
      .q    (ALUOut)
  );

  mux3 #(32) resultmux (
      .d0(ALUOut),
      .d1(Data),
      .d2(ALUResult),
      .s (ResultSrc),
      .y (Result)
  );
endmodule

