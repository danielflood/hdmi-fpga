`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:43:43 AM
// Design Name: 
// Module Name: tmds_stage_1_tb
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


module tmds_stage_1_tb;
    reg [7:0] D;
    reg invert;
    wire [8:0] q_m;
    
    tmds_stage_1 dut (
        .D(D),
        .invert(invert),
        .q_m(q_m)
     );
     
     function [8:0] ref_qm(input [7:0] d, input inv);
        integer i;
        reg [8:0] r;
        begin
            r[0] = d[0];
            for (i = 1; i < 8; i = i + 1) begin
                if (!inv)   r[i] = r[i-1] ^ d[i];
                else        r[i] = (~r[i-1]) ^ d[i];
            end
            r[8] = ~inv;
            ref_qm = r;
        end
     endfunction
     
     integer invv, x;
     initial begin
        for (invv = 0; invv < 2; invv = invv + 1) begin
            invert = invv[0];
            for (x=0; x<256; x=x+1) begin
                D = x[7:0];
                #1;
                if (q_m !== ref_qm(D, invert)) begin
                    $display("Mismatch invert=%0d D=0x%02h got %b exp=%b",
                                invert, D, q_m, ref_qm(D, invert));
                    $stop;
                end
                if (q_m[8] !== ~invert) $fatal("q_m[8] property failed");
            end
        end
        $display("All tests passed :)");
        $finish;
    end            
endmodule
