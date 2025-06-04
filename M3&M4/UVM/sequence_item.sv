class transaction extends uvm_sequence_item;
	`uvm_object_utils(transaction)

	parameter WIDTH = 64;
	rand bit sel;
	rand bit reset;
	rand bit wr_en,rd_en;
	rand logic [WIDTH-1:0]din;

	logic [WIDTH-1:0]dout;
	logic full,empty,almost_full,almost_empty;	
	
	//constraint select {  sel dist {1:=80, 0:=20};  }

	function new (string path = "transaction");
		super.new(path);
	endfunction

endclass: transaction

