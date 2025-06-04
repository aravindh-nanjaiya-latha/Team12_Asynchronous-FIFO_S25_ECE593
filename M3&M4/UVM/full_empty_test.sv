class test extends uvm_test;
	`uvm_component_utils(test)

	environment env;
	full_empty_seq seq;

	function new(string path = "test", uvm_component parent);
		super.new(path, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env = environment::type_id::create("env",  this);

	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	
	endfunction: connect_phase

	virtual function void end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);

	uvm_top.print_topology();

	endfunction : end_of_elaboration_phase

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
			
		phase.raise_objection(this);
		
		seq = full_empty_seq::type_id::create("seq");
	        seq.start(env.agt.sqr);
		
		phase.drop_objection(this);
	endtask: run_phase

endclass: test	


