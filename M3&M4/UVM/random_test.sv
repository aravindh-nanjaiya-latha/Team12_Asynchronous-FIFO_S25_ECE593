class random_test extends uvm_test;
	`uvm_component_utils(random_test)

	environment env;
	random_seq random;

	function new(string path = "random_test", uvm_component parent);
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
		
		random = random_seq::type_id::create("random");
	        random.start(env.agt.sqr);
		
		phase.drop_objection(this);
	endtask: run_phase

endclass: random_test	

