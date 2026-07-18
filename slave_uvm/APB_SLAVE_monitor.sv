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
            @(vif.mon_cb);
            seq_item.PRESETn <= vif.mon_cb.PRESETn;
            seq_item.PADDR <= vif.mon_cb.PADDR;
            seq_item.PSEL <= vif.mon_cb.PSEL;
            seq_item.PENABLE <= vif.mon_cb.PENABLE;
            seq_item.PWRITE <= vif.mon_cb.PWRITE;
            seq_item.PWDATA <= vif.mon_cb.PWDATA;
            seq_item.PSTRB <= vif.mon_cb.PSTRB;
            seq_item.PREADY <= vif.mon_cb.PREADY;
            seq_item.PRDATA <= vif.mon_cb.PRDATA;
            seq_item.PSLVERR <= vif.mon_cb.PSLVERR;
            #1step ap.write(seq_item);
        end
    endtask
endclass
endpackage