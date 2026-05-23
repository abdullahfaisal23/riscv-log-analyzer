# RISC-V Simulation Verification Log Analyzer Engine (`riscv-log-analyzer`)

## Project Description
The `riscv-log-analyzer` is a professional, high-reliability command-line framework designed for parsing, structural aggregation, metrics mining, and runtime tracking analysis of simulation test execution streams for automated RISC-V processor architectural verification suites.

## Features
- **Highly Accurate Parsing:** Fast tracking of pass rates, failures, skips, line numbers, and error patterns.
- **Mathematical Computation Profile Optimization:** Uses raw system pipeline integration alongside floating-point calculation arrays computed via `bc`.
- **Dynamic HTML Monitoring Dashboards:** Automatically converts verification streams into clear HTML metric dashboards.
- **Continuous Integration Checks:** Includes regression testing support with an option to check for behavioral changes across validation log histories.

## Installation & Workspace Configuration
Ensure the host platform runs a modern Linux distribution (Ubuntu 22.04+ LTS recommended) with core scripting dependencies and mathematical libraries installed.

```bash
# Clone the project repository
git clone git@github.com:yourusername/riscv-log-analyzer.git
cd riscv-log-analyzer

# Provision execution workspace environments
make setup
