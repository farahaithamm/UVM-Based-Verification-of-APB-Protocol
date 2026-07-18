vlib work
vsim -voptargs=+acc work.APB_MASTER_top -cover -classdebug -uvmcontrol=all +UVM_VERBOSITY=UVM_HIGH
add wave /APB_MASTER_top/dut/*
run -all
coverage report -details -output coverage.txt
coverage save coverage.ucdb