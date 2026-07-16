package APB_agent_pkg;
import uvm_pkg::*;
import APB_monitor_pkg::*;
import APB_driver_pkg::*;
import APB_sequencer_pkg::*;
import APB_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_agent extends uvm_agent;
    `uvm_component_utils(APB_agent)

    APB_monitor mon;
    APB_driver drv;
    APB_sequencer sqr;

    virtual intf vif;
    uvm_analysis_port#(APB_seq_item) ap;

    function new(string name = "APB_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = APB_monitor::type_id::create("mon", this);
        drv = APB_driver::type_id::create("drv", this);
        sqr = APB_sequencer::type_id::create("sqr", this);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual intf)::get(this, "", "my_vif", vif))
            `uvm_error(get_full_name(), "Agent - Unable to get the virtual interface")

        uvm_config_db#(virtual intf)::set(this, "mon", "my_vif", vif);
        uvm_config_db#(virtual intf)::set(this, "drv", "my_vif", vif);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.ap.connect(ap);
    endfunction
endclass
endpackage