class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp#(transaction, scoreboard) scr_analysis_imp;
  logic [7:0] fifo_model[$]; // Queue to model FIFO behavior
  int write_count, read_count;

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCOREBOARD_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD_CLASS", "Build Phase!", UVM_HIGH)
    scr_analysis_imp = new("scr_analysis_imp", this);
    write_count = 0;
    read_count = 0;
  endfunction

  virtual function void write(transaction tr);
    $display("SCOREBOARD: wr_en=%0d rd_en=%0d data_in=0x%0h data_out=0x%0h full=%0d half_full = %0d empty=%0d write_error=%0d read_error=%0d write_count=%0d read_count=%0d",
             tr.wr_en, tr.rd_en, tr.din, tr.dout, tr.full, tr.half_full, tr.empty, tr.write_error, tr.read_error, write_count, read_count);
    if (!tr.wrst_n || !tr.rrst_n) begin
      fifo_model.delete();
      write_count = 0;
      read_count = 0;
      `uvm_info("SCOREBOARD_CLASS", "Reset: FIFO cleared", UVM_HIGH)
    end else if (tr.wr_en && !tr.write_error) begin
      if (write_count < 512) begin
        fifo_model.push_back(tr.din);
        write_count++;
        `uvm_info("SCOREBOARD_CLASS", $sformatf("Write: din=%h, FIFO size=%0d", tr.din, fifo_model.size()), UVM_HIGH)
      end
      if (tr.full && write_count == 512)
        `uvm_info("SCOREBOARD_CLASS", "FIFO Full: Correct", UVM_HIGH)
      else if (tr.full && write_count < 512)
        `uvm_error("SCOREBOARD_CLASS", $sformatf("FIFO Full prematurely at write_count=%0d", write_count))
    end else if (tr.rd_en && !tr.read_error) begin
      if (fifo_model.size() > 0) begin
        logic [7:0] expected = fifo_model.pop_front();
        read_count++;
        if (tr.dout == expected)
          `uvm_info("SCOREBOARD_CLASS", $sformatf("Read: dout=%h, Expected=%h, Match", tr.dout, expected), UVM_HIGH)
        else
          `uvm_error("SCOREBOARD_CLASS", $sformatf("Read: dout=%h, Expected=%h, Mismatch", tr.dout, expected))
      end
      if (tr.empty && fifo_model.size() == 0)
        `uvm_info("SCOREBOARD_CLASS", "FIFO Empty: Correct", UVM_HIGH)
      else if (tr.empty && fifo_model.size() > 0)
        `uvm_error("SCOREBOARD_CLASS", "FIFO Empty prematurely")
    end
    if (tr.write_error)
      `uvm_info("SCOREBOARD_CLASS", "Write Error Detected", UVM_HIGH)
    if (tr.read_error)
      `uvm_info("SCOREBOARD_CLASS", "Read Error Detected", UVM_HIGH)
  endfunction
endclass
