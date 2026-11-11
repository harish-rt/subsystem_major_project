import os
import subprocess
import time
import datetime
import random
import re
import csv
import sys
 
# ------------------------------------------------------------
# Tag-based test selection
# Usage:
#   python3 regression.py sanity
#   python3 regression.py sanity2
#   python3 regression.py full_regression
# ------------------------------------------------------------

MAIL_LIST = [
    #"jaganathan.s@raitonsemi.com",
    #"anusuya.b@raitonsemi.com",
    "harish@raitonsemi.com"
]
 
TEST_TAGS = {
    "sanity": [
        "sg_mode_incr_test",
        "simple_mode_rd_fixed_test",
        "simple_mode_wr_fixed_test",
        "simple_mode_rd_wr_fixed_test",
        "simple_mode_b2b_ioc_test",
        "simple_mode_b2b_test",
        "simple_mode_sa_da_unalignment_test",
        "simple_mode_da_unalignment_test",
        "simple_mode_sa_unalignment_test", 
        "simple_mode_sa_da_alignment_test",
        "simple_mode_btt_check_aligned_16b_test",
        "simple_mode_btt_check_aligned_17b_test",
        "simple_mode_btt_check_unaligned_15b_test"
    ],
    "sanity2": [
        "sg_mode_internal_error_test",
        "simple_mode_b2b_test",
        "simple_mode_4k_boundary_test",
        "simple_mode_btt_check_aligned_17b_test",
        "sg_mode_rd_fixed_test",
        "sg_mode_delay_interrupt_test",
        "sg_mode_wr_fixed_test"
    ],
    "full_regression": [
        "simple_mode_incr_transfer_test",
        "simple_mode_rd_fixed_test",
        "simple_mode_wr_fixed_test",
        "simple_mode_rd_wr_fixed_test",
        "simple_mode_b2b_ioc_test",
        "simple_mode_b2b_test",
        "simple_mode_sa_da_unalignment_test",
        "simple_mode_da_unalignment_test",
        "simple_mode_sa_unalignment_test", 
        "simple_mode_sa_da_alignment_test",
        "simple_mode_btt_check_aligned_16b_test",
        "simple_mode_btt_check_aligned_17b_test",
        "simple_mode_btt_check_unaligned_15b_test",
        "simple_mode_btt_check_unaligned_1b_test",
        "simple_mode_btt_check_sa_unaligned_16b_test",
        "simple_mode_btt_check_da_unaligned_16b_test",
        "simple_mode_btt_check_aligned_32b_test",
        "simple_mode_btt_check_stress_64b_test",
        "simple_mode_4k_boundary_test",
        "simple_mode_4k_check_test",
        "simple_dma_int_error_test",
        "simple_dma_decode_error_test",
        "simple_dma_slave_error_test",
    
        "sg_mode_incr_test",
        "sg_mode_rd_fixed_test",
        "sg_mode_wr_fixed_test",
        "sg_mode_rd_wr_fixed_test",
        "sg_mode_rresp_decode_error_test",
        "sg_mode_bresp_decode_error_test",
        "sg_mode_rresp_slave_error_test",
        "sg_mode_bresp_slave_error_test",
        "sg_mode_internal_error_test",
        "sg_dma_rresp_decode_error_test",
        "sg_dma_bresp_decode_error_test",
        "sg_dma_rresp_slave_error_test",
        "sg_dma_bresp_slave_error_test",
        "sg_dma_internal_error_test",
        "sg_mode_delay_interrupt_test",
        "sg_mode_threshold_interrupt_test",
        "sg_cyclic_bd_test"
    ]
}
 
if len(sys.argv) != 2:
    print("Usage: python regression.py <sanity|sanity2|full_regression>")
    sys.exit(1)
 
tag = sys.argv[1]
 
if tag not in TEST_TAGS:
    print(f"Unknown tag: {tag}")
    print("Available tags:", ", ".join(TEST_TAGS.keys()))
    sys.exit(1)
 
test_list = TEST_TAGS[tag]
 
print(f"Running tag: {tag}")
print(f"Total tests: {len(test_list)}")
 

# Ensure compile.do has coverage flags enabled (e.g., alog -coverage all ...)
vsim_base_cmd = (
    "vsim -c +access +r +m+top +UVM_OBJECTION_TRACE "
    "-L unisims_ver -L unimacro_ver -L secureip -L xpm "
    "-L axi_datamover_v5_1_37 -L axi_sg_v4_1_21 -L axi_cdma_v4_1_35 "
    "-L xil_defaultlib -O0 xil_defaultlib.top xil_defaultlib.glbl "
)

# Create timestamped directories
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

master_run_dir = f"regression_run_{timestamp}_{tag}"
os.makedirs(master_run_dir, exist_ok=True)

log_dir = os.path.join(master_run_dir, "logs")
report_dir = os.path.join(master_run_dir, "reports")
cov_dir = os.path.join(master_run_dir, "coverage")

os.makedirs(log_dir, exist_ok=True)
os.makedirs(report_dir, exist_ok=True)
os.makedirs(cov_dir, exist_ok=True)

print(f"Created workspace: {master_run_dir}/")

# Regex for parsing UVM summary
err_re = re.compile(r'UVM_ERROR\s*:\s*(\d+)')
fatal_re = re.compile(r'UVM_FATAL\s*:\s*(\d+)')
warn_re = re.compile(r'UVM_WARNING\s*:\s*(\d+)')


def execute_with_license_wait(command, phase_name, wait_seconds=3):
    """
    Executes a shell command and retries if an Aldec license error is detected.
    """
    print("==================================================")
    print(f" {phase_name}")
    print("==================================================")
    
    while True:
        # Run the command and capture output
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        
        # Combine stdout and stderr for comprehensive error checking
        output = result.stdout + result.stderr
        output_lower = output.lower()
        
        # Check for common Aldec Riviera license error signatures
        # Note: You can add more specific error strings here based on your log files
        license_errors = ["valid license", "license checkout failed", "cannot checkout", "aldec_license_file"]
        
        if any(err in output_lower for err in license_errors):
            print(f"[Wait Phase] License unavailable for '{phase_name}'.")
            print(f"Waiting {wait_seconds} seconds before retrying...")
            time.sleep(wait_seconds)
            continue # Loop back and try the command again
            
        # If the command failed for a reason OTHER than a license issue
        elif result.returncode != 0:
            print(output)
            print(f"CRITICAL ERROR: '{phase_name}' failed due to a compilation/simulation error.")
            sys.exit(1)
            
        # If execution was successful
        else:
            print(result.stdout)
            print(f"\n--- {phase_name} Finished Successfully ---")
            
            # Optional brief pause to ensure the server fully releases the license 
            # before the next phase requests it again
            time.sleep(3) 
            break

# ---------------------------------------------------------
# Main Regression Flow
# ---------------------------------------------------------

if __name__ == "__main__":
    
    # Phase 1: Compilation
    compile_cmd = 'vsim -c -do "do compile.do; quit -force"'
    execute_with_license_wait(compile_cmd, "Phase 1: Compiling Design and Testbench")
    


# -------------------------------------------------------------------------
# Phase 1: Compilation
# -------------------------------------------------------------------------
print("==================================================")
print(" Phase 1: Compiling Design and Testbench")
print("==================================================")

#compile_cmd = 'vsim -c -do "do compile.do; quit -force"'
#comp_result = subprocess.run(compile_cmd, shell=True, capture_output=True, text=True)
#
#print(comp_result.stdout)
#
#if "valid license" in comp_result.stdout or "valid license" in comp_result.stderr:
#    print("CRITICAL ERROR: License checkout failed during compilation.")
#    exit(1)
#
#print("\n--- Compilation Finished. Waiting 3s for license release ---")
#time.sleep(3)

# -------------------------------------------------------------------------
# Phase 2: Execution & Coverage Extraction
# -------------------------------------------------------------------------
print("\n==================================================")
print(" Phase 2: Running Regression & Saving Coverage")
print("==================================================")

results = []
valid_acdbs = [] # Only track coverage files for tests that pass
total_tests = len(test_list)
passed_tests = 0
failed_tests = 0

regression_start_time = time.time()

for idx, test in enumerate(test_list, 1):
    seed = random.randint(1, 9999999)
    log_file = os.path.join(log_dir, f"{test}_{seed}.log")
    cov_file = os.path.join(cov_dir, f"{test}_{seed}.acdb")
    
    print(f"[{idx}/{total_tests}] Running: {test:<30} (Seed: {seed}) ... ", end="", flush=True)
    
    # UVM run and coverage dump in one TCL sequence
    do_commands = f"run -all; acdb save -o {cov_file}; quit -force"
    run_cmd = f'{vsim_base_cmd} -sv_seed {seed} +UVM_TESTNAME={test} -l {log_file} -do "{do_commands}"'
    
    test_start_time = time.time()
    subprocess.run(run_cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    test_duration = time.time() - test_start_time
    
    status = "FAIL"
    errors, fatals, warnings = -1, -1, -1
    reason = "Unknown"

    wait_time = 0;
    while not os.path.exists(log_file) and wait_time < 60:
        time.sleep(3)
        wait_time = wait_time + 1

    try:
        with open(log_file, "r") as f:
            log_content = f.read()
            
            if "valid license" in log_content:
                reason = "License Error"
            else:
                err_match = err_re.search(log_content)
                fatal_match = fatal_re.search(log_content)
                warn_match = warn_re.search(log_content)
                
                if err_match and fatal_match:
                    errors = int(err_match.group(1))
                    fatals = int(fatal_match.group(1))
                    warnings = int(warn_match.group(1)) if warn_match else 0
                    
                    if errors == 0 and fatals == 0:
                        status = "PASS"
                        reason = "-"
                        # Verify the coverage file was actually created before appending
                        if os.path.exists(cov_file):
                            valid_acdbs.append(cov_file)
                    else:
                        reason = "UVM Errors/Fatals"
                else:
                    reason = "Simulation Crashed/Hanged"
                    
    except FileNotFoundError:
        reason = "Log File Missing"

    if status == "PASS":
        passed_tests += 1
        print(f"PASS ({test_duration:.1f}s)")
    else:
        failed_tests += 1
        print(f"FAIL ({test_duration:.1f}s) - {reason}")
        
    results.append({
        "Test Name": test,
        "Status": status,
        "Seed": seed,
        "Errors": errors if errors != -1 else "N/A",
        "Warnings": warnings if warnings != -1 else "N/A",
        "Duration (s)": round(test_duration, 2),
        "Reason": reason,
        "Coverage DB": cov_file if status == "PASS" else "N/A"
    })
    
    time.sleep(2)

regression_duration = time.time() - regression_start_time

# -------------------------------------------------------------------------
# Phase 3: Coverage Merging & Report Generation
# -------------------------------------------------------------------------
print("\n==================================================")
print(" Phase 3: Merging Coverage Databases")
print("==================================================")

merged_acdb_path = "N/A"

if valid_acdbs:
    merged_acdb_path = os.path.join(cov_dir, "merged_cdma.acdb")
    
    # Construct input arguments safely: "-i file1.acdb -i file2.acdb"
    merge_inputs = " ".join([f"-i {f}" for f in valid_acdbs])
    
    tcl_merge_cmd = f"acdb merge -o {merged_acdb_path} {merge_inputs}; quit -force"
    vsim_merge_cmd = f'vsim -c -do "{tcl_merge_cmd}"'
    
    print(f"Merging {len(valid_acdbs)} successful databases via vsim...")
    merge_result = subprocess.run(vsim_merge_cmd, shell=True, capture_output=True, text=True)
    
    if os.path.exists(merged_acdb_path):
        print(f"Coverage successfully merged into: {merged_acdb_path}")
        
        # Phase 3.1: HTML Report Generation via vsim Engine
        print("\n==================================================")
        print(" Phase 3.1: HTML file for Merged ACDB file")
        print("==================================================")
        
        html_report_dir = os.path.join(cov_dir, "html_coverage_report")
        
        tcl_report_cmd = f"acdb report -i {merged_acdb_path} -html -o {html_report_dir}; quit -force"
        vsim_report_cmd = f'vsim -c -do "{tcl_report_cmd}"'
        
        print(f"Generating HTML coverage report folder at: {html_report_dir}...")
        report_result = subprocess.run(vsim_report_cmd, shell=True, capture_output=True, text=True)
        
        index_file = os.path.join(html_report_dir, "index.html")
        if os.path.exists(index_file):
            print(f"HTML report generated successfully! Open this file to view: {index_file}")
        else:
            print("HTML generation failed. Command output logs:")
            print(report_result.stderr)
            print(report_result.stdout)
            
    else:
        print("Error merging coverage databases. Check output:")
        print(merge_result.stdout)
else:
    print("No successful tests to merge coverage for.")

# -------------------------------------------------------------------------
# Phase 4: Regression Summary Generation
# -------------------------------------------------------------------------
print("\n==================================================")
print(" Phase 4: Regression Summary")
print("==================================================")

pass_rate = (passed_tests / total_tests) * 100

print(f"{'Test Name':<32} | {'Status':<6} | {'Seed':<8} | {'Err/Warn':<8} | {'Time(s)'}")
print("-" * 75)
for r in results:
    err_warn = f"{r['Errors']}/{r['Warnings']}"
    print(f"{r['Test Name']:<32} | {r['Status']:<6} | {r['Seed']:<8} | {err_warn:<8} | {r['Duration (s)']}")
print("-" * 75)
print(f"Total: {total_tests} | Passed: {passed_tests} | Failed: {failed_tests} | Pass Rate: {pass_rate:.1f}%")

# Generate CSV
csv_file = os.path.join(report_dir, "regression_report.csv")
with open(csv_file, mode='w', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)

# Generate HTML Dashboard
html_file = os.path.join(report_dir, "regression_report.html")
html_content = f"""
<!DOCTYPE html>
<html>
<head>
<title>UVM Regression & Coverage Report</title>
<style>
    body {{ font-family: Arial, sans-serif; margin: 20px; background-color: #f4f7f6; }}
    h1 {{ color: #333; }}
    .summary {{ background: #fff; padding: 15px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 20px; line-height: 1.6; }}
    .summary span {{ margin-right: 20px; font-weight: bold; }}
    .pass-rate {{ color: {'green' if pass_rate == 100 else 'red'}; font-size: 1.2em; }}
    table {{ width: 100%; border-collapse: collapse; background: #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }}
    th, td {{ padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }}
    th {{ background-color: #0056b3; color: white; }}
    tr:hover {{ background-color: #f1f1f1; }}
    .PASS {{ color: green; font-weight: bold; }}
    .FAIL {{ color: red; font-weight: bold; }}
</style>
</head>
<body>
    <h1>UVM Regression Report</h1>
    <div class="summary">
        <div>
            <span>Date: {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</span>
            <span>Duration: {regression_duration:.1f}s</span>
        </div>
        <div>
            <span>Total Tests: {total_tests}</span>
            <span class="PASS">Passed: {passed_tests}</span>
            <span class="FAIL">Failed: {failed_tests}</span>
            <span class="pass-rate">Pass Rate: {pass_rate:.1f}%</span>
        </div>
        <div>
            <span>Merged Coverage DB: {merged_acdb_path}</span>
        </div>
    </div>
    <table>
        <tr>
            <th>Test Name</th>
            <th>Status</th>
            <th>Seed</th>
            <th>Errors</th>
            <th>Warnings</th>
            <th>Time (s)</th>
            <th>Failure Reason</th>
        </tr>
"""

for r in results:
    html_content += f"""
        <tr>
            <td>{r['Test Name']}</td>
            <td class="{r['Status']}">{r['Status']}</td>
            <td>{r['Seed']}</td>
            <td>{r['Errors']}</td>
            <td>{r['Warnings']}</td>
            <td>{r['Duration (s)']}</td>
            <td>{r['Reason']}</td>
        </tr>
    """

html_content += """
    </table>
</body>
</html>
"""

with open(html_file, "w") as file:
    file.write(html_content)

print(f"\n Artifacts saved:")
print(f"   - Reports: ./{report_dir}/")
print(f"   - Logs: ./{log_dir}/")
print(f"   - Coverage DBs: ./{cov_dir}/")

#print("\n==================================================")
#print(" Phase 4.1: Coverage HTML zip for Email Report")
#print("==================================================") 
#
#coverage_zip = f"coverage_archive_{timestamp}.zip"
#zip_cmd = f'zip -r {coverage_zip} {cov_dir} -x "*.acdb"'
#print(f"Compressing {cov_dir} into archive...")
#subprocess.run(zip_cmd, shell=True)

# E-Mail added

print("\n==================================================")
print(" Phase 5: Sending Email Report")
print("==================================================") 

subject = f"UVM Regression Report : {tag} : {pass_rate:.1f}% PASS"
 
mail_body = f"""
Regression Completed
 
Tag            : {tag}
Total Tests    : {total_tests}
Passed         : {passed_tests}
Failed         : {failed_tests}
Pass Rate      : {pass_rate:.1f}%
 
HTML Report:
{os.path.abspath(html_file)}
 
CSV Report:
{os.path.abspath(csv_file)}

Coverage DB (Merged acdb Path):
{os.path.abspath(merged_acdb_path)}

Coverage HTML (Coverage HTML Path):
{os.path.abspath(index_file)}
"""

for mail_id in MAIL_LIST:
    cmd = (
        f'echo "{mail_body}" | '
        f'mail -s "{subject}" '
        f'-a "{html_file}" '
        f'-a "{csv_file}" '
        f'{mail_id}'
    )
    subprocess.run(cmd, shell=True)
 
print("Email sent successfully.")
