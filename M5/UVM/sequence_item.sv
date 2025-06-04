
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  rand bit wr_en, rd_en;
  rand bit wrst_n, rrst_n;
  rand logic [7:0] din;
  logic [7:0] dout;
  bit full, empty, half_full;
  bit write_error, read_error;

  // Constraints for valid FIFO operations
  constraint valid_ops { 
    // Prevent simultaneous write and read in random tests
    !(wr_en == 1 && rd_en == 1);
    // Reset constraints
    if (wrst_n == 0 || rrst_n == 0) { wr_en == 0; rd_en == 0; }
  }

  function new(string name = "transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("wrst_n=%b, rrst_n=%b, wr_en=%b, rd_en=%b, din=%h, dout=%h, full=%b, empty=%b, write_error=%b, read_error=%b",
                     wrst_n, rrst_n, wr_en, rd_en, din, dout, full, empty, write_error, read_error);
  endfunction
endclass

