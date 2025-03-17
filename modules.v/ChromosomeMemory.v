`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Course: Bio-Inspired-Design
// Engineer: Matin Firoozbakht
// Module Name: ChromosomeMemory
// Project Name: Genetic Algorithm Processor
//////////////////////////////////////////////////////////////////////////////////
module ChromosomeMemory #( parameter COUNT = 32, parameter DATA_WIDTH = 19) (
    rBarw, address, data_in, fitness_in, data_out, fitness_out
);
    input rBarw;
    input [COUNT - 1 : 0] address;
    input [DATA_WIDTH - 1 : 0] data_in;
    input [63 : 0] fitness_in;
    output reg [DATA_WIDTH - 1 : 0] data_out;
    output reg [63 : 0] fitness_out;

    reg [DATA_WIDTH-1 : 0] data_memory [0 : COUNT - 1];
    reg [63 : 0] fitness_memory [0 : COUNT - 1];

    always @* begin
        if (rBarw) begin
            data_out <= data_memory[address];
            fitness_out <= fitness_memory[address];
        end
        else begin
            data_memory[address] <= data_in;
            fitness_memory[address] <= fitness_in;
        end
    end

endmodule