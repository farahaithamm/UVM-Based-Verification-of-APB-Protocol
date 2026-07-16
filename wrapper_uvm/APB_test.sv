package APB_Test_pkg;
import uvm_pkg::*;
import APB_env_pkg::*;
import APB_sequences_pkg::*;
`include "uvm_macros.svh"

class APB_Test extends uvm_test;
    `uvm_component_utils(APB_Test)

    APB_env env;
    APB_reset_sequence reset_seq;
    APB_write_sequence write_seq;
    APB_read_sequence read_seq;
    APB_read_write_sequence rw_seq;
    virtual intf vif;

    function new(string name = "APB_Test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = APB_env::type_id::create("env", this);
        reset_seq = APB_reset_sequence::type_id::create("reset_seq");
        write_seq = APB_write_sequence::type_id::create("write_seq");
        read_seq = APB_read_sequence::type_id::create("read_seq");
        rw_seq = APB_read_write_sequence::type_id::create("rw_seq");  
        if (!uvm_config_db #(virtual intf)::get(this, "", "my_vif", vif)) begin
            `uvm_fatal(get_full_name(), "Test - Unable to get the virtual interface")
        end 

        uvm_config_db #(virtual intf)::set(this, "env", "my_vif", vif);

    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        reset_seq.start(env.ag.sqr);
        write_seq.start(env.ag.sqr);
        read_seq.start(env.ag.sqr);
        rw_seq.start(env.ag.sqr);
        phase.drop_objection(this);
    endtask
endclass
endpackage