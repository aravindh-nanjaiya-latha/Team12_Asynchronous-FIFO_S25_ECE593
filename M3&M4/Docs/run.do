vlib work
vlog -coveropt 3 +cover +acc design.sv top.sv

vopt top_tb -o top_optimized  +acc +cover=sbfec+asynchronous_fifo(rtl).
vsim top_optimized -coverage +UVM_VERBOSITY=UVM_HIGH
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
add wave -r sim:/top_tb/*
run -all

coverage save full_empty_cov.ucdb
vcover report full_empty_cov.ucdb 
vcover merge -out Final_cov.ucdb full_empty_cov.ucdb cov.ucdb
vcover report Final_cov.ucdb -cvg -details
quit -sim

