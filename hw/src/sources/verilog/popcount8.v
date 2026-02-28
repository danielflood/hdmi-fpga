`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 08:47:53 AM
// Design Name: 
// Module Name: popcount8
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
