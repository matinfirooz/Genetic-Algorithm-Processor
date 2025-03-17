`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Course: Bio-Inspired-Design
// Engineer: Matin Firoozbakht
// Module Name: MasterControl
// Project Name: Genetic Algorithm Processor
//////////////////////////////////////////////////////////////////////////////////
module MasterControl #( parameter GENERATION_COUNT = 16, parameter DATA_WIDTH = 19 ) (
    clk, selection_done, crossover_mutation_done, fitness_done, replacement_done, 
    best_found_reg, best_found_fitness,
    progress_pipeline
);
    input clk, selection_done, crossover_mutation_done, 
    fitness_done, replacement_done;
    input [DATA_WIDTH - 1 : 0] best_found_reg;
    input [63 : 0] best_found_fitness;
    output reg progress_pipeline;

    integer gen_counter = 0;

    always @(posedge clk) begin
        if (progress_pipeline == 0 && selection_done && 
        crossover_mutation_done && fitness_done && replacement_done) begin
            progress_pipeline <= 1;
            gen_counter <= gen_counter + 1;
        end
        else
            progress_pipeline <= 0;

        if (gen_counter == 4 * GENERATION_COUNT) begin
            $display("best found chromosome: %b fitness: %f\n", best_found_reg, $bitstoreal(best_found_fitness));
            $stop;
        end
    end
    
endmodule
