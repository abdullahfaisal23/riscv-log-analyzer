#!/bin/bash
# ==============================================================================
# Alternative Master Execution Pipeline (No Password / No Make Required)
# ==============================================================================
set -euo pipefail

CLR_RESET="\033[0m"
CLR_GREEN="\033[1;32m"
CLR_CYAN="\033[1;36m"
CLR_YELLOW="\033[1;33m"
CLR_RED="\033[1;31m"

ACTION=${1:-"all"}

setup_env() {
    echo -e "${CLR_CYAN}[Setup] Configuring script executable flags...${CLR_RESET}"
    chmod +x scripts/*.sh
    ./scripts/setup_env.sh
}

analyze_log() {
    setup_env
    echo -e "${CLR_CYAN}[Analyze] Processing sample log via analyze.sh...${CLR_RESET}"
    ./scripts/analyze.sh --verbose --format text --output test_data/report.txt test_data/sample_sim.log || true
}

generate_reports() {
    setup_env
    echo -e "${CLR_CYAN}[Report] Compiling multi-format dashboards...${CLR_RESET}"
    ./scripts/analyze.sh --format csv --output test_data/report.csv test_data/sample_sim.log || true
    ./scripts/generate_report.sh test_data/report.csv test_data/report.html
    echo -e "${CLR_GREEN}[Success] View visual artifacts inside test_data/report.html${CLR_RESET}"
}

validate_suite() {
    setup_env
    echo -e "${CLR_CYAN}[Validation] 1. Testing pristine passing log environment...${CLR_RESET}"
    ./scripts/analyze.sh test_data/sample_pass.log && echo -e "${CLR_GREEN}PASS Log Verified Successfully!${CLR_RESET}"

    echo -e "${CLR_CYAN}[Validation] 2. Testing failing log environment (Expects non-zero escape)...${CLR_RESET}"
    if ./scripts/analyze.sh test_data/sample_fail.log; then
        echo -e "${CLR_RED}Validation Failed: Script structural error.${CLR_RESET}"; exit 1
    else
        echo -e "${CLR_GREEN}FAIL Log Flagged Correctly! Structural system functional.${CLR_RESET}"
    fi
}

clean_workspace() {
    echo -e "${CLR_RED}[Cleaning Files] Scrubbing output report matrix and build logs...${CLR_RESET}"
    rm -f test_data/report.* test_data/output_* scripts/*.tmp
    echo -e "${CLR_GREEN}Clean phase finalized cleanly.${CLR_RESET}"
}

case "$ACTION" in
    setup)     setup_env ;;
    analyze)   analyze_log ;;
    report)    generate_reports ;;
    validate)  validate_suite ;;
    clean)     clean_workspace ;;
    all)
        setup_env
        analyze_log
        generate_reports
        ;;
    *)
        echo "Usage: $0 {setup|analyze|report|validate|clean|all}"
        exit 1
        ;;
esac
