`timescale 1ns / 1ps

module tmds_stage_0_tb;
    reg  [7:0] D;
    wire invert;

    tmds_stage_0 dut ( .D(D), .invert(invert) );

    function check_invert;
        input [7:0] val;
        integer j; reg [3:0] pc;
        begin
            pc = 0;
            for (j=0; j<8; j=j+1) pc = pc + val[j];
            check_invert = (pc > 4) || ((pc == 4) && (val[0] == 1'b0));
        end
    endfunction

    integer i;
    initial begin
        for (i=0; i<256; i=i+1) begin
            D = i[7:0];
            #1;
            if (invert !== check_invert(D)) begin
                $display("Mismatch: D=%b invert=%0b expected=%0b", D, invert, check_invert(D));
                $finish;
            end
        end
        $display("All tests passed!");
        $finish;
    end
endmodule

