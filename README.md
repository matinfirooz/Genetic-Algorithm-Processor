## Genetic Algorithm Processor

This project implements a **Genetic Algorithm Processor** using **Verilog**. The processor utilizes **pipeline processing** to enhance execution speed.

##  Overview  
The Genetic Algorithm (GA) is an evolutionary algorithm used for optimization problems. This project designs a GA processor that follows a **pipelined execution** for increased efficiency.

##  Pipeline Stages  

1. **Selection Stage**  
   - Uses **tournament selection** with a degree of **5**.  
   - Random numbers determine which parents are selected.

2. **Crossover & Mutation Stage**  
   - **Single-point crossover** occurs based on a probability `r1`.  
   - **Mutation** happens with probability `r2`.  
   - These probabilities are adjustable.

3. **Fitness Calculation Stage**  
   - The objective is to **find a test vector** to detect **stuck-at-zero faults** at a circuit node.  
   - The fitness function is defined as:  

     ```math
     Fitness = (1 if fault is excited, else 0) +  
               (Fraction of inputs on gate Y with non-controlling values) +  
               (Fraction of inputs on gate Z with non-controlling values)
     ```

4. **Replacement Stage**  
   - The worst chromosomes are replaced by new ones based on **fitness values**.  
   - Two replacement methods:  
     - **Worst replacement** (mandatory)  
     - **Scoring-based replacement** (optional)  

5. **Best Found Register**  
   - Stores the best chromosome found during execution.  
   - Used in **tournament selection** to improve GA performance.  
   - The final best chromosome is returned as output.

## ⚙️ Pipeline Execution Parameters  
- **Number of Generations** = `16`  
- **Crossover Probability** = `1.0`  
- **Mutation Probability** = `0.04`  

##  Implementation  
- Implemented using **Verilog**.  

##  Reference  
[1] Alinodehi, S. P. H., Moshfe, S., Zaeimian, M. S., Khoei, A., & Hadidi, K. (2015). High-speed general-purpose genetic algorithm processor. *IEEE Transactions on Cybernetics*, 46(7), 1551-1565.  

---

###  How to Use  
1. Clone the repository:  
   ```sh
   git clone https://github.com/matinfirooz/genetic-algorithm-processor.git
   cd genetic-algorithm-processor
