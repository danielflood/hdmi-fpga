`timescale 1ns / 1ps

module tmds_stage_2(
    input  [8:0]       q_m,
    input  signed [5:0] rd_in,
    output reg  [9:0]   tmds_out,
    output reg  signed [5:0] rd_out
    );

    // Count 1s in q_m[7:0]
    wire [3:0] ones8;
    popcount8 counter (.D(q_m[7:0]), .count(ones8));

    wire [3:0] zeros8 = 4'd8 - ones8;

    reg  use_inverted;
    reg  signed [6:0] rd_next;   // internal with a bit of headroom
    reg  signed [5:0] diff8;

    always @* begin
        // default (to avoid Xs)
        tmds_out = 10'b0;
        rd_next  = rd_in;

        // diff8 = N1_q - N0_q in signed 6-bit
        diff8 = $signed({2'b00, ones8}) - $signed({2'b00, zeros8});

        // Case 1: rd == 0 OR ones == zeros (balanced case)
        if ((rd_in == 0) || (ones8 == zeros8)) begin
            tmds_out[9] = ~q_m[8];
            tmds_out[8] =  q_m[8];

            if (q_m[8]) begin
                // send q_m as-is
                tmds_out[7:0] = q_m[7:0];
                // RD += N1 - N0
                rd_next = rd_in + diff8;
            end else begin
                // send inverted q_m
                tmds_out[7:0] = ~q_m[7:0];
                // RD += N0 - N1 = -diff8
                rd_next = rd_in - diff8;
            end

        end else begin
            // Case 2 & 3: rd != 0 and ones != zeros
            use_inverted = ((rd_in > 0) && (ones8 > zeros8)) ||
                           ((rd_in < 0) && (ones8 < zeros8));

            tmds_out[8] = q_m[8];

            if (use_inverted) begin
                // Invert data to oppose current RD
                tmds_out[9]   = 1'b1;
                tmds_out[7:0] = ~q_m[7:0];

                // RD += (N0 - N1)
                rd_next = rd_in - diff8;

                // and adjust by q_m[8]
                if (q_m[8])
                    rd_next = rd_next - 1;  // subtract 1 if q_m[8]=1
                else
                    rd_next = rd_next + 1;  // add 1 if q_m[8]=0

            end else begin
                // Keep data as-is
                tmds_out[9]   = 1'b0;
                tmds_out[7:0] = q_m[7:0];

                // RD += (N1 - N0)
                rd_next = rd_in + diff8;

                // and adjust by q_m[8]
                if (q_m[8])
                    rd_next = rd_next + 1;
                else
                    rd_next = rd_next - 1;
            end
        end

        // Truncate back to 6 bits signed
        rd_out = rd_next[5:0];
    end

endmodule