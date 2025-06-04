class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)

  virtual fifo_inf fifo;
  transaction tr;

  function new(string name = "driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    if (!uvm_config_db#(virtual fifo_inf)::get(this, "*", "fifo", fifo))
      `uvm_fatal("DRIVER", "Failed to get FIFO interface")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("DRIVER_CLASS", "Run Phase!", UVM_HIGH)
    initialize();
    forever begin
      tr = transaction::type_id::create("tr");
      seq_item_port.get_next_item(tr);
      drive_transaction(tr);
      seq_item_port.item_done();
    end
  endtask

  virtual task initialize();
    fifo.wrst_n <= 0;
    fifo.rrst_n <= 0;
    fifo.wr_en <= 0;
    fifo.rd_en <= 0;
    fifo.din <= 0;
    repeat(2) @(negedge fifo.wclk);
    repeat(2) @(negedge fifo.rclk);
    fifo.wrst_n <= 1;
    fifo.rrst_n <= 1;
    `uvm_info("DRIVER_CLASS", "Initialization Complete", UVM_HIGH)
  endtask

  virtual task drive_transaction(transaction tr);
    if (tr.wrst_n == 0 || tr.rrst_n == 0) begin
      @(negedge fifo.wclk);
      fifo.wrst_n <= tr.wrst_n;
      fifo.rrst_n <= tr.rrst_n;
      fifo.wr_en <= 0;
      fifo.rd_en <= 0;
      fifo.din <= 0;
      `uvm_info("DRIVER_CLASS", "Reset Applied", UVM_HIGH)
    end else if (tr.wr_en) begin
      @(negedge fifo.wclk);
      fifo.wrst_n <= 1;
      fifo.rrst_n <= 1;
      fifo.wr_en <= 1;
      fifo.rd_en <= 0;
      fifo.din <= tr.din;
      `uvm_info("DRIVER_CLASS", $sformatf("Write: din=%h", tr.din), UVM_HIGH)
      @(negedge fifo.wclk);
      fifo.wr_en <= 0;
      fifo.din <= 0;
    end else if (tr.rd_en) begin
      @(negedge fifo.rclk);
      fifo.wrst_n <= 1;
      fifo.rrst_n <= 1;
      fifo.wr_en <= 0;
      fifo.rd_en <= 1;
      `uvm_info("DRIVER_CLASS", "Read", UVM_HIGH)
      @(negedge fifo.rclk);
      fifo.rd_en <= 0;
    end
  endtask
endclass

