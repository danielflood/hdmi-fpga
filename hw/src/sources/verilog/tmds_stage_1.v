`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:25:57 AM
// Design Name: 
// Module Name: tmds_stage_1
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


module tmds_stage_1(
    input [7:0] D,
    input invert,
    output reg [8:0] q_m
    );
    
    integer i;
    always @ (*) begin
        q_m[0] = D[0];
        
        for (i=1; i<8; i=i+1) begin
            if (!invert) begin
                //XOR
                q_m[i] = q_m[i-1] ^ D[i];
            end else begin
                //XNOR
                q_m[i] = q_m[i-1] ^~ D[i];
            end
        end
       
       q_m[8] = ~invert; 
    end         
endmodule
