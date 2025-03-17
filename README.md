## Genetic Algorithm Processor   

This project implements a **Genetic Algorithm (GA) Processor** using **Verilog**, designed to solve optimization problems efficiently. The processor leverages **pipeline processing** to improve the execution speed of the algorithm.

---

## 🧬 What is a Genetic Algorithm?  

A **Genetic Algorithm (GA)** is an optimization technique inspired by natural evolution. It mimics biological processes such as **selection, crossover, and mutation** to iteratively improve solutions for a given problem.  

In this project, the **GA Processor** is designed to find a **test vector** that can detect a **stuck-at-zero fault** in a digital circuit.  

---

## Project Goal  

- **Design a hardware accelerator** for **Genetic Algorithm (GA)** computations.  
- Implement the GA processor with **pipeline architecture** to optimize execution speed.  
- Use **Verilog** to model and simulate the GA processor.  
- Evaluate the processor’s performance in solving a **test vector generation problem** in digital circuits.  

---

##  How the Genetic Algorithm Processor Works  ?

The GA processor follows a **pipelined** execution model, where different stages of the algorithm are processed simultaneously to maximize efficiency.

### **🛠 Pipeline Stages & Execution Flow**  

1️⃣ **Selection Stage**  
   - Uses **tournament selection** (degree of 5) to pick **two parent chromosomes**.  
   - A **random number generator** selects parents from different memory banks.  

2️⃣ **Crossover & Mutation Stage**  
   - A **random number** determines whether **crossover** and **mutation** occur.  
   - **Single-point crossover** swaps portions of two parent chromosomes.  
   - **Mutation** randomly alters bits in the offspring.  
   - The crossover and mutation rates (**r1, r2**) are **adjustable** parameters.  

3️⃣ **Fitness Calculation Stage**  
   - Evaluates the quality of each chromosome.  
   - The goal is to detect a **stuck-at-zero fault** in a circuit node.  
   - The **fitness function** rewards solutions that propagate the fault to the circuit’s output.  
   - The fitness score is calculated as:  
     ```math
     Fitness = (1 if fault is excited, else 0) +  
               (Fraction of inputs on gate Y with non-controlling values) +  
               (Fraction of inputs on gate Z with non-controlling values)
     ```  

4️⃣ **Replacement Stage**  
   - The worst chromosomes in the population are replaced with new ones based on **fitness values**.  
   - Two replacement strategies:  
     - **Worst replacement** (mandatory)  
     - **Scoring-based replacement** (optional)  

5️⃣ **Best Found Register**  
   - A **register stores the best chromosome** found so far.  
   - New solutions are continuously compared against the stored best chromosome.  
   - If a better solution is found, it **replaces** the current best.  
   - This register also participates in **tournament selection** to ensure strong solutions persist.  
   - When the **GA termination condition** is met, the stored best chromosome is output as the final result.  

---

## 🔢 Pipeline Execution Parameters  

These parameters control the execution of the GA processor:  

- **Number of Generations** = `16`  
- **Crossover Probability** = `1.0`  
- **Mutation Probability** = `0.04`  

---

##  Implementation Details  

- The **GA Processor** is implemented using **Verilog**.  
- It is designed as a **hardware accelerator** to speed up GA computations.  
- The processor reads the **initial population** from memory and executes GA steps in a pipelined fashion.  
- Final results are stored in a **register** for output.  

---


##  Reference  
[1] Alinodehi, S. P. H., Moshfe, S., Zaeimian, M. S., Khoei, A., & Hadidi, K. (2015). High-speed general-purpose genetic algorithm processor. *IEEE Transactions on Cybernetics*, 46(7), 1551-1565.  

---
