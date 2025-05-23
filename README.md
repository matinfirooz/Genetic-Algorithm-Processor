## Genetic Algorithm Processor   

This project implements a **Genetic Algorithm (GA) Processor** using **Verilog**, designed to solve optimization problems efficiently. The processor leverages **pipeline processing** to improve the execution speed of the algorithm.

---
## Table of Contents

1. [What is a Genetic Algorithm?](#what-is-a-genetic-algorithm)  
2. [Project Goal](#project-goal)  
3. [How the Genetic Algorithm Processor Works](#how-the-genetic-algorithm-processor-works)  
   3.1. [Pipeline Stages and Execution Flow](#pipeline-stages-and-execution-flow)  
4. [Pipeline Execution Parameters](#pipeline-execution-parameters)  
5. [Reference](#reference)

---

## What is a Genetic Algorithm?  

A **Genetic Algorithm (GA)** is an optimization technique inspired by natural evolution. It mimics biological processes such as **selection, crossover, and mutation** to iteratively improve solutions for a given problem.  

In this project, the **GA Processor** is designed to find a **test vector** that can detect a **stuck-at-zero fault** in a digital circuit.  

---

## Project Goal  

The entire GA processor is described in Verilog and functions as a hardware accelerator. It reads the initial population from memory and continuously runs the genetic algorithm in a pipelined manner. The result is stored in a dedicated register for final output. This implementation is well-suited for deployment on FPGA or ASIC platforms.

---

##  How the Genetic Algorithm Processor Works  ?

The GA processor follows a **pipelined** execution model, where different stages of the algorithm are processed simultaneously to maximize efficiency.

###  Pipeline Stages & Execution Flow  

1. **Selection Stage**  

   The first stage is the selection stage. It uses a tournament selection strategy with a degree of five to pick two parent chromosomes. A random number generator selects individuals from separate memory banks to ensure diversity.

3. **Crossover & Mutation Stage**

   A random value determines whether crossover and mutation operations will occur. The crossover is implemented as a single-point crossover, where segments of two parent chromosomes are exchanged. Mutation randomly alters individual bits in the resulting offspring. The probabilities of crossover and mutation are adjustable using two parameters, r1 and r2.
   

4. **Fitness Calculation Stage**  

   Following this is the fitness calculation stage. In this stage, the processor evaluates the quality of each chromosome based on its ability to detect a stuck-at-zero fault. The fitness function gives a base score of one if the fault is excited. Additional points are added based on the fraction of inputs with non-controlling values at two specific gates, Y and Z. The more favorable these conditions, the higher the fitness score.
   
   - The fitness score is calculated as:  
     ```math
     Fitness = (1 if fault is excited, else 0) +  
               (Fraction of inputs on gate Y with non-controlling values) +  
               (Fraction of inputs on gate Z with non-controlling values)
     ```  

6. **Replacement Stage**  
   
   The newly generated offspring replace the worst-performing chromosomes in the population. There are two replacement strategies: a mandatory worst replacement strategy and an optional scoring-based replacement strategy.  

7. **Best Found Register**  

   Finally, the best-found register tracks the highest-scoring chromosome discovered so far. Each new solution is compared to the current best. If the new solution performs better, it replaces the previous best. This register is also included in future selection rounds to preserve strong candidates. Once the genetic algorithm meets its termination condition, the best chromosome is output as the final result.

---

##  Pipeline Execution Parameters  

These parameters control the execution of the GA processor:  

- **Number of Generations** = `16`  
- **Crossover Probability** = `1.0`  
- **Mutation Probability** = `0.04`  

---

##  Reference  
[1] Alinodehi, S. P. H., Moshfe, S., Zaeimian, M. S., Khoei, A., & Hadidi, K. (2015). High-speed general-purpose genetic algorithm processor. *IEEE Transactions on Cybernetics*, 46(7), 1551-1565.  

---
