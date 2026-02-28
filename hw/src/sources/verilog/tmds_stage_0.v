`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 12:31:44 PM
// Design Name: 
// Module Name: tmds_stage_0
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


module tmds_stage_0(
    input  [7:0] D,   // D[0] = LSB
    output reg   invert
);
    wire [3:0] count;
    
    popcount8 counter (.D(D), .count(count));
    
    always @(*) begin
        invert = (count > 4) || ((count == 4) && (D[0] == 1'b0));
    end
endmodule

