class fifo_scoreboard;
  parameter DATA_WIDTH = 8;
  parameter DEPTH = 8;

  mailbox mon2scb;
  int no_trans;
  logic [DATA_WIDTH-1:0] ref_fifo[$]; // Reference queue
  int write_count, read_count;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
    this.no_trans = 0;
    this.write_count = 0;
    this.read_count = 0;
  endfunction

  task main();
    fifo_transaction trans;
    forever begin
      mon2scb.get(trans);
      no_trans++;

      // Write operation
      if (trans.w_en && !trans.full) begin
        ref_fifo.push_back(trans.data_in);
        write_count++;
        $display("Scoreboard: Write data=%h, FIFO size=%0d", trans.data_in, ref_fifo.size());
      end

      // Read operation
      if (trans.r_en && !trans.empty) begin
        logic [DATA_WIDTH-1:0] expected;
        if (ref_fifo.size() > 0) begin
          expected = ref_fifo.pop_front();
          read_count++;
          if (trans.data_out !== expected) begin
            $error("Scoreboard: Mismatch at read #%0d: Expected=%h, Got=%h", read_count, expected, trans.data_out);
          end else begin
            $display("Scoreboard: Read match at #%0d: data=%h", read_count, trans.data_out);
          end
        end
      end

      // Full/Empty checks
      if (trans.full) $display("Scoreboard: FIFO is full");
      if (trans.empty) $display("Scoreboard: FIFO is empty");

      if (no_trans >= 30) break; // Match trans_count
    end
  endtask
endclass