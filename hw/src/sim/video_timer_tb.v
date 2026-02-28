`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:40:57 AM
// Design Name: 
// Module Name: video_timer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module video_timer_tb;

  // ---- 720p60 timing constants ----
  localparam integer H_ACTIVE = 1280;
  localparam integer H_FP     = 110;
  localparam integer H_SYNC   = 40;
  localparam integer H_BP     = 220;
  localparam integer H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP; // 1650

  localparam integer V_ACTIVE = 720;
  localparam integer V_FP     = 5;
  localparam integer V_SYNC   = 5;
  localparam integer V_BP     = 20;
  localparam integer V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP; // 750

  // ---- Clock: 74.25 MHz (T = 13.468 ns) ----
  reg clk = 1'b0;
  localparam real T_PIX_NS = 13.468;
  always #(T_PIX_NS/2.0) clk = ~clk;

  // ---- Reset ----
  reg rst = 1'b1;

  // ---- DUT I/O ----
  wire [10:0] x;
  wire [9:0]  y;
  wire        de, hsync, vsync;

  // ==== DUT INSTANTIATION ====
  // Adjust instance/port names if your module differs.
  video_timer dut (
    .clk_pix(clk),
    .rst    (rst),
    .counterX(x),
    .counterY(y),
    .de     (de),
    .hsync  (hsync),
    .vsync  (vsync)
  );

  // ---- Bookkeeping for checks ----
  integer frame_count = 0;
  integer de_count_line = 0;
  integer de_count_frame = 0;

  // Edge tracking
  reg [10:0] x_d;
  reg [9:0]  y_d;

// Verilog-2001 compatible "check" task
task check;
  input cond;                 // plain 1-bit input (no 'bit' keyword)
  input [1023:0] msg;         // packed ASCII string
  begin
    if (!cond) begin
      $display("[%0t ns] CHECK FAILED: %s", $time, msg);
      $stop;                  // or $finish; (use $fatal only if your sim supports SV)
    end
  end
endtask


  // ---- Stimulus & main process ----
  initial begin
    // Hold reset for a few cycles
    repeat (20) @(posedge clk);
    rst = 1'b0;

    // Run until 2 frames observed
    wait (!rst);
    while (frame_count < 2) @(posedge clk);

    $display("All checks passed for %0d frames. ✅", frame_count);
    $finish;
  end

  // ---- Cycle-by-cycle checks ----
  always @(posedge clk) begin
    if (rst) begin
      x_d <= 0; y_d <= 0;
      de_count_line  <= 0;
      de_count_frame <= 0;
    end else begin
      // Basic ranges
      check(x < H_TOTAL, "x out of range");
      check(y < V_TOTAL, "y out of range");

      // X wrap behaviour
      if (x_d == H_TOTAL-1) begin
        check(x == 0, "x did not wrap to 0 at end of line");
        if (y_d < V_TOTAL-1)
          check(y == y_d + 1, "y did not increment at x wrap");
        else
          check(y == 0, "y did not wrap to 0 at frame end");
      end

      // de truth table
      check(de == ((x < H_ACTIVE) && (y < V_ACTIVE)), "de mismatch to active window");

      // Count visible pixels per line / frame
      if (de) begin
        de_count_line  <= de_count_line + 1;
        de_count_frame <= de_count_frame + 1;
      end

      // End of line: verify de count and reset line counter
      if (x == H_TOTAL-1) begin
        if (y < V_ACTIVE)
          check(de_count_line == H_ACTIVE, "visible pixels per active line != 1280");
        else
          check(de_count_line == 0, "non-active line had de pixels");
        de_count_line <= 0;
      end

      // HSync window (positive polarity): x in [H_ACTIVE+H_FP, H_ACTIVE+H_FP+H_SYNC)
      if ( (x >= H_ACTIVE + H_FP) && (x < H_ACTIVE + H_FP + H_SYNC) )
        check(hsync == 1'b1, "hsync not high inside pulse window");
      else
        check(hsync == 1'b0, "hsync high outside pulse window");

      // VSync window (positive), in lines [V_ACTIVE+V_FP, V_ACTIVE+V_FP+V_SYNC)
      if ( (y >= V_ACTIVE + V_FP) && (y < V_ACTIVE + V_FP + V_SYNC) )
        check(vsync == 1'b1, "vsync not high inside pulse window");
      else
        check(vsync == 1'b0, "vsync high outside pulse window");

      // End of frame: verify total visible pixels and bump frame counter
      if (x == H_TOTAL-1 && y == V_TOTAL-1) begin
        check(de_count_frame == (H_ACTIVE * V_ACTIVE), "visible pixels per frame != 1280*720");
        de_count_frame <= 0;
        frame_count <= frame_count + 1;
        $display("[%0t ns] Frame %0d complete", $time, frame_count);
      end

      // delay registers
      x_d <= x; y_d <= y;
    end
  end

endmodule
