#!/bin/bash
# ==============================================================================
# CSV Data to HTML Component Dashboard Generator Script
# Author: MEDS Verification Support Toolset UI Engine
# ==============================================================================

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_metrics_csv> <output_dashboard_html>" >&2
    exit 1
fi

INPUT_CSV="$1"
OUTPUT_HTML="$2"

if [ ! -f "$INPUT_CSV" ]; then
    echo "Error: Base metrics file dependency missing: $INPUT_CSV" >&2
    exit 1
fi

# Variable interpolation extraction helper
fetch_metric() {
    grep "^$1," "$INPUT_CSV" | cut -d',' -f2-
}

# Map parameters out of database rows
LOG_NAME=$(fetch_metric "log_file")
TOTAL=$(fetch_metric "total_tests")
PASSED=$(fetch_metric "pass_count")
FAILED=$(fetch_metric "fail_count")
SKIPPED=$(fetch_metric "skip_count")
RATE=$(fetch_metric "pass_rate")
MIN=$(fetch_metric "min_time")
MAX=$(fetch_metric "max_time")
AVG=$(fetch_metric "avg_time")
VERDICT=$(fetch_metric "verdict")

# Determine UI representation layout class configurations
COLOR_THEME="#2ecc71"
[[ "$VERDICT" != "PASS" ]] && COLOR_THEME="#e74c3c"

# Assemble functional static data structure
cat << EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RISC-V Simulation Verification Insight Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f6fa; color: #333; margin: 40px; }
        .container { max-width: 900px; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        h1 { color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 12px; }
        .verdict-banner { background: ${COLOR_THEME}; color: white; padding: 15px; font-weight: bold; text-align: center; border-radius: 6px; font-size: 24px; margin-bottom: 25px; }
        .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-bottom: 30px; }
        .card { background: #f8f9fa; padding: 20px; border-radius: 6px; border-left: 4px solid #3498db; }
        .card.pass { border-left-color: #2ecc71; }
        .card.fail { border-left-color: #e74c3c; }
        .card-title { font-size: 12px; text-transform: uppercase; color: #7f8c8d; font-weight: bold; }
        .card-value { font-size: 22px; font-weight: bold; margin-top: 5px; color: #2c3e50; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f1f2f6; color: #2c3e50; }
        .footer { font-size: 11px; text-align: center; color: #95a5a6; margin-top: 40px; }
    </style>
</head>
<body>

<div class="container">
    <h1>RISC-V Simulation Run Analysis</h1>
    <p><strong>Target File Resource Trace:</strong> ${LOG_NAME}</p>
    
    <div class="verdict-banner">Overall Run Status Verdict: ${VERDICT}</div>

    <div class="grid">
        <div class="card">
            <div class="card-title">Total Test Routines Run</div>
            <div class="card-value">${TOTAL}</div>
        </div>
        <div class="card pass">
            <div class="card-title">Passed Functional Modules</div>
            <div class="card-value">${PASSED}</div>
        </div>
        <div class="card fail">
            <div class="card-title">Failed Core Blocks</div>
            <div class="card-value">${FAILED}</div>
        </div>
    </div>

    <div class="grid">
        <div class="card">
            <div class="card-title">Functional Coverage Pass Rate</div>
            <div class="card-value">${RATE}%</div>
        </div>
        <div class="card">
            <div class="card-title">Average Task Execution Speed</div>
            <div class="card-value">${AVG}s</div>
        </div>
        <div class="card">
            <div class="card-title">Extreme Execution Limit Spectrum</div>
            <div class="card-value">${MIN}s (Min) / ${MAX}s (Max)</div>
        </div>
    </div>
    
    <p class="footer">Dashboard pipeline automatically generated via MEDS Build System at $(date).</p>
</div>

</body>
</html>
EOF

exit 0
