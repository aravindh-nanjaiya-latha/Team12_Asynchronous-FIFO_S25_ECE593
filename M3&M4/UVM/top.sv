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
`include "full_empty_test.sv"

module top_tb;

logic clk1,clk2;

fifo_inf fifo(.clk1(clk1),.clk2(clk2));

asynchronous_fifo DUT (.clk1(fifo.clk1),
			.clk2(fifo.clk2),
			.reset(fifo.reset),
			.wr_en(fifo.wr_en),
			.rd_en(fifo.rd_en),
			.din(fifo.din),
			.dout(fifo.dout),
			.full(fifo.full),
			.empty(fifo.empty),
			.almost_full(fifo.almost_full),
			.almost_empty(fifo.almost_empty));

	initial begin
		uvm_config_db#(virtual fifo_inf)::set(null, "*", "fifo", fifo);
	end

	
covergroup cvr;
option.auto_bin_max = 10;
option.per_instance = 1;
  
  // Coverpoint for write operation
  wr:coverpoint fifo.wr_en {
    bins write_enabled = {1'b1};
    bins write_disabled = {1'b0};
  }
  // Coverpoint for read operation
  rd:coverpoint fifo.rd_en {
    bins read_enabled = {1'b1};
    bins read_disabled = {1'b0};
  }
  // Coverpoint for data input
  din:coverpoint fifo.din {
         bins min = {'h0000000000000000};
         bins others = {['h0000000000000001:'hFFFFFFFFFFFFFFFE]};
         bins max  = {'hFFFFFFFFFFFFFFFF};
  }
  // Coverpoint for data output
  dout:coverpoint fifo.dout {
		 bins min = {'h0000000000000000};
         bins others = {['h0000000000000001:'hFFFFFFFFFFFFFFFE]};
         bins max  = {'hFFFFFFFFFFFFFFFF};
  }
  // Coverpoints for FIFO states
  full:coverpoint fifo.full {
    bins full_state = {1'b1};
    bins not_full_state = {1'b0};
  }
  empty:coverpoint fifo.empty {
    bins empty_state = {1'b1};
    bins not_empty_state = {1'b0};
  }
  almost_full:coverpoint fifo.almost_full {
    bins almost_full_state = {1'b1};
    bins not_almost_full_state = {1'b0};
  }
  almost_empty:coverpoint fifo.almost_empty {
    bins almost_empty_state = {1'b1};
    bins not_almost_empty_state = {1'b0};
  }
  // Cross coverage between wr_en and rd_en
  cross wr,rd {
    bins wr_en_and_rd_en = binsof (wr.write_enabled) && binsof (rd.read_enabled);
    bins wr_en_and_not_rd_en = binsof (wr.write_enabled) && binsof (rd.read_disabled);
    bins not_wr_en_and_rd_en = binsof (wr.write_disabled) && binsof (rd.read_enabled);
    bins not_wr_en_and_not_rd_en = binsof (wr.write_disabled) && binsof (rd.read_disabled);
  }
  // Cross coverage between wr_en and full state
  cross wr,full {
    bins wr_en_and_full = binsof (wr.write_enabled) && binsof (full.full_state);
    bins wr_en_and_not_full = binsof (wr.write_enabled) && binsof (full.not_full_state);
    bins not_wr_en_and_full = binsof (wr.write_disabled) && binsof (full.full_state);
    bins not_wr_en_and_not_full = binsof (wr.write_disabled) && binsof (full.not_full_state);
  }
  // Cross coverage between rd_en and empty state
  cross rd,empty {
    bins rd_en_and_empty = binsof (rd.read_enabled) && binsof (empty.empty_state);
    bins rd_en_and_not_empty = binsof (rd.read_enabled) && binsof (empty.not_empty_state);
    bins not_rd_en_and_empty = binsof (rd.read_disabled) && binsof (empty.empty_state);
    bins not_rd_en_and_not_empty = binsof (rd.read_disabled) && binsof (empty.not_empty_state);
  }
endgroup

	cvr cv;
   
  	 initial begin : coverage
   
      		cv = new();
     
      		forever begin @(negedge fifo.clk1);
         	cv.sample();
        	 end
	 end : coverage
   

	initial begin
		run_test("test");
	end

	initial begin
		clk1 = 0;
		clk2 = 0;
	end	

	always #1 clk1 <= ~clk1;
	always #2.22 clk2 <= ~clk2;

	initial begin
		#19000;
		$finish();
	end

endmodule
