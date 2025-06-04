class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual fifo_inf fifo;
  transaction tr;
  uvm_analysis_port#(transaction) mon_analysis_port;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
    mon_analysis_port = new("mon_analysis_port", this);
    if (!uvm_config_db#(virtual fifo_inf)::get(this, "*", "fifo", fifo))
      `uvm_fatal("MONITOR", "Failed to get FIFO interface")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR_CLASS", "Run Phase!", UVM_HIGH)
    fork
      // Monitor write clock domain
      forever begin
        @(posedge fifo.wclk);
        tr = transaction::type_id::create("tr");
        tr.wrst_n = fifo.wrst_n;
        tr.wr_en = fifo.wr_en;
        tr.din = fifo.din;
        tr.full = fifo.full;
	tr.half_full = fifo.half_full;
        tr.write_error = fifo.write_error;
        if (tr.wr_en && !tr.write_error) begin
          mon_analysis_port.write(tr);
          `uvm_info("MONITOR_CLASS", $sformatf("Write Monitored: %s", tr.convert2string()), UVM_HIGH)
        end
      end
      // Monitor read clock domain
      forever begin
        @(posedge fifo.rclk);
        tr = transaction::type_id::create("tr");
        tr.rrst_n = fifo.rrst_n;
        tr.rd_en = fifo.rd_en;
        tr.dout = fifo.dout;
        tr.empty = fifo.empty;
        tr.read_error = fifo.read_error;
        if (tr.rd_en && !tr.read_error) begin
          mon_analysis_port.write(tr);
          `uvm_info("MONITOR_CLASS", $sformatf("Read Monitored: %s", tr.convert2string()), UVM_HIGH)
        end
      end
    join
  endtask
endclass


