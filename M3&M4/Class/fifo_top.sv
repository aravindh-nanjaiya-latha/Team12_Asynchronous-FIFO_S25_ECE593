`include "fifo_if.sv"
`include "fifo_test.sv"

module fifo_top;
  parameter WCLK_PERIOD = 5;  // 100 MHz
  parameter RCLK_PERIOD = 7;  // ~71 MHz

  logic wclk, rclk, wrst_n, rrst_n;

  // Clock generation
  always #(WCLK_PERIOD) wclk = ~wclk;
  always #(RCLK_PERIOD) rclk = ~rclk;

  // Reset generation
  initial begin
    wclk = 0;
    rclk = 0;
    wrst_n = 0;
    rrst_n = 0;
    #(WCLK_PERIOD*2) wrst_n = 1;
    #(RCLK_PERIOD*2) rrst_n = 1;
  end

  // Instantiate interface and test
  fifo_if vif(wclk, rclk, wrst_n, rrst_n);
  fifo_test t1(vif);

  // Instantiate DUV
  asynchronous_fifo #(
    .DATA_WIDTH(8),
    .DEPTH(8)
  ) dut (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .w_en(vif.w_en),
    .r_en(vif.r_en),
    .data_in(vif.data_in),
    .data_out(vif.data_out),
    .full(vif.full),
    .empty(vif.empty)
  );

endmodule