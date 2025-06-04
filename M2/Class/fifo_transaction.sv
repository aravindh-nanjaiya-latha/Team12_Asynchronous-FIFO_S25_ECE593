class fifo_transaction;
  parameter DATA_WIDTH = 8;

  // Inputs (randomized)
  rand bit [DATA_WIDTH-1:0] data_in;
  rand bit w_en;
  rand bit r_en;

  // Outputs (captured)
  bit [DATA_WIDTH-1:0] data_out;
  bit full;
  bit empty;

  // Constraints
  constraint valid_ops {
    // Ensure either write or read (or neither), but not both
    (w_en == 1 && r_en == 0) || (w_en == 0 && r_en == 1) || (w_en == 0 && r_en == 0);
  }

  function void display(string prefix = "");
    $display("%s Transaction: w_en=%b, r_en=%b, data_in=%h, data_out=%h, full=%b, empty=%b",
             prefix, w_en, r_en, data_in, data_out, full, empty);
  endfunction
endclass