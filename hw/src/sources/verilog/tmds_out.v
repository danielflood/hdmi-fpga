`timescale 1ns / 1ps

// Serialize one 10-bit TMDS word onto a differential pair
// clk_pix = pixel clock (1x)
// clk_5x  = 5x pixel clock (used with DDR to get 10x bit rate)
module tmds_out (
    input        clk_pix,
    input        clk_5x,
    input        rst,
    input  [9:0] tmds_data,
    output       tmds_p,
    output       tmds_n
);

    // connection into the IOB
    wire data_to_iob;
    wire master_shiftin1, master_shiftin2;

    // -----------------------
    // Master OSERDESE2 (bits 0..7)
    // -----------------------
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("DDR"),
        .DATA_WIDTH   (10),
        .INIT_OQ      (1'b0),
        .INIT_TQ      (1'b0),
        .SERDES_MODE  ("MASTER"),
        .SRVAL_OQ     (1'b0),
        .SRVAL_TQ     (1'b0),
        .TBYTE_CTL    ("FALSE"),
        .TBYTE_SRC    ("FALSE"),
        .TRISTATE_WIDTH(1)
    ) oserdes_master (
        .OFB(),
        .OQ        (data_to_iob),
        .SHIFTOUT1 (),
        .SHIFTOUT2 (),
        .TBYTEOUT  (),
        .TFB       (),
        .TQ        (),

        .CLK    (clk_5x),
        .CLKDIV (clk_pix),

        .D1 (tmds_data[0]),
        .D2 (tmds_data[1]),
        .D3 (tmds_data[2]),
        .D4 (tmds_data[3]),
        .D5 (tmds_data[4]),
        .D6 (tmds_data[5]),
        .D7 (tmds_data[6]),
        .D8 (tmds_data[7]),

        .OCE   (1'b1),
        .RST   (rst),

        .SHIFTIN1 (master_shiftin1),
        .SHIFTIN2 (master_shiftin2),

        .T1      (1'b0),
        .T2      (1'b0),
        .T3      (1'b0),
        .T4      (1'b0),
        .TBYTEIN (1'b0),
        .TCE     (1'b0)
    );

    // -----------------------
    // Slave OSERDESE2 (bits 8..9)
    // -----------------------
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("DDR"),
        .DATA_WIDTH   (10),
        .INIT_OQ      (1'b0),
        .INIT_TQ      (1'b0),
        .SERDES_MODE  ("SLAVE"),
        .SRVAL_OQ     (1'b0),
        .SRVAL_TQ     (1'b0),
        .TBYTE_CTL    ("FALSE"),
        .TBYTE_SRC    ("FALSE"),
        .TRISTATE_WIDTH(1)
    ) oserdes_slave (
        .OFB(),
        .OQ        (),   // not used
        .SHIFTOUT1 (master_shiftin1),
        .SHIFTOUT2 (master_shiftin2),
        .TBYTEOUT  (),
        .TFB       (),
        .TQ        (),

        .CLK    (clk_5x),
        .CLKDIV (clk_pix),

        .D1 (1'b0),
        .D2 (1'b0),
        .D3 (tmds_data[8]),
        .D4 (tmds_data[9]),
        .D5 (1'b0),
        .D6 (1'b0),
        .D7 (1'b0),
        .D8 (1'b0),

        .OCE   (1'b1),
        .RST   (rst),

        .SHIFTIN1 (1'b0),
        .SHIFTIN2 (1'b0),

        .T1      (1'b0),
        .T2      (1'b0),
        .T3      (1'b0),
        .T4      (1'b0),
        .TBYTEIN (1'b0),
        .TCE     (1'b0)
    );

    // -----------------------
    // Differential TMDS output buffer
    // -----------------------
    OBUFDS #(
        .IOSTANDARD("TMDS_33"),
        .SLEW      ("FAST")
    ) obuf_tmds (
        .I (data_to_iob),
        .O (tmds_p),
        .OB(tmds_n)
    );

endmodule

