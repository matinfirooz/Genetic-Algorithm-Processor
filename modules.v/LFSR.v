`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Course: Bio-Inspired-Design
// Engineer: Matin Firoozbakht
// Module Name: LFSR
// Project Name: Genetic Algorithm Processor
//////////////////////////////////////////////////////////////////////////////////
module LFSR #(parameter LFSR_WIDTH = 8) (
    input clk, init, en, input [LFSR_WIDTH-1:0] poly, 
    input [LFSR_WIDTH-1:0] seed, output reg [LFSR_WIDTH-1:0] Q);
    integer i;
    always @(posedge clk, posedge init) begin
        if (init == 1'b1) Q <= seed;
        else if (en == 1'b1) begin
            Q[LFSR_WIDTH-1] <= Q[0];
            for (i=0; i<LFSR_WIDTH-1 ; i=i+1 ) begin
                Q[i] <= (Q[0] & poly[i] ) ^ Q[i+1];
            end //for
        end
    end
endmodule