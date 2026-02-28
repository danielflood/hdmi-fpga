`timescale 1ns / 1ps

module hdmi_core (
    input  wire        clk_pix,     // pixel clock (74.25 MHz)
    input  wire        rst,         // active-high reset

    // Encoded TMDS words (still at pixel rate)
    output reg  [9:0]  tmds_r,
    output reg  [9:0]  tmds_g,
    output reg  [9:0]  tmds_b,

    // For debug / external use if needed
    output wire        hsync,
    output wire        vsync,
    output wire        de
);

    // ------------------------------------------------------------
    // 1) Video timing
    // ------------------------------------------------------------
    wire [10:0] counterX;
    wire [9:0]  counterY;

    video_timer u_video_timer (
        .clk_pix (clk_pix),
        .rst     (rst),
        .counterX(counterX),
        .counterY(counterY),
        .hsync   (hsync),
        .vsync   (vsync),
        .de      (de)
    );

    // ------------------------------------------------------------
    // 2) Pixel generation (unencoded RGB)
    // ------------------------------------------------------------
    wire [7:0] red_pix;
    wire [7:0] green_pix;
    wire [7:0] blue_pix;

    pixel_gen u_pixel_gen (
        .counterX(counterX),
        .counterY(counterY),
        .red     (red_pix),
        .blue    (blue_pix),
        .green   (green_pix)
    );

    // You can still blank the *data* when de==0, but the real
    // blanking behaviour is now handled by the control symbols
    // we drive on the TMDS channels below.
    wire [7:0] red_data   = red_pix;
    wire [7:0] green_data = green_pix;
    wire [7:0] blue_data  = blue_pix;

    // ------------------------------------------------------------
    // 3) Running disparity registers for each channel
    // ------------------------------------------------------------
    reg  signed [5:0] rd_r = 6'sd0;
    reg  signed [5:0] rd_g = 6'sd0;
    reg  signed [5:0] rd_b = 6'sd0;

    wire signed [5:0] rd_r_next_data;
    wire signed [5:0] rd_g_next_data;
    wire signed [5:0] rd_b_next_data;

    wire [9:0] tmds_r_data;
    wire [9:0] tmds_g_data;
    wire [9:0] tmds_b_data;

    // ------------------------------------------------------------
    // 4) TMDS encoders for each colour channel (active video)
    // ------------------------------------------------------------
    tmds_encoder u_tmds_r (
        .D        (red_data),
        .rd_in    (rd_r),
        .tmds_out (tmds_r_data),
        .rd_out   (rd_r_next_data)
    );

    tmds_encoder u_tmds_g (
        .D        (green_data),
        .rd_in    (rd_g),
        .tmds_out (tmds_g_data),
        .rd_out   (rd_g_next_data)
    );

    tmds_encoder u_tmds_b (
        .D        (blue_data),
        .rd_in    (rd_b),
        .tmds_out (tmds_b_data),
        .rd_out   (rd_b_next_data)
    );

    // ------------------------------------------------------------
    // 5) TMDS control tokens (used when de == 0)
    //
    // According to TMDS spec (C0 = hsync, C1 = vsync on channel 0):
    //   C0 C1 -> 10-bit symbol
    //    0  0 -> 0010101011
    //    0  1 -> 0010101010
    //    1  0 -> 1101010100
    //    1  1 -> 1101010101
    //
    // We put these on BLUE channel (lane 0). Red/green get a
    // "C0=0,C1=0" token during blanking.
    // ------------------------------------------------------------
    function [9:0] tmds_control;
        input c0;  // hsync
        input c1;  // vsync
        begin
            case ({c0, c1})
                2'b00: tmds_control = 10'b0010101011;
                2'b01: tmds_control = 10'b0010101010;
                2'b10: tmds_control = 10'b1101010100;
                2'b11: tmds_control = 10'b1101010101;
            endcase
        end
    endfunction

    localparam [9:0] TMDS_CTL_00 = 10'b0010101011;  // C0=0,C1=0

    // ------------------------------------------------------------
    // 6) Register TMDS outputs & update running disparity
    //
    //   - When de == 1: use encoder outputs, update rd_*.
    //   - When de == 0: send control tokens, reset rd_* to 0.
    // ------------------------------------------------------------
    always @(posedge clk_pix or posedge rst) begin
        if (rst) begin
            rd_r  <= 6'sd0;
            rd_g  <= 6'sd0;
            rd_b  <= 6'sd0;

            tmds_r <= 10'd0;
            tmds_g <= 10'd0;
            tmds_b <= 10'd0;
        end else begin
            if (de) begin
                // Active video: use encoded pixel data
                rd_r  <= rd_r_next_data;
                rd_g  <= rd_g_next_data;
                rd_b  <= rd_b_next_data;

                tmds_r <= tmds_r_data;
                tmds_g <= tmds_g_data;
                tmds_b <= tmds_b_data;
            end else begin
                // Blanking: send TMDS control symbols
                rd_r <= 6'sd0;
                rd_g <= 6'sd0;
                rd_b <= 6'sd0;

                // Red/green get C0=C1=0 control token
                tmds_r <= TMDS_CTL_00;
                tmds_g <= TMDS_CTL_00;

                // Blue (lane 0) carries HSYNC/VSYNC
                tmds_b <= tmds_control(hsync, vsync);
            end
        end
    end

endmodule


