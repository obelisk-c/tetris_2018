vlib work
vlog -timescale 1ns/1ns control_data.v
vsim control_data
log {/*}
add wave {/*}


# Reset
force {enable} 0
force {clk} 0
force {resetn} 0
run 10ns
force {enable} 0
force {clk} 1
force {resetn} 0
run 10ns

# Pause
force {enable} 0
force {clk} 0
force {resetn} 1
run 10ns
force {enable} 0
force {clk} 1
force {resetn} 1
run 10ns

# Start, and wait ~18 cycles
force {enable} 1
force {clk} 0
force {resetn} 1
run 10ns
force {enable} 1
force {clk} 1
force {resetn} 1
run 10ns

force {enable} 0
force {resetn} 1
force {clk} 0 0, 1 10 -repeat 20
run 880ns

# Draw next frame# Start, and wait ~18 cycles
force {enable} 1
force {clk} 0
force {resetn} 1
run 10ns
force {enable} 1
force {clk} 1
force {resetn} 1
run 10ns

force {enable} 0
force {resetn} 1
force {clk} 0 0, 1 10 -repeat 20
run 160ns