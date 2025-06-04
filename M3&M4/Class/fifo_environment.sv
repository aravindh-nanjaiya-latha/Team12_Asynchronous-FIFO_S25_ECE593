class fifo_environment;
  fifo_generator gen;
  fifo_driver drv;
  fifo_monitor mon;
  fifo_scoreboard scb;

  mailbox gen2drv;
  mailbox mon2scb;
  event drv2gen;

  virtual fifo_if vif;

  function new(virtual fifo_if vif);
    this.vif = vif;
    gen2drv = new();
    mon2scb = new();
    gen = new(gen2drv, drv2gen);
    drv = new(vif, gen2drv, drv2gen);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
  endfunction

  task pre_env();
    drv.reset();
  endtask

  task test();
    $display("Environment: Starting test with %0d transactions", gen.trans_count);
    fork
      gen.main();
      drv.main();
      mon.main();
      scb.main();
    join_none
  endtask

  task post_env();
    $display("Environment: Post-test");
    wait (drv2gen.triggered);
    wait (gen.trans_count == drv.no_trans);
    wait (gen.trans_count == scb.no_trans);
  endtask

  task run();
    pre_env();
    test();
    post_env();
  endtask
endclass