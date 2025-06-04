/*interface fifo_inf(input logic clk1, clk2);
  
  logic reset;						// reset signal
  logic rd_en, wr_en;         				// read and write signals
  logic full, empty; 		// Flags indicating FIFO status
  logic [7:0] din;         				// Data input
  logic [7:0] dout;        				// Data output             				
endinterface*/

interface fifo_inf(input logic wclk, rclk);
  logic wrst_n; // Write domain reset (active-low)
  logic rrst_n; // Read domain reset (active-low)
  logic wr_en, rd_en;
  logic full, empty, half_full;
  logic write_error, read_error;
  logic [7:0] din;
  logic [7:0] dout;

// Check: No write when FIFO is full
always @(posedge wclk) begin
  if (wrst_n && wr_en && full) begin
    $error("Attempted write when FIFO is full!");
  end
end

// Check: No read when FIFO is empty
always @(posedge rclk) begin
  if (rrst_n && rd_en && empty) begin
    $error("Attempted read when FIFO is empty!");
  end
end
endinterface


