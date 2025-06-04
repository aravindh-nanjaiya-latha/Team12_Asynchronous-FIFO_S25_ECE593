class environment extends uvm_env;
  `uvm_component_utils(environment)

  agent agt;
  scoreboard scr;

  function new(string name = "environment", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENVIRONMENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENVIRONMENT_CLASS", "Build Phase!", UVM_HIGH)
    agt = agent::type_id::create("agt", this);
    scr = scoreboard::type_id::create("scr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENVIRONMENT_CLASS", "Connect Phase!", UVM_HIGH)
    agt.mon.mon_analysis_port.connect(scr.scr_analysis_imp);
  endfunction
endclass
