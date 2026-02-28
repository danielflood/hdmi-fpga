`timescale 1ns / 1ps

// Top-level for Arty Z7-20 HDMI
module hdmi_top (
    input  wire clk_100mhz,
    input  wire rst_btn,   // active-high pushbutton

    // HDMI TMDS differential outputs
    output wire hdmi_tx_clk_p,
    output wire hdmi_tx_clk_n,
    output wire hdmi_tx_d0_p,
    output wire hdmi_tx_d0_n,
    output wire hdmi_tx_d1_p,
    output wire hdmi_tx_d1_n,
    output wire hdmi_tx_d2_p,
    output wire hdmi_tx_d2_n
);
    //--------------------------------------------------------------
    // 1) Clocking: 100 MHz -> 74.25 MHz (pix) and 371.25 MHz (5x)
    //--------------------------------------------------------------
    wire clk_pix;     // ~74.25 MHz
    wire clk_5x;      // ~371.25 MHz (5 × pix)
    wire clk_locked;

    // Instantiate Vivado Clocking Wizard (create this IP yourself)
    // Configure:
    //   - Input: 100 MHz
    //   - Outputs: clk_pix = 74.25 MHz, clk_5x = 371.25 MHz
    clk_wiz_0 u_clk_wiz (
        .clk_in1 (clk_100mhz),
        .reset   (1'b0),
        .locked  (clk_locked),
        .clk_out1(clk_pix),
        .clk_out2(clk_5x)
    );

    // Sync reset to pixel clock and gate with MMCM lock
    reg [3:0] rst_sync = 4'hF;
    always @(posedge clk_pix or negedge clk_locked) begin
        if (!clk_locked)
            rst_sync <= 4'hF;
        else
            rst_sync <= {rst_sync[2:0], rst_btn};
    end
    wire rst = rst_sync[3];

    //--------------------------------------------------------------
    // 2) HDMI core: produces 10-bit TMDS per channel at pixel rate
    //--------------------------------------------------------------
    wire [9:0] tmds_r_word;
    wire [9:0] tmds_g_word;
    wire [9:0] tmds_b_word;
    wire       hsync, vsync, de;

    hdmi_core u_core (
        .clk_pix(clk_pix),
        .rst    (rst),
        .tmds_r (tmds_r_word),
        .tmds_g (tmds_g_word),
        .tmds_b (tmds_b_word),
        .hsync  (hsync),
        .vsync  (vsync),
        .de     (de)
    );

    //--------------------------------------------------------------
    // 3) TMDS clock channel pattern (10-bit)
    //    TMDS clock is just a 50% duty cycle at pixel rate:
    //    1111100000 pattern on the wire
    //--------------------------------------------------------------
    // Bit 0 is the first transmitted bit. Pattern 1111100000 gives a
    // square wave at clk_pix when serialized at 10×.
    wire [9:0] tmds_clk_word = 10'b1111100000;

    //--------------------------------------------------------------
    // 4) Serialize each 10-bit word and drive differential outputs
    //--------------------------------------------------------------
    tmds_out u_tmds_clk (
        .clk_5x   (clk_5x),
        .clk_pix  (clk_pix),
        .rst      (rst),
        .tmds_data(tmds_clk_word),
        .tmds_p   (hdmi_tx_clk_p),
        .tmds_n   (hdmi_tx_clk_n)
    );

    tmds_out u_tmds_b (
        .clk_5x   (clk_5x),
        .clk_pix  (clk_pix),
        .rst      (rst),
        .tmds_data(tmds_b_word),
        .tmds_p   (hdmi_tx_d0_p),
        .tmds_n   (hdmi_tx_d0_n)
    );

    tmds_out u_tmds_g (
        .clk_5x   (clk_5x),
        .clk_pix  (clk_pix),
        .rst      (rst),
        .tmds_data(tmds_g_word),
        .tmds_p   (hdmi_tx_d1_p),
        .tmds_n   (hdmi_tx_d1_n)
    );

    tmds_out u_tmds_r (
        .clk_5x   (clk_5x),
        .clk_pix  (clk_pix),
        .rst      (rst),
        .tmds_data(tmds_r_word),
        .tmds_p   (hdmi_tx_d2_p),
        .tmds_n   (hdmi_tx_d2_n)
    );

endmodule

