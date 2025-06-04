module write_pointer_handler #(parameter int PTR_WIDTH = 3) (
  input  logic                    wclk,
  input  logic                    wrst_n,
  input  logic                    w_en,
  input  logic [PTR_WIDTH:0]      g_rptr_sync,
  output logic [PTR_WIDTH:0]      b_wptr,
  output logic [PTR_WIDTH:0]      g_wptr,
  output logic                    full
);

  logic [PTR_WIDTH:0] b_wptr_next;
  logic [PTR_WIDTH:0] g_wptr_next;
  logic               wfull;
  logic half_fulled;

  // Calculate next binary and gray write pointers
  assign b_wptr_next = b_wptr + (w_en & !full);
  assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

  // Sequential logic for updating write pointers
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      b_wptr <= '0;
      g_wptr <= '0;
    end else begin
      b_wptr <= b_wptr_next;
      g_wptr <= g_wptr_next;
    end
  end

  // Sequential logic for setting full flag
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      full <= 1'b0;
    else
      full <= wfull;
  end

  // Full condition detection logic
  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule


