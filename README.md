# uvm_training
Learn how to build a complete UVM testbench in 3 weeks

# Agenda
## I- Prerequisites
### week1 day1 to day3
- create a github account: https://github.com
- brush-up on object oriented programming: https://datascientest.com/programmation-orientee-objet-guide-ultime
- brush-up on bash scripting: https://www.learnshell.org/

## II- Theoretical Training
### week1 day4

### week1 day5

### week2 day1

### week2 day2

### week2 day3

### week2 day4

### week2 day5

## III- Practical Case Study: Fifo
### week3 day1
  1. create a git repo
  2. easier UVM
      1. here is the [reference guide](https://www.doulos.com/knowhow/systemverilog/uvm/easier-uvm/easier-uvm-code-generator/easier-uvm-code-generator-reference-guide/)
      2. create templates for each agent
          - defining a good sequence_item is very important
          - use wires in the interface. This is why: [link1](https://verificationacademy.com/forums/systemverilog/wire-vs.-logic-sv-interface) and [link2](https://blogs.sw.siemens.com/verificationhorizons/2013/05/03/wire-vs-reg/)
              > Any signal with more or the potential for more than one driver should be declared as a wire.
      3. create a pinlist
      4. generate code
      5. make sure it compiles
          - comment out do_mon() in monitors for now
          - comment out do_drive() in drivers for now
      6. look at the code, Q&A
  3. commit
      - generate a .gitignore
      - commit + push

### week3 day2
  1. interface: use clocking blocks, make sure it compiles
  2. monitor & driver: fill out run_phase, make sure it compiles
  3. sequence
      - definition: "virtual sequence = sequence launching other sequences"
      - discusion: vitual sequence is called from the uvm_env, can also be called from the uvm_test

### week3 day3
  1. scoreboard
  2. add delay in drivers

### week3 day4
  1. coverage: code
  2. coverage: functional
      - monitor only
      - scoreboard
          - add full->empty->full
          - empty->full->empty

### week3 day5
  1. resources & discussion
      - pipelined protocols
      - override
  2. Q&A
