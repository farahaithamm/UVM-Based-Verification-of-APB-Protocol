package APB_driver_pkg;
import uvm_pkg::*;
import APB_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_driver extends uvm_driver #(APB_seq_item);
    `uvm_component_utils(APB_driver)

    virtual intf vif;
    APB_seq_item seq_item;

    function new(string name = "APB_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual intf)::get(this, "", "my_vif", vif))
            `uvm_fatal(get_full_name(), "Driver - Unable to get the virtual interface")
    
        
        seq_item = APB_seq_item::type_id::create("APB_seq_item");

    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(seq_item);
            vif.PRESETn <= seq_item.PRESETn;
            vif.addr <= seq_item.addr;
            vif.sel <= seq_item.sel;
            vif.transfer <= seq_item.transfer;
            vif.wr_en <= seq_item.wr_en;
            vif.wdata <= seq_item.wdata;
            vif.strb <= seq_item.strb;
            repeat(2) @(vif.cb);
            if(seq_item.continue_transfer) @(vif.cb);
            seq_item_port.item_done();
        end
    endtask
endclass
endpackage