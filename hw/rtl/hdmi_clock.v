`timescale 1ns / 1ps

module hdmi_clock (
    input  wire clk_in,
    input  wire rst,
    output wire clk_pix,
    output wire clk_5x,
    output wire locked
);
    wire clkfb;
    wire clkfb_buf;
    wire clk_pix_raw;
    wire clk_5x_raw;

    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(62.375),
        .CLKFBOUT_PHASE(0.000),
        .CLKIN1_PERIOD(8.000),
        .CLKOUT0_DIVIDE_F(15.000),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_PHASE(0.000),
        .CLKOUT1_DIVIDE(3),
        .CLKOUT1_DUTY_CYCLE(0.500),
        .CLKOUT1_PHASE(0.000),
        .DIVCLK_DIVIDE(7),
        .REF_JITTER1(0.010),
        .STARTUP_WAIT("FALSE")
    ) u_mmcm (
        .CLKIN1(clk_in),
        .CLKFBIN(clkfb_buf),
        .CLKFBOUT(clkfb),
        .CLKFBOUTB(),
        .CLKOUT0(clk_pix_raw),
        .CLKOUT0B(),
        .CLKOUT1(clk_5x_raw),
        .CLKOUT1B(),
        .CLKOUT2(),
        .CLKOUT2B(),
        .CLKOUT3(),
        .CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKOUT6(),
        .LOCKED(locked),
        .PWRDWN(1'b0),
        .RST(rst)
    );

    BUFG u_clkfb_bufg (
        .I(clkfb),
        .O(clkfb_buf)
    );

    BUFG u_clk_pix_bufg (
        .I(clk_pix_raw),
        .O(clk_pix)
    );

    BUFG u_clk_5x_bufg (
        .I(clk_5x_raw),
        .O(clk_5x)
    );
endmodule
