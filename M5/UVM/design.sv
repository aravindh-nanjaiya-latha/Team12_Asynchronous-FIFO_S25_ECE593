module asynchronous_fifo #(
    parameter DEPTH = 512,
    parameter DATA_WIDTH = 8,
    parameter PTR_WIDTH = 9
) (
    input wclk, wrst_n,
    input rclk, rrst_n,
    input w_en, r_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full, empty, write_error, read_error,half_full
);
    reg [PTR_WIDTH-1:0] g_wptr_sync, g_rptr_sync;
    reg [PTR_WIDTH-1:0] b_wptr, b_rptr;
    reg [PTR_WIDTH-1:0] g_wptr, g_rptr;

    synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync);
    synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync);
    wptr_handler #(PTR_WIDTH) wptr_h (wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full, half_full);
    rptr_handler #(PTR_WIDTH) rptr_h (rclk, rrst_n, r_en, g_wptr_sync, b_rptr, g_rptr, empty);
    fifo_mem #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifom (
        .wclk(wclk), .wrst_n(wrst_n), .w_en(w_en),
        .rclk(rclk), .rrst_n(rrst_n), .r_en(r_en),
        .b_wptr(b_wptr), .b_rptr(b_rptr), .data_in(data_in),
        .full(full), .empty(empty), .data_out(data_out),
        .write_error(write_error), .read_error(read_error)
    );

endmodule

module wptr_handler #(
    parameter PTR_WIDTH = 9,
	parameter DEPTH = 512
) (
    input wclk, wrst_n, w_en,
    input [PTR_WIDTH-1:0] g_rptr_sync,
    output reg [PTR_WIDTH-1:0] b_wptr, g_wptr,
    output reg full,half_full
);
    reg [PTR_WIDTH-1:0] b_wptr_next;
    reg [PTR_WIDTH-1:0] g_wptr_next;
    wire wfull;
    wire whalf_full;
    reg [PTR_WIDTH-1:0] b_rptr_sync;

    // Convert synchronized Gray code read pointer to binary
    always @(*) begin
        b_rptr_sync = g_rptr_sync ^ (g_rptr_sync >> 1); // Gray to binary conversion
    end
    
    assign b_wptr_next = b_wptr + (w_en & ~full);
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
    
    // Update binary and gray pointers
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= 0;
            g_wptr <= 0;
        end else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end
    
    // Update full condition
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)begin full <= 0; half_full <= 0; end
        else begin full <= wfull; half_full <= whalf_full; end
    end
    
    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});
	// Half-full condition: Check if FIFO occupancy is greater than or equal to DEPTH/2
    assign whalf_full = ((b_wptr_next - b_rptr_sync) >= (DEPTH/2));
    //assign wfull = ((b_wptr_next - b_rptr_sync) == DEPTH);
endmodule

module rptr_handler #(
    parameter PTR_WIDTH = 9
) (
    input rclk, rrst_n, r_en,
    input [PTR_WIDTH-1:0] g_wptr_sync,
    output reg [PTR_WIDTH-1:0] b_rptr, g_rptr,
    output reg empty
);
    reg [PTR_WIDTH-1:0] b_rptr_next;
    reg [PTR_WIDTH-1:0] g_rptr_next;
    wire rempty;
    
    assign b_rptr_next = b_rptr + (r_en & ~empty);  //~empty
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    assign rempty = (g_wptr_sync == g_rptr_next);
    
    // Update pointers
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end
    
    // Update empty condition
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) empty <= 1;
        else empty <= rempty;
    end
endmodule

module synchronizer #(
    parameter WIDTH = 9
) (
    input clk, rst_n,
    input [WIDTH-1:0] d_in,
    output reg [WIDTH-1:0] d_out
);
    reg [WIDTH-1:0] q1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            d_out <= 0;
        end else begin
            q1 <= d_in;
            d_out <= q1;
        end
    end
endmodule

module fifo_mem #(
    parameter DEPTH = 512,
    parameter DATA_WIDTH = 8,
    parameter PTR_WIDTH = 9
) (
    input wclk, wrst_n, w_en, rclk, rrst_n, r_en,
    input [PTR_WIDTH-1:0] b_wptr, b_rptr,
    input [DATA_WIDTH-1:0] data_in,
    input full, empty,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg write_error, read_error
);
    reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];
    
    // Write block
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            write_error <= 0;
        end else begin
            write_error <= 0;
            if (w_en) begin
                if (full) begin
                    write_error <= 1;
                end else begin
                    fifo[b_wptr] <= data_in;
                end
            end
        end
    end
    
    // Read block
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            read_error <= 0;
            data_out <= 0;
        end else begin
            read_error <= 0;
            if (r_en) begin
                if (empty) begin
                    read_error <= 1;
                end else begin
                    data_out <= fifo[b_rptr];
                end
            end
        end
    end
endmodule
