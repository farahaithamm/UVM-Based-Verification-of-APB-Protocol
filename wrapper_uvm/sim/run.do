vlib work
vsim -voptargs=+acc work.APB_top -cover -classdebug -uvmcontrol=all +UVM_VERBOSITY=UVM_HIGH
add wave /APB_top/dut/*
add wave -position insertpoint  \
sim:/APB_top/dut/master/cs \
sim:/APB_top/dut/master/ns
add wave -position insertpoint  \
sim:/APB_top/dut/slave0/mem
add wave -position insertpoint  \
sim:/APB_top/dut/slave1/mem
run -all
coverage report -details -output coverage.txt
coverage save coverage.ucdb