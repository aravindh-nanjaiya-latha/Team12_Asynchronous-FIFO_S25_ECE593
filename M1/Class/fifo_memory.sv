module fifo_memory #(
  parameter int DEPTH      = 8,
  parameter int DATA_WIDTH = 8,
  parameter int PTR_WIDTH  = 3
)(
  input  logic                   wclk,
  input  logic                   w_en,
  input  logic                   rclk,
  input  logic                   r_en,
  input  logic [PTR_WIDTH:0]     b_wptr,
  input  logic [PTR_WIDTH:0]     b_rptr,
  input  logic [DATA_WIDTH-1:0]  data_in,
  input  logic                   full,
  input  logic                   empty,
  output logic [DATA_WIDTH-1:0]  data_out
);

  logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

  // Write to FIFO
  always_ff @(posedge wclk) begin
    if (w_en && !full)
      fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
  end

  // Continuous read output (combinational)
  assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];

  /*
  // Optional: registered read
  always_ff @(posedge rclk) begin
    if (r_en && !empty)
      data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
  end
  */

endmodule

