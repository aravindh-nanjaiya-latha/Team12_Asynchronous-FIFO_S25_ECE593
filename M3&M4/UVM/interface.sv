interface fifo_inf(input logic clk1, clk2);
  
  logic reset;						// reset signal
  logic rd_en, wr_en;         				// read and write signals
  logic full, empty,almost_full,almost_empty; 		// Flags indicating FIFO status
  logic [63:0] din;         				// Data input
  logic [63:0] dout;        				// Data output             				
endinterface

