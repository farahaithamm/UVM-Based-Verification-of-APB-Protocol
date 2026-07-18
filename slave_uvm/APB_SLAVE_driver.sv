package APB_SLAVE_driver_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_driver extends uvm_driver #(APB_SLAVE_seq_item);
    `uvm_component_utils(APB_SLAVE_driver)

    virtual intf vif;
    APB_SLAVE_seq_item seq_item;

    function new(string name = "APB_SLAVE_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual intf)::get(this, "", "my_vif", vif))
            `uvm_fatal(get_full_name(), "Driver - Unable to get the virtual interface")
    
        
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item");

    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(seq_item);
            vif.drv_cb.PRESETn <= seq_item.PRESETn;
            vif.drv_cb.PADDR <= seq_item.PADDR;
            vif.drv_cb.PSEL <= 1'b1;
            vif.drv_cb.PENABLE <= 1'b0;
            vif.drv_cb.PWRITE <= seq_item.PWRITE;
            vif.drv_cb.PWDATA <= seq_item.PWDATA;
            vif.drv_cb.PSTRB <= seq_item.PSTRB;
            @(vif.drv_cb);
            vif.drv_cb.PENABLE <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.PSEL <= 1'b0;
            vif.drv_cb.PENABLE <= 1'b0;
            @(vif.drv_cb);
            seq_item_port.item_done();
        end
    endtask
endclass
endpackage