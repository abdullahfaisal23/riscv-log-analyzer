# ==============================================================================
# MEDS Lab Module 1: Build & Execution Management Automation
# Project Name: riscv-log-analyzer
# Author: MEDS Summer Training Programme Cohort
# ==============================================================================

# System definitions
SHELL        := /bin/bash
SCRIPTS_DIR  := scripts
DATA_DIR     := test_data
LOG_FILE     := $(DATA_DIR)/sample_sim.log
PASS_LOG     := $(DATA_DIR)/sample_pass.log
FAIL_LOG     := $(DATA_DIR)/sample_fail.log
REPORT_TXT   := $(DATA_DIR)/report.txt
REPORT_CSV   := $(DATA_DIR)/report.csv
REPORT_HTML  := $(DATA_DIR)/report.html

# ANSI Escape Terminal Formatting Codes
CLR_RESET   := \033[0m
CLR_GREEN   := \033[1;32m
CLR_CYAN    := \033[1;36m
CLR_YELLOW  := \033[1;33m
CLR_RED     := \033[1;31m

.PHONY: all help setup analyze report compare validate clean

all: setup analyze report

help:
	@echo -e "$(CLR_CYAN)========================================================================"
	@echo -e "                   RISC-V LOG ANALYZER BUILD SYSTEM                     "
	@echo -e "========================================================================$(CLR_RESET)"
	@echo -e "$(CLR_YELLOW)Available Commands:$(CLR_RESET)"
	@echo -e "  $(CLR_GREEN)make setup$(CLR_RESET)     - Validates environment conditions and updates permissions."
	@echo -e "  $(CLR_GREEN)make analyze$(CLR_RESET)   - Runs 'analyze.sh' parsing metrics on the default logs."
	@echo -e "  $(CLR_GREEN)make report$(CLR_RESET)    - Generates localized text, CSV, and HTML reports."
	@echo -e "  $(CLR_GREEN)make compare$(CLR_RESET)   - Performs verification testing to check for test regressions."
	@echo -e "  $(CLR_GREEN)make validate$(CLR_RESET)  - Performs verification against passing and failing test suites."
	@echo -e "  $(CLR_GREEN)make clean$(CLR_RESET)     - Clears runtime artifacts, generated CSV data, and dashboards."
	@echo -e "$(CLR_CYAN)========================================================================$(CLR_RESET)"

setup: $(SCRIPTS_DIR)/setup_env.sh
	@echo -e "$(CLR_CYAN)[Build System Setup] Configuring script executable flags...$(CLR_RESET)"
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@./$(SCRIPTS_DIR)/setup_env.sh

analyze: setup
	@echo -e "$(CLR_CYAN)[Build System Analyze] Processing sample log via analyze.sh...$(CLR_RESET)"
	@./$(SCRIPTS_DIR)/analyze.sh --verbose --format text --output $(REPORT_TXT) $(LOG_FILE) || true

report: setup
	@echo -e "$(CLR_CYAN)[Build System Report] Compiling multi-format dashboards...$(CLR_RESET)"
	@./$(SCRIPTS_DIR)/analyze.sh --format csv --output $(REPORT_CSV) $(LOG_FILE) || true
	@./$(SCRIPTS_DIR)/generate_report.sh $(REPORT_CSV) $(REPORT_HTML)
	@echo -e "$(CLR_GREEN)[Success] View visual artifacts inside $(REPORT_HTML)$(CLR_RESET)"

compare: setup
	@echo -e "$(CLR_CYAN)[Build System Compare] Testing log differentials for regression...$(CLR_RESET)"
	@./$(SCRIPTS_DIR)/analyze.sh --compare $(PASS_LOG) $(FAIL_LOG)

validate: setup
	@echo -e "$(CLR_CYAN)[Validation] 1. Testing pristine passing log environment...$(CLR_RESET)"
	@./$(SCRIPTS_DIR)/analyze.sh $(PASS_LOG) && echo -e "$(CLR_GREEN)PASS Log Verified Successfully!$(CLR_RESET)"
	@echo -e "$(CLR_CYAN)[Validation] 2. Testing failing log environment (Expects non-zero escape)...$(CLR_RESET)"
	@if ./$(SCRIPTS_DIR)/analyze.sh $(FAIL_LOG); then \
		echo -e "$(CLR_RED)Validation Failed: Script structural error (Fails to signal 1 on bad logs).$(CLR_RESET)"; exit 1; \
	else \
		echo -e "$(CLR_GREEN)FAIL Log Flagged Correctly! Structural system functional.$(CLR_RESET)"; \
	fi

clean:
	@echo -e "$(CLR_RED)[Cleaning Files] Scrubbing output report matrix and build logs...$(CLR_RESET)"
	@rm -f $(DATA_DIR)/report.* $(DATA_DIR)/output_* $(SCRIPTS_DIR)/*.tmp
	@echo -e "$(CLR_GREEN)Clean phase finalized cleanly.$(CLR_RESET)"
