`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Course: Bio-Inspired-Design
// Engineer: Matin Firoozbakht
// Module Name: Testbench
// Project Name: Genetic Algorithm Processor
//////////////////////////////////////////////////////////////////////////////////
module Testbench;

    parameter COUNT = 32;
    parameter DATA_WIDTH = 19;
    parameter GENERATION_COUNT = 32; 
    parameter CROSSOVER_PROB = 1; 
    parameter MUTATION_PROB = 0.04;

    reg clk = 0;
    
    always begin: CLOCK_GENERATION
		#10 clk = ~clk;
	end

    wire rBarw1, rBarw2;
    wire [COUNT - 1 : 0] address1, address2;
    wire [DATA_WIDTH - 1 : 0] data_in1, data_in2;
    wire [63 : 0] fitness_in1, fitness_in2;
    wire [DATA_WIDTH - 1 : 0] data_out1, data_out2;
    wire [63 : 0] fitness_out1, fitness_out2;

    ChromosomeMemory #(COUNT, DATA_WIDTH) chromosomeMem1(rBarw1, address1, data_in1, 
    fitness_in1, data_out1, fitness_out1);
    ChromosomeMemory #(COUNT, DATA_WIDTH) chromosomeMem2(rBarw2, address2, data_in2, 
    fitness_in2, data_out2, fitness_out2);


    parameter LFSR_WIDTH = 8;
    reg init = 1;
    wire lfsr_en;
    wire [LFSR_WIDTH - 1:0] lfsr_out;
    LFSR #( LFSR_WIDTH ) lfsr (clk, init, lfsr_en, 8'b10110100, 8'b10010010, lfsr_out);

    initial begin
        #20;
        init = 0;
    end

    // GACPU
    wire [DATA_WIDTH - 1 : 0] best_found_reg;
    wire [63 : 0] best_found_fitness;

    wire progress_pipeline;
    wire selection_done, crossover_mutation_done, fitness_done, replacement_done;

    GACPU #(CROSSOVER_PROB, MUTATION_PROB, COUNT, DATA_WIDTH, LFSR_WIDTH) gacpu(
        clk, lfsr_en, lfsr_out, progress_pipeline, best_found_reg, best_found_fitness,
        rBarw1, address1, data_in1, fitness_in1, data_out1, fitness_out1,
        rBarw2, address2, data_in2, fitness_in2, data_out2, fitness_out2,
        selection_done, crossover_mutation_done, fitness_done, replacement_done
    );
    // END GACPU

    MasterControl # (GENERATION_COUNT, DATA_WIDTH) mc(clk, selection_done, crossover_mutation_done, 
    fitness_done, replacement_done, best_found_reg, best_found_fitness, progress_pipeline);

endmodule;