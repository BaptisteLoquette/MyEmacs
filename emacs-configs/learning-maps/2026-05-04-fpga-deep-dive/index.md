# Deep FPGA: Physics, Math, Electronics and ML/HPC Acceleration

Quick-start index for the **Deep FPGA** curriculum.

## Overview
A frontier-level, dependency-aware learning plan for engineers and researchers who want to master FPGA internals from semiconductor physics to ML/AI acceleration.

## Target Audience
- Working engineers & researchers
- Strong Python / software background
- Want to go deep into physics, math, electronics, Verilog RTL, and SOTA ML/HPC on FPGAs

## Files in this directory

| File | Purpose |
|------|---------|
| `learning-plan.org` | Master Org-mode learning plan with all 30 atomic concepts, dependency order, and linked resources |
| `prereq-graph.dot` | Graphviz DOT prerequisite graph |
| `concepts.json` | Machine-readable atomic concepts table |
| `resources.json` | Machine-readable resource pool (60 resources) |

## How to start

1. Open `learning-plan.org` in Emacs or any Org-mode viewer.
2. Start at **Module 1 — Foundations** and follow the dependency order.
3. For each concept, read the **Theory** source first, then attempt the **Hands-on** exercise.
4. Use the DOT graph to visualize prerequisite relationships.

## Estimated time
- ~30–40 hours of focused self-study across 30 atomic concepts
- Each concept is designed for 20–40 minutes of study

## Domains covered
- **Physics & Electronics**: Semiconductor devices, CMOS, signal integrity, clocking, power integrity
- **Math**: Linear algebra, fixed-point arithmetic, probability, numerical analysis
- **RTL & FPGA**: Verilog, simulation, timing analysis, synthesis/P&R internals
- **Tools**: Python, MATLAB/Simulink HDL Coder, Julia
- **Algorithms**: FIFOs, CAMs, systolic arrays, dataflow graphs, memory hierarchy
- **ML Acceleration**: Quantization, CNN accelerators, transformer acceleration on FPGA
- **HPC**: Sparse computation, Network-on-Chip, roofline analysis, partial reconfiguration

## Prerequisites assumed
- Bachelor-level digital logic and programming
- Python proficiency
- MATLAB access helpful but not required

## Generated
2026-05-04 via frontier-curriculum-builder skill.
