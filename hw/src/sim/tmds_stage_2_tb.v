`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 07:42:55 AM
// Design Name: 
// Module Name: tmds_stage_2_tb
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

module tmds_stage_2_tb;
  reg  [8:0]        q_m;
  reg  signed [5:0] rd_in;
  wire [9:0]        tmds_out;
  wire signed [5:0] rd_out;

  tmds_stage_2 dut (
    .q_m(q_m),
    .rd_in(rd_in),
    .tmds_out(tmds_out),
    .rd_out(rd_out)
  );

  // Local popcount for reference model
  function [3:0] pop8(input [7:0] x);
    integer i;
    begin
      pop8 = 0;
      for (i = 0; i < 8; i = i + 1)
        pop8 = pop8 + x[i];
    end
  endfunction

  // Golden model for stage 2 (same as canonical TMDS and your new RTL)
  task ref_stage2 (
    input  [8:0] qmi,
    input  integer rd_prev,
    output [9:0] tmds_ref,
    output integer rd_next
  );
    integer N1_q, N0_q;
    integer diff8;
    reg use_inv;
  begin
    N1_q  = pop8(qmi[7:0]);
    N0_q  = 8 - N1_q;
    diff8 = N1_q - N0_q;  // signed

    // Default
    tmds_ref = 10'b0;
    rd_next  = rd_prev;

    // Case 1: rd == 0 OR ones == zeros (balanced case)
    if ((rd_prev == 0) || (N1_q == N0_q)) begin
      tmds_ref[9] = ~qmi[8];
      tmds_ref[8] =  qmi[8];

      if (qmi[8]) begin
        // send q_m as-is
        tmds_ref[7:0] = qmi[7:0];
        rd_next       = rd_prev + diff8;      // + (N1 - N0)
      end else begin
        // send inverted q_m
        tmds_ref[7:0] = ~qmi[7:0];
        rd_next       = rd_prev - diff8;      // + (N0 - N1)
      end

    end else begin
      // Case 2 & 3: rd != 0 and ones != zeros
      use_inv = ((rd_prev > 0) && (N1_q > N0_q)) ||
                ((rd_prev < 0) && (N1_q < N0_q));

      tmds_ref[8] = qmi[8];

      if (use_inv) begin
        // Invert data to oppose current RD
        tmds_ref[9]   = 1'b1;
        tmds_ref[7:0] = ~qmi[7:0];

        // RD += (N0 - N1) = -diff8
        rd_next = rd_prev - diff8;

        // and adjust by q_m[8]
        if (qmi[8])
          rd_next = rd_next - 1;
        else
          rd_next = rd_next + 1;

      end else begin
        // Keep data as-is
        tmds_ref[9]   = 1'b0;
        tmds_ref[7:0] =  qmi[7:0];

        // RD += (N1 - N0) = diff8
        rd_next = rd_prev + diff8;

        // and adjust by q_m[8]
        if (qmi[8])
          rd_next = rd_next + 1;
        else
          rd_next = rd_next - 1;
      end
    end
  end
  endtask

  task check(input [8:0] qmi, input signed [5:0] rdi);
    reg [9:0] tmds_ref;
    integer rd_next_ref;
  begin
    ref_stage2(qmi, rdi, tmds_ref, rd_next_ref);

    if (tmds_out !== tmds_ref || $signed(rd_out) !== $signed(rd_next_ref)) begin
      $display("FAIL q_m=%b rd_in=%0d  exp_tmds=%b got=%b  exp_rd=%0d got=%0d",
                qmi, rdi, tmds_ref, tmds_out, rd_next_ref, rd_out);
      $fatal;
    end
  end
  endtask

  integer d, v, k;

  initial begin
    // Directed edge cases
    q_m=9'b000000000; rd_in=0; #1; check(q_m, rd_in);
    q_m=9'b000000001; rd_in=0; #1; check(q_m, rd_in);
    q_m={1'b0,8'h00}; rd_in=0; #1; check(q_m, rd_in);
    q_m={1'b1,8'hFF}; rd_in=0; #1; check(q_m, rd_in);

    // Exhaustive over all q_m (512) and disparities -9..+9
    for (d = -9; d <= 9; d = d + 1) begin
      for (v = 0; v < 512; v = v + 1) begin
        q_m   = v[8:0];
        rd_in = d[5:0];
        #1;
        check(q_m, rd_in);
      end
    end

    // Random fuzz
    for (k = 0; k < 1000; k = k + 1) begin
      q_m   = $random;
      rd_in = $urandom_range(-9, 9);
      #1;
      check(q_m, rd_in);
    end

    $display("PASS: tmds_stage_2");
    $finish;
  end
endmodule
