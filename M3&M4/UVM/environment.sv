class environment extends uvm_env;
	`uvm_component_utils(environment)

	agent agt;
	scoreboard scr;
	
	function new(string path = "environment", uvm_component parent);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agt = agent::type_id::create("agt",this);
		scr = scoreboard::type_id::create("scr",this);
	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		agt.mon.mon_analysis_port.connect(scr.scr_analysis_imp);

	endfunction: connect_phase

endclass: environment
		

