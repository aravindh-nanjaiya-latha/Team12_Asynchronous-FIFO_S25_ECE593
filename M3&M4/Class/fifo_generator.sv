class fifo_generator;
  mailbox gen2drv;
  event drv2gen;
  int trans_count;

  function new(mailbox gen2drv, event drv2gen, int trans_count = 30);
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.trans_count = trans_count;
  endfunction

  task main();
    fifo_transaction trans;
    repeat (trans_count) begin
      trans = new();
      if (!trans.randomize()) $fatal("Transaction randomization failed");
      gen2drv.put(trans);
      trans.display("Generator");
      @(posedge $root.async_fifo_top.wclk); // Synchronize with clock
    end
    ->drv2gen;
  endtask
endclass