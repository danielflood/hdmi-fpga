`timescale 1ns / 1ps

module video_timer(
    input clk_pix,
    input rst,
    output reg [10:0] counterX,
    output reg [9:0] counterY,
    output hsync,
    output vsync,
    output de
    );
   
   always @ (posedge clk_pix or posedge rst) begin
        if (rst) begin
            counterX <= 0;
            counterY <= 0;
        end else begin
            counterX <= (counterX==1649) ? 0 : counterX+1;
            if (counterX==1649)
                counterY <= (counterY==749)  ? 0 : counterY+1;
        end
   end
   
   assign de = (counterX<1280) && (counterY<720);
   assign hsync = (counterX>=1390) && (counterX<1430);
   assign vsync = (counterY>=725) && (counterY<730);

endmodule
