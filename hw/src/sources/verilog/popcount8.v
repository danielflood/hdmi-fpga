`timescale 1ns / 1ps

module popcount8(
    input      [7:0] D,
    output reg [3:0] count
    );
    integer i;
    always @ (*) begin
        count = 0;
        for (i=0; i<8; i=i+1) count = count + D[i];
    end 
endmodule
