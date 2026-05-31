`timescale 1ns / 1ps

module pixel_gen(
    input [10:0] counterX,
    input  [9:0] counterY,
    output [7:0] red,
    output [7:0] blue,
    output [7:0] green
    );
    
    assign red = {counterX[5:0] & {6{counterY[4:3]==~counterX[4:3]}}, 2'b00};
    assign green = counterX[7:0] & {8{counterY[6]}};
    assign blue = counterY[7:0];
endmodule
