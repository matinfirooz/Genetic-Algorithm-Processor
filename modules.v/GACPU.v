`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Course: Bio-Inspired-Design
// Engineer: Matin Firoozbakht
// Module Name: GACPU
// Project Name: Genetic Algorithm Processor
//////////////////////////////////////////////////////////////////////////////////
module GACPU #( parameter CROSSOVER_PROB = 1, 
        parameter MUTATION_PROB = 0.04,
        parameter COUNT = 32,
        parameter DATA_WIDTH = 19,
        parameter LFSR_WIDTH = 8) (
    clk, lfsr_en, lfsr_out, progress_pipeline, best_found_reg, best_found_fitness,
    cm1_rBarw, cm1_address, cm1_data_in, cm1_fitness_in, cm1_data_out, cm1_fitness_out,
    cm2_rBarw, cm2_address, cm2_data_in, cm2_fitness_in, cm2_data_out, cm2_fitness_out,
    selection_done, crossover_mutation_done, fitness_done, replacement_done
);
    input clk, progress_pipeline;
    input [LFSR_WIDTH-1:0] lfsr_out;
    output reg lfsr_en;
    output reg selection_done = 0;
    output reg crossover_mutation_done = 0;
    output reg fitness_done = 0;
    output reg replacement_done = 0;
    output reg [DATA_WIDTH - 1 : 0] best_found_reg = 'z;
    output reg [63 : 0] best_found_fitness = 'z;

    // chromosome memory 1, 2 ports
    output reg cm1_rBarw, cm2_rBarw;
    output reg [COUNT - 1 : 0] cm1_address, cm2_address;
    output reg [DATA_WIDTH - 1 : 0] cm1_data_in, cm2_data_in;
    output reg [63 : 0] cm1_fitness_in, cm2_fitness_in;
    input [DATA_WIDTH - 1 : 0] cm1_data_out, cm2_data_out;
    input [63 : 0] cm1_fitness_out, cm2_fitness_out;

    reg memory_initialization_done = 0;
    reg [3:0] pipeline_init_stage_counter = 0;

    // initialize memory with pre-data
    integer populationFile;
    reg [DATA_WIDTH - 1 : 0] chromosome;
    real fitness;

    initial begin
        #20;
        populationFile = $fopen("pop.txt", "r");
        cm1_rBarw = 0;
        cm1_address = 0;
        cm2_rBarw = 0;
        cm2_address = 0;
        while(!$feof(populationFile)) begin
            $fscanf(populationFile, "%b %f\n", chromosome, fitness);
            cm1_data_in = chromosome;
            cm1_fitness_in = $realtobits(fitness);
            @(posedge clk); @(negedge clk);
            cm1_address = cm1_address + 1;
            cm2_data_in = chromosome;
            cm2_fitness_in = $realtobits(fitness);
            @(posedge clk); @(negedge clk);
            cm2_address = cm2_address + 1;
        end // while

        $fclose(populationFile);

        memory_initialization_done = 1;
    end // initial
    // end of memory initialization


    // selection
    integer i, j, index = 0;
    reg [63 : 0] tmp1 = 64'b0, tmp2 = 64'b0;
    reg [DATA_WIDTH - 1 : 0] parents [0 : 4];
    reg [63 : 0] parents_fit [0 : 4];
    reg [DATA_WIDTH - 1 : 0] parent1 = 'b0, parent2 = 'b0;

    always @(posedge clk) begin
        if (progress_pipeline == 1)
            selection_done <= 0;
        else if (memory_initialization_done && selection_done == 0) begin
            if (best_found_reg !== 'z) begin
                parents[0] <= best_found_reg;
                index <= 1;
                @(posedge clk) @(negedge clk);
            end
            for (i = index; i < 5; i = i + 1) begin
                // here : get two lfsr values before
                cm1_rBarw <= 1;
                lfsr_en <= 1;
                @(posedge clk) @(negedge clk);
                cm1_address <= lfsr_out[4:0];
                cm2_rBarw <= 1;
                @(posedge clk) @(negedge clk);
                cm2_address <= lfsr_out[4:0];
                @(posedge clk) @(negedge clk);
                lfsr_en <= 0;
                // check two fitnesses
                if (cm1_fitness_out > cm2_fitness_out) begin
                    parents[i] <= cm1_data_out;
                    parents_fit[i] <= cm1_fitness_out;
                end
                else begin
                    parents[i] <= cm2_data_out;
                    parents_fit[i] <= cm2_fitness_out;
                end
            end // for
            @(posedge clk) @(negedge clk);

            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5-i; j = j + 1) begin
                    if (parents_fit[j] > parents_fit[j+1]) begin
                        tmp1 = parents_fit[j];
                        parents_fit[j] = parents_fit[j+1];
                        parents_fit[j+1] = tmp1;

                        tmp2 = parents[j];
                        parents[j] = parents[j+1];
                        parents[j+1] = tmp2;
                        @(posedge clk) @(negedge clk);
                    end
                end
            end

            parent1 <= parents[4];
            parent2 <= parents[3];
            @(posedge clk) @(negedge clk);

            if (pipeline_init_stage_counter == 0)
                pipeline_init_stage_counter <= 1;

            selection_done <= 1;
        end
    end
    // end selection

    // crossover & mutation
    reg [DATA_WIDTH - 1 : 0] cm_parent1 = 'b0, cm_parent2 = 'b0;
    reg [DATA_WIDTH - 1 : 0] cm_child1 = 'b0, cm_child2 = 'b0;
    integer k = 0;
    reg [5:0] randnum = 0;
    
    always @(posedge clk) begin
        if (pipeline_init_stage_counter >= 1) begin
            if (progress_pipeline) begin
                cm_parent1 <= parent1;
                cm_parent2 <= parent2;
                crossover_mutation_done <= 0;
                k <= 0;
            end
            else if (progress_pipeline == 0 && crossover_mutation_done == 0) begin
                lfsr_en <= 1;
                @(posedge clk) @(negedge clk);
                randnum <= (lfsr_out % 19 == 0 ? 1 : lfsr_out % 19);
                lfsr_en <= 0;

                @(posedge clk) @(negedge clk);


                if (CROSSOVER_PROB >= randnum/100) begin
                    for (k = 0; k <= randnum - 1; k = k + 1) begin
                        cm_child1[k] <= cm_parent1[k];
                        cm_child2[k] <= cm_parent2[k];
                        @(posedge clk) @(negedge clk);
                    end
                        @(posedge clk) @(negedge clk);
                    for (k = randnum; k <= DATA_WIDTH; k = k + 1) begin
                        cm_child1[k] <= cm_parent2[k];
                        cm_child2[k] <= cm_parent1[k];
                        @(posedge clk) @(negedge clk);
                    end
                end

                if (MUTATION_PROB >= randnum/100) begin
                    cm_child1[randnum] <= ~cm_child1[randnum];
                    cm_child2[randnum] <= ~cm_child2[randnum];
                    @(posedge clk) @(negedge clk);
                end

                if (pipeline_init_stage_counter == 1)
                    pipeline_init_stage_counter <= 2;

                crossover_mutation_done <= 1;
            end
        end
        else 
            crossover_mutation_done <= 1;
    end
    // end crossover & mutation

    // fitness phase
    reg [DATA_WIDTH - 1 : 0] new_children [0:1];
    reg [63 : 0] new_children_fitness [0:1];
    integer l, m, n;
    real new_fitness;
    integer ones, zeros;

    always @(posedge clk) begin
        if (pipeline_init_stage_counter >= 2) begin
            if (progress_pipeline) begin
                new_children[0] <= cm_child1;
                new_children[1] <= cm_child2;
                new_children_fitness[0] <= '0;
                new_children_fitness[1] <= '0;
                fitness_done <= 0; new_fitness <= 0; ones <= 0; zeros <= 0;
            end
            else if (progress_pipeline == 0 && fitness_done == 0) begin
                for (l = 0; l < 2; l = l + 1) begin
                    new_fitness = 0; ones = 0; zeros = 0;
                    @(posedge clk) @(negedge clk);

                    for (m = 18; m > 8; m = m - 1) begin    // count ones in A -> J (non-control value in AND)
                        if (new_children[l][m] == 1'b1)
                            ones = ones + 1;
                        @(posedge clk) @(negedge clk);
                    end
                    if (ones == 10) // Y is 1
                        new_fitness = new_fitness + 1;
                    
                    new_fitness = new_fitness + ones * 0.1;
                    @(posedge clk) @(negedge clk);


                    for (n = 0; n < 9; n = n +1) begin // count zeros in K -> S (non-control value in OR)
                        if (new_children[l][n] == 0'b0)
                            zeros = zeros + 1;
                        @(posedge clk) @(negedge clk);
                    end
                    new_fitness = new_fitness + zeros * 0.111111111;
                    new_children_fitness[l] = $realtobits(new_fitness);
                    @(posedge clk) @(negedge clk);
                end

                if (pipeline_init_stage_counter == 2)
                    pipeline_init_stage_counter <= 3;

                fitness_done <= 1;
            end
        end // if
        else
            fitness_done <= 1;
    end
    // end fitness phase

    // replacement
    reg [DATA_WIDTH - 1 : 0] rep_new_children [0:1];
    reg [63 : 0] rep_new_children_fitness [0:1];
    integer rep_address = 0;

    always @(posedge clk) begin
        if (pipeline_init_stage_counter >= 3) begin
            if (progress_pipeline) begin
                if (best_found_reg === 'z) begin
                    if (new_children_fitness[0] > new_children_fitness[1]) begin
                        best_found_reg <= new_children[0];
                        best_found_fitness <= new_children_fitness[0];
                    end
                    else begin
                        best_found_reg <= new_children[1];
                        best_found_fitness <= new_children_fitness[1];
                    end
                end
                rep_new_children[0] <= new_children[0];
                rep_new_children[1] <= new_children[1];
                rep_new_children_fitness[0] <= new_children_fitness[0];
                rep_new_children_fitness[1] <= new_children_fitness[1];
                replacement_done <= 0;
                if (rep_address == 31)
                    rep_address <= 0;
            end
            else if (progress_pipeline == 0 && replacement_done == 0) begin

                if (rep_new_children_fitness[0] > best_found_fitness) begin
                    best_found_reg <= rep_new_children[0];
                    best_found_fitness <= rep_new_children_fitness[0];
                end
                else if (rep_new_children_fitness[1] > best_found_fitness) begin
                    best_found_reg <= rep_new_children[1];
                    best_found_fitness <= rep_new_children_fitness[1];
                end

                #800;

                cm1_rBarw = 0;
                cm1_address = rep_address;
                cm1_data_in = rep_new_children[0];
                cm1_fitness_in = rep_new_children_fitness[0];
                @(posedge clk) @(negedge clk);

                cm1_address = rep_address + 1;
                cm1_data_in = rep_new_children[1];
                cm1_fitness_in = rep_new_children_fitness[1];
                @(posedge clk) @(negedge clk);

                cm2_rBarw = 0;
                cm2_address = rep_address;
                cm2_data_in = rep_new_children[0];
                cm2_fitness_in = rep_new_children_fitness[0];
                @(posedge clk) @(negedge clk);

                cm2_address = rep_address + 1;
                cm2_data_in = rep_new_children[1];
                cm2_fitness_in = rep_new_children_fitness[1];
                @(posedge clk) @(negedge clk);

                rep_address = rep_address + 2;

                if (pipeline_init_stage_counter == 3)
                    pipeline_init_stage_counter <= 4;

                replacement_done <= 1;
            end
        end // if
        else
            replacement_done <= 1;
    end // replacement

endmodule