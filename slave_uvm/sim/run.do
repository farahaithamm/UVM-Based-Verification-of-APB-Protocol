vlib work
vsim -voptargs=+acc work.APB_SLAVE_top -cover -classdebug -uvmcontrol=all +UVM_VERBOSITY=UVM_HIGH
add wave /APB_SLAVE_top/dut/*
add wave -position insertpoint  \
sim:/APB_SLAVE_top/dut/mem
run -all
coverage report -details -output coverage.txt
coverage save coverage.ucdb