`timescale 1ns / 1ps

module tmds_encoder_tb;

    // DUT inputs
    reg  [7:0] D;
    reg  signed [5:0] rd_in;

    // DUT outputs
    wire [9:0] tmds_out;
    wire signed [5:0] rd_out;

    // Instantiate DUT
    tmds_encoder dut (
        .D(D),
        .rd_in(rd_in),
        .tmds_out(tmds_out),
        .rd_out(rd_out)
    );

    // ----------------------------
    // Reference / golden model
    // ----------------------------

    // 8-bit popcount
    function integer popcount8;
        input [7:0] val;
        integer i;
        begin
            popcount8 = 0;
            for (i = 0; i < 8; i = i + 1)
                popcount8 = popcount8 + val[i];
        end
    endfunction

    // TMDS reference encoder:
    // implements stage0 + stage1 + stage2 directly, per the standard algorithm
    task ref_tmds;
        input  [7:0] D_in;
        input  integer rd_prev;        // running disparity (signed)
        output [9:0] tmds_ref;         // 10-bit TMDS symbol
        output integer rd_next;        // next running disparity
        integer N1_d;
        integer N1_q, N0_q;
        reg invert;
        reg [8:0] q_m;
        integer i;
    begin
        // ---- Stage 0: invert decision from input byte ----
        N1_d   = popcount8(D_in);
        invert = (N1_d > 4) || (N1_d == 4 && D_in[0] == 1'b0);

        // ---- Stage 1: transition minimisation (q_m) ----
        q_m[0] = D_in[0];
        for (i = 1; i < 8; i = i + 1) begin
            if (!invert)
                q_m[i] = q_m[i-1] ^ D_in[i];
            else
                q_m[i] = ~q_m[i-1] ^ D_in[i];
        end
        q_m[8] = ~invert;

        // ---- Stage 2: DC balancing / running disparity ----
        N1_q = popcount8(q_m[7:0]);
        N0_q = 8 - N1_q;

        if ((rd_prev == 0) || (N1_q == N0_q)) begin
            // Case 1: rd == 0 or balanced q_m
            tmds_ref[9] = ~q_m[8];
            tmds_ref[8] =  q_m[8];
            if (q_m[8]) begin
                tmds_ref[7:0] = q_m[7:0];
                rd_next = rd_prev + (N1_q - N0_q);
            end else begin
                tmds_ref[7:0] = ~q_m[7:0];
                rd_next = rd_prev + (N0_q - N1_q);
            end
        end else begin
            // Case 2: rd != 0 and q_m is not balanced
            tmds_ref[8] = q_m[8];

            if ((rd_prev > 0 && N1_q > N0_q) ||
                (rd_prev < 0 && N1_q < N0_q)) begin
                // Invert to oppose current RD
                tmds_ref[9]   = 1'b1;
                tmds_ref[7:0] = ~q_m[7:0];
                rd_next = rd_prev + (N0_q - N1_q);
                if (q_m[8]) rd_next = rd_next - 1;
                else        rd_next = rd_next + 1;
            end else begin
                // Keep as-is
                tmds_ref[9]   = 1'b0;
                tmds_ref[7:0] =  q_m[7:0];
                rd_next = rd_prev + (N1_q - N0_q);
                if (q_m[8]) rd_next = rd_next + 1;
                else        rd_next = rd_next - 1;
            end
        end
    end
    endtask

    // ----------------------------
    // Test stimulus
    // ----------------------------

    integer errors;
    integer rd_ref, rd_next_ref;
    integer pass, x;
    reg [9:0] tmds_ref;

    initial begin
        errors  = 0;
        rd_ref  = 0;
        rd_in   = 0;
        D       = 0;

        // Optional: enable if you want VCD from Icarus; Vivado doesn't need this.
        // $dumpfile("tmds_encoder_tb.vcd");
        // $dumpvars(0, tmds_encoder_tb);

        // Do a few passes over all 256 input values, feeding rd_out back into rd_in
        for (pass = 0; pass < 3; pass = pass + 1) begin
            for (x = 0; x < 256; x = x + 1) begin
                D     = x[7:0];
                rd_in = rd_ref[5:0];     // drive lower 6 bits to DUT

                // wait for DUT combinational logic to settle
                #1;

                // compute golden result
                ref_tmds(D, rd_ref, tmds_ref, rd_next_ref);

                // compare TMDS word
                if (tmds_out !== tmds_ref) begin
                    $display("TMDS MISMATCH pass=%0d D=%0d rd_prev=%0d : dut=%b ref=%b",
                             pass, D, rd_ref, tmds_out, tmds_ref);
                    errors = errors + 1;
                end

                // compare running disparity (sign-extend both to 32 bits for compare)
                if ($signed(rd_out) !== $signed(rd_next_ref)) begin
                    $display("RD MISMATCH   pass=%0d D=%0d rd_prev=%0d : dut_rd=%0d ref_rd=%0d",
                             pass, D, rd_ref, rd_out, rd_next_ref);
                    errors = errors + 1;
                end

                // advance reference RD for next symbol
                rd_ref = rd_next_ref;

                #4;
            end
        end

        if (errors == 0)
            $display("TMDS encoder test PASSED: no mismatches.");
        else
            $display("TMDS encoder test FAILED: %0d mismatches.", errors);

        $finish;
    end

endmodule