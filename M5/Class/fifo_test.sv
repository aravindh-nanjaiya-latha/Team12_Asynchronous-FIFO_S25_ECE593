import fifo_pkg::*;

program fifo_test(fifo_if vif);
  fifo_environment env;

  initial begin
    $display("Test: Starting environment");
    env = new(vif);
    env.gen.trans_count = 30; // Number of transactions
    env.run();
    $display("Test: Finished");
    $finish;
  end
endprogram