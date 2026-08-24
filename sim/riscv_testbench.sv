module testbench;
  logic        clk;
  logic        reset;
  logic [31:0] write_data;
  logic [31:0] data_address;
  logic        mem_write;

  top dut (
      .clk      (clk),
      .reset    (reset),
      .WriteData(write_data),
      .DataAdr  (data_address),
      .MemWrite (mem_write)
  );

  initial begin
    reset <= 1'b1;
    #22;
    reset <= 1'b0;
  end

  always begin
    clk <= 1'b1;
    #5;
    clk <= 1'b0;
    #5;
  end

  always @(negedge clk) begin
    if (mem_write) begin
      if ((data_address === 32'd84) && (write_data === 32'd71)) begin
        $display("Simulation succeeded");
        $stop;
      end else if (data_address !== 32'd80) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end
endmodule
