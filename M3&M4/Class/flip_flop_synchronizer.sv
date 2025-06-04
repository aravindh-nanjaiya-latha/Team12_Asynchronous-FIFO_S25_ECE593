module flip_flop_synchronizer #(parameter int WIDTH = 3) (
  input  logic               clk,
  input  logic               rst_n,
  input  logic [WIDTH:0]     d_in,
  output logic [WIDTH:0]     d_out
);

  logic [WIDTH:0] q1;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q1     <= '0;
      d_out  <= '0;
    end else begin
      q1     <= d_in;
      d_out  <= q1;
    end
  end

endmodule


