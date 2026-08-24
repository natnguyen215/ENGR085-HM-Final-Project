module memory (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);
  logic [31:0] RAM[63:0];

  initial $readmemh("program/memfile.dat", RAM);

  assign rd = RAM[a[31:2]];

  always_ff @(posedge clk) begin
    if (we) RAM[a[31:2]] <= wd;
  end
endmodule
