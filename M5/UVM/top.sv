import uvm_pkg::*;
`include "uvm_macros.svh"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "uvm_logging.sv"
`include "test.sv"

module top_testbench;
  logic wclk, rclk;

  fifo_inf fifo(.wclk(wclk), .rclk(rclk));

  asynchronous_fifo DUT (
    .wclk(fifo.wclk),
    .rclk(fifo.rclk),
    .wrst_n(fifo.wrst_n),
    .rrst_n(fifo.rrst_n),
    .w_en(fifo.wr_en),
    .r_en(fifo.rd_en),
    .data_in(fifo.din),
    .data_out(fifo.dout),
    .full(fifo.full),
    .empty(fifo.empty),
    .write_error(fifo.write_error),
    .read_error(fifo.read_error),
	.half_full(fifo.half_full)
  );

  initial begin
    uvm_config_db#(virtual fifo_inf)::set(null, "*", "fifo", fifo);
  end

  covergroup cvr;
    option.auto_bin_max = 10;
    option.per_instance = 1;

    wr: coverpoint fifo.wr_en {
      bins write_enabled = {1'b1};
      bins write_disabled = {1'b0};
    }
    rd: coverpoint fifo.rd_en {
      bins read_enabled = {1'b1};
      bins read_disabled = {1'b0};
    }
    din: coverpoint fifo.din {
      bins min = {8'h00};
      bins others = {[8'h01:8'hFE]};
      bins max = {8'hFF};
    }
    dout: coverpoint fifo.dout {
      bins min = {8'h00};
      bins others = {[8'h01:8'hFE]};
      bins max = {8'hFF};
    }
    full: coverpoint fifo.full {
      bins full_state = {1'b1};
      bins not_full_state = {1'b0};
    }
    empty: coverpoint fifo.empty {
      bins empty_state = {1'b1};
      bins not_empty_state = {1'b0};
    }
    half_full: coverpoint fifo.half_full {
      bins half_full_state = {1'b1};
      bins not_half_full_state = {1'b0};
    }
    write_error: coverpoint fifo.write_error {
      bins error = {1'b1};
      bins no_error = {1'b0};
    }
    read_error: coverpoint fifo.read_error {
      bins error = {1'b1};
      bins no_error = {1'b0};
    }
    cross wr, rd {
      bins wr_en_and_rd_en = binsof(wr.write_enabled) && binsof(rd.read_enabled);
      bins wr_en_and_not_rd_en = binsof(wr.write_enabled) && binsof(rd.read_disabled);
      bins not_wr_en_and_rd_en = binsof(wr.write_disabled) && binsof(rd.read_enabled);
      bins not_wr_en_and_not_rd_en = binsof(wr.write_disabled) && binsof(rd.read_disabled);
    }
    cross wr, full {
      bins wr_en_and_full = binsof(wr.write_enabled) && binsof(full.full_state);
      bins wr_en_and_not_full = binsof(wr.write_enabled) && binsof(full.not_full_state);
      bins not_wr_en_and_full = binsof(wr.write_disabled) && binsof(full.full_state);
      bins not_wr_en_and_not_full = binsof(wr.write_disabled) && binsof(full.not_full_state);
    }
    cross rd, empty {
      bins rd_en_and_empty = binsof(rd.read_enabled) && binsof(empty.empty_state);
      bins rd_en_and_not_empty = binsof(rd.read_enabled) && binsof(empty.not_empty_state);
      bins not_rd_en_and_empty = binsof(rd.read_disabled) && binsof(empty.empty_state);
      bins not_rd_en_and_not_empty = binsof(rd.read_disabled) && binsof(empty.not_empty_state);
    }
    cross wr, write_error {
      bins wr_en_and_error = binsof(wr.write_enabled) && binsof(write_error.error);
      bins wr_en_and_no_error = binsof(wr.write_enabled) && binsof(write_error.no_error);
    }
    cross rd, read_error {
      bins rd_en_and_error = binsof(rd.read_enabled) && binsof(read_error.error);
      bins rd_en_and_no_error = binsof(rd.read_enabled) && binsof(read_error.no_error);
    }
  endgroup

  cvr cv;

  initial begin : coverage
    cv = new();
    forever begin
      @(negedge fifo.wclk or negedge fifo.rclk);
      cv.sample();
    end
  end

  initial begin
    wclk = 0;
    rclk = 0;
  end

  always #1 wclk <= ~wclk; // 2ns period
  always #2.22 rclk <= ~rclk; // 4.44ns period

  initial begin
    run_test("comprehensive_test");
  end

  initial begin
    #20000; // Run long enough to cover all sequences
    $finish();
  end
endmodule