

# Clean previous work
vdel -all
vlib work

# Compile DUT with coverage
vlog -cover bcst -sv design.sv

# Compile testbench/top
vlog -sv top.sv

# Simulate with coverage enabled
vsim -coverage top_testbench

# Run simulation
run -all

# Generate coverage report for the DUT
coverage report -details -srcfile=design.sv

# Save coverage database
coverage save mac_coverage.ucdb

#quit
