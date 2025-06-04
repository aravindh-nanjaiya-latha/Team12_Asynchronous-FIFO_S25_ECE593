class comprehensive_test extends uvm_test;
  `uvm_component_utils(comprehensive_test)

  environment env;
  rst_seq rst;
  wr_full_seq wr_full;
  rd_empty_seq rd_empty;
  random_seq random;

  function new(string name = "comprehensive_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)
    env = environment::type_id::create("env", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)
    phase.raise_objection(this);

    // Reset sequence
    rst = rst_seq::type_id::create("rst");
    rst.start(env.agt.sqr);
    #1000; // Increased delay for reset propagation

    // Write to full
    wr_full = wr_full_seq::type_id::create("wr_full");
    wr_full.start(env.agt.sqr);
    #1000; // Increased delay for synchronization

    // Read to empty
    rd_empty = rd_empty_seq::type_id::create("rd_empty");
    rd_empty.start(env.agt.sqr);
    #1000; // Increased delay for synchronization

    // Random operations
    random = random_seq::type_id::create("random");
    random.start(env.agt.sqr);

    #1000; // Final delay
    phase.drop_objection(this);
  endtask
endclass
