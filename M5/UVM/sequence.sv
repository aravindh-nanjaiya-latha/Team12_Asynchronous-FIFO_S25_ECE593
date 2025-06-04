class rst_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(rst_seq)
  transaction rst_txn;

  function new(string name = "rst_seq");
    super.new(name);
    `uvm_info("RESET_SEQUENCE", "Inside Constructor!", UVM_HIGH)
  endfunction

  task body();
    `uvm_info("RESET_SEQUENCE", "Inside Body Task!", UVM_HIGH)
    rst_txn = transaction::type_id::create("rst_txn");
    start_item(rst_txn);
    assert(rst_txn.randomize() with { wrst_n == 0; rrst_n == 0; wr_en == 0; rd_en == 0; });
    `uvm_info("RESET_SEQUENCE", "RESET FIFO!", UVM_HIGH)
    finish_item(rst_txn);
  endtask
endclass

class wr_full_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(wr_full_seq)
  transaction txn;

  function new(string name = "wr_full_seq");
    super.new(name);
    `uvm_info("WR_FULL_SEQUENCE", "Inside Constructor!", UVM_HIGH)
  endfunction

  task body();
    `uvm_info("WR_FULL_SEQUENCE", "Inside Body Task!", UVM_HIGH)
    repeat(512) begin
      txn = transaction::type_id::create("txn");
      start_item(txn);
      assert(txn.randomize() with { wrst_n == 1; rrst_n == 1; wr_en == 1; rd_en == 0; });
      `uvm_info("WR_FULL_SEQUENCE", $sformatf("WRITING DATA: %s", txn.convert2string()), UVM_HIGH)
      finish_item(txn);
    end
    // Test write to full FIFO
    txn = transaction::type_id::create("txn");
    start_item(txn);
    assert(txn.randomize() with { wrst_n == 1; rrst_n == 1; wr_en == 1; rd_en == 0; });
    `uvm_info("WR_FULL_SEQUENCE", "WRITING TO FULL FIFO", UVM_HIGH)
    finish_item(txn);
  endtask
endclass

class rd_empty_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(rd_empty_seq)
  transaction txn;

  function new(string name = "rd_empty_seq");
    super.new(name);
    `uvm_info("RD_EMPTY_SEQUENCE", "Inside Constructor!", UVM_HIGH)
  endfunction

  task body();
    `uvm_info("RD_EMPTY_SEQUENCE", "Inside Body Task!", UVM_HIGH)
    repeat(512) begin
      txn = transaction::type_id::create("txn");
      start_item(txn);
      assert(txn.randomize() with { wrst_n == 1; rrst_n == 1; wr_en == 0; rd_en == 1; });
      `uvm_info("RD_EMPTY_SEQUENCE", $sformatf("READING DATA: %s", txn.convert2string()), UVM_HIGH)
      finish_item(txn);
    end
    // Test read from empty FIFO
    txn = transaction::type_id::create("txn");
    start_item(txn);
    assert(txn.randomize() with { wrst_n == 1; rrst_n == 1; wr_en == 0; rd_en == 1; });
    `uvm_info("RD_EMPTY_SEQUENCE", "READING FROM EMPTY FIFO", UVM_HIGH)
    finish_item(txn);
  endtask
endclass

class random_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(random_seq)
  transaction txn;

  function new(string name = "random_seq");
    super.new(name);
    `uvm_info("RANDOM_SEQUENCE", "Inside Constructor!", UVM_HIGH)
  endfunction

  task body();
    `uvm_info("RANDOM_SEQUENCE", "Inside Body Task!", UVM_HIGH)
    repeat(1000) begin
      txn = transaction::type_id::create("txn");
      start_item(txn);
      assert(txn.randomize() with { wrst_n == 1; rrst_n == 1; });
      `uvm_info("RANDOM_SEQUENCE", $sformatf("RANDOM OPERATION: %s", txn.convert2string()), UVM_HIGH)
      finish_item(txn);
    end
  endtask
endclass
