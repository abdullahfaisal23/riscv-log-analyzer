#!/bin/bash
# ==============================================================================
# RISC-V Verification Log Analyzer Core Framework Engine
# Author: MEDS Systems Engineering Group
# ==============================================================================

# Secure execution modes configuration
set -euo pipefail

# ANSI color output maps for terminal interface display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1;33m'
NC='\033[0m' # No Color

# Initialization default parameters
FORMAT="text"
OUTPUT="/dev/stdout"
VERBOSE=0
COMPARE_MODE=0

# Help documentation display function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] <simulation_log_path>

Core Options:
  --format [text|csv]  Specifies destination data presentation mechanism (default: text).
  --output <file_path> Directs results stream payload routing layout (default: stdout).
  --verbose            Outputs metrics in real time during log traversal operations.
  --compare <l1> <l2>  [Bonus] Audits two logs to identify regressions.
  --help               Prints tool structural operational manual interface.

EOF
    exit 0
}

# --- Parsing command line parameters via standard loops ---
# Enables flags to parse correctly in any execution sequence
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            FORMAT="$2"; shift 2 ;;
        --output)
            OUTPUT="$2"; shift 2 ;;
        --verbose)
            VERBOSE=1; shift 1 ;;
        --compare)
            COMPARE_MODE=1; shift 1 ;;
        --help)
            usage ;;
        -*)
            echo -e "${RED}[Input Error] Unknown parameter argument given: $1${NC}" >&2; usage ;;
        *)
            ARGS+=("$1"); shift 1 ;;
    esac
done

# --- [Bonus Challenge Functionality]: Regression Compare Interface Handler ---
execute_regression_audit() {
    if [ ${#ARGS[@]} -lt 2 ]; then
        echo -e "${RED}[Input Error] System compare operation requires two reference log paths.${NC}" >&2
        exit 1
    fi
    local base_log="${ARGS}"
    local current_log="${ARGS[1]}"

    if [ ! -f "$base_log" ] || [ ! -f "$current_log" ]; then
        echo -e "${RED}[Execution Error] Valid reference log targets are required for processing.${NC}" >&2
        exit 1
    fi

    echo -e "${BOLD}======================================================================"
    echo -e "              RISC-V REGRESSION ANALYSIS ENGINE OUTCOME               "
    echo -e "======================================================================${NC}"
    echo -e "${BLUE}Baseline Reference Log: ${NC}$base_log"
    echo -e "${BLUE}Current Evaluation Log: ${NC}$current_log\n"

    # Temporary directory extraction files map
    local t_base
    local t_curr
    t_base=$(mktemp)
    t_curr=$(mktemp)

    # Scrape tests passing in base logs
    grep "TEST PASS:" "$base_log" | awk '{print $4}' | sort > "$t_base"
    # Scrape tests failing in new log versions
    grep "TEST FAIL:" "$current_log" | awk '{print $4}' | sort > "$t_curr"

    # Match intersecting rows to find active regressions
    local regression_matches
    regression_matches=$(comm -12 "$t_base" "$t_curr")

    if [ -z "$regression_matches" ]; then
        echo -e "${GREEN}[Regression Status] No regressions detected. All active modules functional.${NC}"
        rm -f "$t_base" "$t_curr"
        exit 0
    else
        echo -e "${RED}[ALERT] Regressions Detected! The following test(s) previously PASSED but are now FAILING:${NC}"
        while read -r regression; do
            echo -e "  --> ${RED}$regression${NC}"
        done <<< "$regression_matches"
        rm -f "$t_base" "$t_curr"
        exit 1
    fi
}

# Branch execution early if compare mode is requested
if [ "$COMPARE_MODE" -eq 1 ]; then
    execute_regression_audit
fi

# Ensure log target parameter parameters are passed
if [ ${#ARGS[@]} -lt 1 ]; then
    echo -e "${RED}[Input Error] Execution target log parameter path trace missing.${NC}" >&2
    usage
fi

TARGET_LOG="${ARGS}"

# Validate target log source presence
if [ ! -f "$TARGET_LOG" ]; then
    echo -e "${RED}[File Error] Target system log file target not present: $TARGET_LOG${NC}" >&2
    exit 1
fi

# --- Structural Log Processing Metrics Scraping Functions ---
total_tests_run() {
    grep -c "TEST START:" "$TARGET_LOG"
}

count_test_status() {
    local criteria="$1"
    grep -c "TEST $criteria:" "$TARGET_LOG"
}

extract_failing_modules() {
    grep "TEST FAIL:" "$TARGET_LOG" | awk '{print $4}'
}

# Multi-parameter execution metrics analysis function
calculate_timing_statistics() {
    # Extract execution times using a regex pattern
    local timings
    timings=$(grep -E "TEST (PASS|FAIL):" "$TARGET_LOG" | grep -oE "\([0-9.]+s\)" | tr -d '(s)' || true)
    
    if [ -z "$timings" ]; then
        echo "0 0 0" # Fallback tuple data string if no timing records are present
        return
    fi

    # Core mathematical analysis via inline AWK computation arrays
    echo "$timings" | awk '
    BEGIN { min=99999; max=0; sum=0; count=0 }
    {
        val=$1
        sum += val
        count++
        if(val < min) min=val
        if(val > max) max=val
    }
    END {
        if(count==0) print "0 0 0";
        else printf "%.2f %.2f %.2f", min, max, (sum/count)
    }'
}

# --- Compile Operational Metric Variables ---
RUN_TOTAL=$(total_tests_run)
TOTAL_PASS=$(count_test_status "PASS")
TOTAL_FAIL=$(count_test_status "FAIL")
TOTAL_SKIP=$(count_test_status "SKIP")

# Pass rate computation loop safely guarded against division by zero
if [ "$RUN_TOTAL" -gt 0 ]; then
    PASS_RATE=$(echo "scale=2; ($TOTAL_PASS / $RUN_TOTAL) * 100" | bc)
else
    PASS_RATE="0.00"
fi

# Import calculated timing structures
read -r TIME_MIN TIME_MAX TIME_AVG <<< "$(calculate_timing_statistics)"

# Determine overall run status verdict
if [ "$TOTAL_FAIL" -eq 0 ] && [ "$RUN_TOTAL" -gt 0 ]; then
    VERDICT="${GREEN}PASS${NC}"
    EXIT_CODE=0
else
    VERDICT="${RED}FAIL${NC}"
    EXIT_CODE=1
fi

# --- Data Formatting Generation Pipeline Operations ---

# Output Generation: Standard Readable Text
generate_text_output() {
    local payload=""
    payload+="======================================================================\n"
    payload+="                    RISC-V LOG INTERFACE REPORT OUTPUT                \n"
    payload+="======================================================================\n"
    payload+="Log Resource: $TARGET_LOG\n"
    payload+="Total Unit Tests Evaluated : $RUN_TOTAL\n"
    payload+="  --> Passed Component Count: $TOTAL_PASS\n"
    payload+="  --> Failed Component Count: $TOTAL_FAIL\n"
    payload+="  --> Skipped Module Metrics : $TOTAL_SKIP\n"
    payload+="Functional Test Pass Rate  : $PASS_RATE%\n"
    payload+="----------------------------------------------------------------------\n"
    payload+="Simulation Performance Profile Run Metrics:\n"
    payload+="  Minimum Operational Run Instance Execution: ${TIME_MIN}s\n"
    payload+="  Maximum Operational Run Instance Execution: ${TIME_MAX}s\n"
    payload+="  Average Module Block Execution Time Matrix : ${TIME_AVG}s\n"
    payload+="----------------------------------------------------------------------\n"
    payload+="Failing Structural Targets Listing:\n"
    
    if [ "$TOTAL_FAIL" -eq 0 ]; then
        payload+="  None detected.\n"
    else
        while read -r module; do
            payload+="  [Core Test Failure]: $module\n"
        done <<< "$(extract_failing_modules)"
    fi
    payload+="----------------------------------------------------------------------\n"
    payload+="Final Verification Infrastructure Verdict Status: $VERDICT\n"
    payload+="======================================================================\n"

    echo -e "$payload" > "$OUTPUT"
}

# Output Generation: Structured CSV Data
generate_csv_output() {
    {
        echo "metric,value"
        echo "log_file,$TARGET_LOG"
        echo "total_tests,$RUN_TOTAL"
        echo "pass_count,$TOTAL_PASS"
        echo "fail_count,$TOTAL_FAIL"
        echo "skip_count,$TOTAL_SKIP"
        echo "pass_rate,$PASS_RATE"
        echo "min_time,$TIME_MIN"
        echo "max_time,$TIME_MAX"
        echo "avg_time,$TIME_AVG"
        echo "verdict,$(strip_ansi_codes "$VERDICT")"
    } > "$OUTPUT"
}

strip_ansi_codes() {
    echo "$1" | sed 's/\x1B\[[0-9;]*[JKmsu]//g'
}

# Print trace operations if verbose tracking is active
if [ "$VERBOSE" -eq 1 ]; then
    echo -e "${CYAN}[Verbose Trace] Parsing targeted simulation components in real-time...${NC}"
    while read -r line; do
        if [[ "$line" =~ "TEST PASS" ]]; then
            echo -e "  Parsed execution: ${GREEN}$line${NC}"
        elif [[ "$line" =~ "TEST FAIL" || "$line" =~ "ERROR" ]]; then
            echo -e "  Parsed execution: ${RED}$line${NC}"
        fi
    done < "$TARGET_LOG"
fi

# Dispatch output routing based on target format configuration
if [ "$FORMAT" == "csv" ]; then
    generate_csv_output
else
    generate_text_output
fi

# Signal runtime evaluation exit code state mapping
exit $EXIT_CODE
