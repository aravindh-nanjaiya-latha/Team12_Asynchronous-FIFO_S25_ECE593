module test_bench;

  parameter int DATA_WIDTH = 8;
  parameter int DEPTH = 8;

  localparam int PTR_WIDTH = $clog2(DEPTH);

  logic wclk = 0, rclk = 0;
  logic wrst_n = 0, rrst_n = 0;
  logic w_en = 0, r_en = 0;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty;

  // Reference model queue
  logic [DATA_WIDTH-1:0] ref_q[$];
  logic [DATA_WIDTH-1:0] expected;
 int count =0;
  // Instantiate the FIFO
  asynchronous_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .wclk     (wclk),
    .wrst_n   (wrst_n),
    .rclk     (rclk),
    .rrst_n   (rrst_n),
    .w_en     (w_en),
    .r_en     (r_en),
    .data_in  (data_in),
    .data_out (data_out),
    .full     (full),
    .empty    (empty)
  );

  // Clocks
  always #5  wclk = ~wclk;  // 100 MHz
  always #7  rclk = ~rclk;  // ~71 MHz

 
  task automatic write();
    //int count = 0;
    while(!full) begin
      @(posedge wclk);
      w_en = 1;
      data_in = $urandom_range(0, 255);
      ref_q.push_back(data_in);
	@(posedge wclk);
	w_en = 0;
      $display(" Writing: %h (Queue size: %0d)", data_in, ref_q.size());
      count++;
	@(posedge wclk);
    end
    @(posedge wclk);
    //w_en = 0;
	//if(full)
    $display(" FIFO FULL after writing %0d elements", count);
  endtask


  task automatic read();
    int count = 0;
    while(!empty) begin
      @(posedge rclk);
      r_en = 1;
      @(posedge rclk);
      r_en = 0;
      expected = ref_q.pop_front();
      if (data_out !== expected)
        $error(" Mismatch: Expected %h, Got %h", expected, data_out);
      else
        $display(" Read: %h (Match)", data_out);
      count++;
	@(posedge rclk);
    end
	//@(posedge wclk);
    //r_en = 0;
    $display(" FIFO EMPTY after reading %0d elements", count);
  endtask

  // Reset sequence
  initial begin
    $display("********* Basic FIFO Functional Test  ***********");
  

    // Initialize
    wrst_n = 0;
    rrst_n = 0;
    w_en = 0;
    r_en = 0;

    // Release resets
    #20 wrst_n = 1;
    #30 rrst_n = 1;

    // Test sequence
    #50;
    write();
    #100;
    read();

    // Finish
    #50;
    $display(" Test Passed: FIFO Full & Empty behavior verified.");
    $stop;
  end

endmodule


