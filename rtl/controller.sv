module controller (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero,
    output logic [1:0] immsrc,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic [2:0] alucontrol,
    output logic       irwrite,
    output logic       pcwrite,
    output logic       regwrite,
    output logic       memwrite
);
  logic [1:0] aluop;
  logic       branch;
  logic       pcupdate;

  fsm mainfsm (
      .clk      (clk),
      .reset    (reset),
      .op       (op),
      .alusrca  (alusrca),
      .alusrcb  (alusrcb),
      .resultsrc(resultsrc),
      .adrsrc   (adrsrc),
      .regwrite (regwrite),
      .memwrite (memwrite),
      .irwrite  (irwrite),
      .aluop    (aluop),
      .branch   (branch),
      .pcupdate (pcupdate)
  );

  aludec aludecoder (
      .f7b5      (funct7b5),
      .op5       (op[5]),
      .funct3    (funct3),
      .aluop     (aluop),
      .alucontrol(alucontrol)
  );

  instrdec instrdecoder (
      .op    (op),
      .immsrc(immsrc)
  );

  assign pcwrite = pcupdate | (branch & zero);
endmodule

module fsm (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic       regwrite,
    output logic       memwrite,
    output logic       irwrite,
    output logic [1:0] aluop,
    output logic       branch,
    output logic       pcupdate
);
  typedef enum logic [4:0] {
    s0,
    s1,
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
    s8,
    s9,
    s10
  } statetype;

  statetype state, nextstate;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= s0;
    else state <= nextstate;
  end

  always_comb begin
    case (state)
      s0: nextstate = s1;
      s1: begin
        case (op)
          7'b0000011: nextstate = s2;   // lw
          7'b0100011: nextstate = s2;   // sw
          7'b0110011: nextstate = s6;   // R-type
          7'b1100011: nextstate = s10;  // beq
          7'b0010011: nextstate = s8;   // I-type ALU
          7'b1101111: nextstate = s9;   // jal
          default:    nextstate = s0;
        endcase
      end
      s2: begin
        if (op == 7'b0000011) nextstate = s3;
        else nextstate = s5;
      end
      s3:      nextstate = s4;
      s4:      nextstate = s0;
      s5:      nextstate = s0;
      s6:      nextstate = s7;
      s7:      nextstate = s0;
      s8:      nextstate = s7;
      s9:      nextstate = s7;
      s10:     nextstate = s0;
      default: nextstate = s0;
    endcase
  end

  always_comb begin
    branch    = 1'b0;
    pcupdate  = 1'b0;
    regwrite  = 1'b0;
    memwrite  = 1'b0;
    irwrite   = 1'b0;
    resultsrc = 2'b00;
    alusrca   = 2'b00;
    alusrcb   = 2'b00;
    adrsrc    = 1'b0;
    aluop     = 2'b00;

    case (state)
      s0: begin
        pcupdate  = 1'b1;
        irwrite   = 1'b1;
        resultsrc = 2'b10;
        alusrcb   = 2'b10;
      end
      s1: begin
        alusrca = 2'b01;
        alusrcb = 2'b01;
      end
      s2: begin
        alusrca = 2'b10;
        alusrcb = 2'b01;
      end
      s3: begin
        adrsrc = 1'b1;
      end
      s4: begin
        regwrite  = 1'b1;
        resultsrc = 2'b01;
      end
      s5: begin
        memwrite = 1'b1;
        adrsrc   = 1'b1;
      end
      s6: begin
        alusrca = 2'b10;
        aluop   = 2'b10;
      end
      s7: begin
        regwrite = 1'b1;
      end
      s8: begin
        alusrca = 2'b10;
        alusrcb = 2'b01;
        aluop   = 2'b10;
      end
      s9: begin
        pcupdate = 1'b1;
        alusrca  = 2'b01;
        alusrcb  = 2'b10;
      end
      s10: begin
        branch  = 1'b1;
        alusrca = 2'b10;
        aluop   = 2'b01;
      end
      default: begin
      end
    endcase
  end
endmodule

module aludec (
    input  logic       f7b5,
    input  logic       op5,
    input  logic [2:0] funct3,
    input  logic [1:0] aluop,
    output logic [2:0] alucontrol
);
  always_comb begin
    case (aluop)
      2'b00: alucontrol = 3'b000;
      2'b01: alucontrol = 3'b001;
      2'b10: begin
        case (funct3)
          3'b000: begin
            if (op5 & f7b5) alucontrol = 3'b001;
            else alucontrol = 3'b000;
          end
          3'b010:  alucontrol = 3'b101;
          3'b110:  alucontrol = 3'b011;
          3'b111:  alucontrol = 3'b010;
          default: alucontrol = 3'b000;
        endcase
      end
      default: alucontrol = 3'b000;
    endcase
  end
endmodule

module instrdec (
    input  logic [6:0] op,
    output logic [1:0] immsrc
);
  always_comb begin
    case (op)
      7'b0000011: immsrc = 2'b00;  // lw
      7'b0100011: immsrc = 2'b01;  // sw
      7'b0110011: immsrc = 2'b00;  // R-type
      7'b1100011: immsrc = 2'b10;  // beq
      7'b0010011: immsrc = 2'b00;  // I-type ALU
      7'b1101111: immsrc = 2'b11;  // jal
      default:    immsrc = 2'b00;
    endcase
  end
endmodule

