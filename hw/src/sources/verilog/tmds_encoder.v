`timescale 1ns / 1ps

module tmds_encoder(
    input [7:0] D,
    input signed [5:0] rd_in,
    output [9:0] tmds_out,
    output [5:0] rd_out
    );
    
    wire invert;
    //Stage 0 -> Generate invert signal
    tmds_stage_0 stage0 (
        .D(D),
        .invert(invert)
    );
    
    
    wire [8:0] q_m;   
    // Stage 1 -> Transition Minimiazation
    tmds_stage_1 stage_1 (
        .D(D),
        .invert(invert),
        .q_m(q_m)
    );
    
    // Stage 2 -> DC Balancing
    tmds_stage_2 stage_2 (
        .q_m(q_m),
        .rd_in(rd_in),
        .tmds_out(tmds_out),
        .rd_out(rd_out)
    );
    
endmodule
