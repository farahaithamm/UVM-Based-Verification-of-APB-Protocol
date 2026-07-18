package APB_SLAVE_env_pkg;
import uvm_pkg::*;
import APB_SLAVE_agent_pkg::*;
import APB_SLAVE_scoreboard_pkg::*;
import APB_SLAVE_subscriber_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_env extends uvm_env;
    `uvm_component_utils(APB_SLAVE_env)

    APB_SLAVE_agent ag;
    APB_SLAVE_scoreboard sc;
    APB_SLAVE_subscriber sub;

    virtual intf vif;

    function new(string name = "APB_SLAVE_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ag = APB_SLAVE_agent::type_id::create("ag", this);
        sc = APB_SLAVE_scoreboard::type_id::create("sc", this);
        sub = APB_SLAVE_subscriber::type_id::create("sub", this);

        if (!uvm_config_db #(virtual intf)::get(this, "", "my_vif", vif)) 
            `uvm_fatal(get_full_name(), "Env - Unable to get the virtual interface")

        uvm_config_db #(virtual intf)::set(this, "ag", "my_vif", vif);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        ag.ap.connect(sc.imp);
        ag.ap.connect(sub.analysis_export);
    endfunction
endclass
endpackage