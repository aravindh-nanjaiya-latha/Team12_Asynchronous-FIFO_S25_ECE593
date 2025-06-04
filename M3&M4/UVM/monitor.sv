class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)

	virtual fifo_inf fifo;
	transaction tr;

	uvm_analysis_port#(transaction) mon_analysis_port;

	function new (string path = "monitor", uvm_component parent = null);
		super.new(path, parent);
		`uvm_info("MONITOR_CLASS", "Inside Constructor!",UVM_HIGH);
	endfunction: new

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("MONITOR_CLASS", "Build Phase!",UVM_HIGH);

		mon_analysis_port = new("mon_analysis_port", this);

		if(!uvm_config_db #(virtual fifo_inf) :: get(this, "*", "fifo", fifo))begin
			`uvm_error(get_type_name(), "DUT interface not found");
		end
		
	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("MONITOR_CLASS", "Connect phase!",UVM_HIGH);

	endfunction: connect_phase

	virtual task run_phase(uvm_phase phase);
	super.run_phase(phase);
	`uvm_info("MONITOR_CLASS", "Run Phase!",UVM_HIGH);

	forever begin
	tr = transaction::type_id::create("tr");
	
	#1;

	@(posedge fifo.clk1);
     	tr.wr_en = fifo.wr_en;
     	tr.rd_en = fifo.rd_en;
	tr.din = fifo.din;

	@(posedge fifo.clk2);
      	tr.full = fifo.full;
      	tr.empty = fifo.empty; 
	tr.almost_full = fifo.almost_full;
 	tr.almost_empty = fifo.almost_empty;
	tr.dout = fifo.dout;

	mon_analysis_port.write(tr);
	end
	endtask: run_phase

endclass : monitor





