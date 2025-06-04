class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)

	uvm_analysis_imp#(transaction, scoreboard) scr_analysis_imp;


  function new (string path = "scoreboard", uvm_component parent);
    super.new(path, parent);
    `uvm_info("SCOREBOARD_CLASS", "Inside Constructor!",UVM_HIGH);
  endfunction : new

  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD_CLASS", "Build Phase!",UVM_HIGH);

    scr_analysis_imp = new("scr_analysis_imp", this);
  endfunction: build_phase
  
 
  virtual function void write(transaction tr);
      `uvm_info("SCO", "Txn Recieved",UVM_FULL);
  endfunction : write

endclass : scoreboard



