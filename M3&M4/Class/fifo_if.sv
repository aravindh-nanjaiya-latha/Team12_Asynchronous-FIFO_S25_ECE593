interface fifo_if (
  input logic wclk,
  input logic rclk,
  input logic wrst_n,
  input logic rrst_n
);

  parameter int DATA_WIDTH = 8;

  // Inputs to DUV
  logic [DATA_WIDTH-1:0] data_in;
  logic w_en;
  logic r_en;

  // Outputs from DUV
  logic [DATA_WIDTH-1:0] data_out;
  logic full;
  logic empty;

  // Clocking block for Driver (write domain)
  clocking driver_cb @(posedge wclk);
    output data_in, w_en;
    input full;
  endclocking

  // Clocking block for Driver (read domain)
  clocking driver_cb_rd @(posedge rclk);
    output r_en;
    input empty;
  endclocking

  // Clocking block for Monitor (read domain)
  clocking monitor_cb @(posedge rclk);
    input data_out, full, empty, r_en, w_en, data_in;
  endclocking

  modport DRIVER (
    clocking driver_cb,
    clocking driver_cb_rd,
    input wclk, rclk, wrst_n, rrst_n
  );

  modport MONITOR (
    clocking monitor_cb,
    input wclk, rclk, wrst_n, rrst_n
  );

endinterface