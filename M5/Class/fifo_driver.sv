class fifo_driver;
  virtual fifo_if.DRIVER vif;
  mailbox gen2drv;
  event drv2gen;
  int no_trans;

  function new(virtual fifo_if.DRIVER vif, mailbox gen2drv, event drv2gen);
    this.vif = vif;
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.no_trans = 0;
  endfunction

  task reset();
    $display("Driver: Reset Initiated");
    wait (!vif.wrst_n || !vif.rrst_n);
    vif.driver_cb.w_en <= 0;
    vif.driver_cb.data_in <= 0;
    vif.driver_cb_rd.r_en <= 0;
    wait (vif.wrst_n && vif.rrst_n);
    $display("Driver: Reset Complete");
  endtask

  task drive();
    fifo_transaction trans;
    gen2drv.get(trans);
    no_trans++;

    // Write operation
    if (trans.w_en && !vif.driver_cb.full) begin
      @(vif.driver_cb);
      vif.driver_cb.data_in <= trans.data_in;
      vif.driver_cb.w_en <= 1;
      @(vif.driver_cb);
      vif.driver_cb.w_en <= 0;
      trans.display("Driver [Write]");
    end

    // Read operation
    if (trans.r_en && !vif.driver_cb_rd.empty) begin
      @(vif.driver_cb_rd);
      vif.driver_cb_rd.r_en <= 1;
      @(vif.driver_cb_rd);
      vif.driver_cb_rd.r_en <= 0;
      trans.display("Driver [Read]");
    end

    if (!trans.w_en && !trans.r_en) begin
      @(vif.driver_cb);
      trans.display("Driver [Idle]");
    end
  endtask

  task main();
    forever begin
      drive();
      if (no_trans >= 30) begin // Match trans_count
        ->drv2gen;
        break;
      end
    end
  endtask
endclass