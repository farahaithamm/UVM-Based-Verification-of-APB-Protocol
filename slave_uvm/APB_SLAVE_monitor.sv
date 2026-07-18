package APB_SLAVE_monitor_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_monitor extends uvm_monitor;
    `uvm_component_utils(APB_SLAVE_monitor)

    APB_SLAVE_seq_item seq_item;
    virtual intf vif;

    uvm_analysis_port#(APB_SLAVE_seq_item) ap;

    function new(string name = "APB_SLAVE_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        
        ap = new("ap", this);

        if (!uvm_config_db#(virtual intf)::get(this, "", "my_vif", vif))
            `uvm_fatal(get_full_name(), "Monitor - Unable to get the virtual interface")
    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item = APB_SLAVE_seq_item::type_id::create("seq_item", this);
            @(vif.cb);
            seq_item.PRESETn <= vif.PRESETn;
            seq_item.PADDR <= vif.PADDR;
            seq_item.PSEL <= vif.PSEL;
            seq_item.PENABLE <= vif.PENABLE;
            seq_item.PWRITE <= vif.PWRITE;
            seq_item.PWDATA <= vif.PWDATA;
            seq_item.PSTRB <= vif.PSTRB;
            seq_item.PREADY <= vif.PREADY;
            seq_item.PRDATA <= vif.PRDATA;
            seq_item.PSLVERR <= vif.PSLVERR;
            #1step ap.write(seq_item);
        end
    endtask
endclass
endpackage