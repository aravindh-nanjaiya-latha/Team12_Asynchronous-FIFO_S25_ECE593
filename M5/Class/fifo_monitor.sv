class fifo_monitor;
  virtual fifo_if.MONITOR vif;
  mailbox mon2scb;

  function new(virtual fifo_if.MONITOR vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main();
    fifo_transaction trans;
    forever begin
      @(vif.monitor_cb);
      trans = new();
      trans.w_en = vif.monitor_cb.w_en;
      trans.r_en = vif.monitor_cb.r_en;
      trans.data_in = vif.monitor_cb.data_in;
      trans.data_out = vif.monitor_cb.data_out;
      trans.full = vif.monitor_cb.full;
      trans.empty = vif.monitor_cb.empty;
      mon2scb.put(trans);
      trans.display("Monitor");
    end
  endtask
endclass