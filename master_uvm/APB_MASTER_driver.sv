package APB_MASTER_driver_pkg;
import uvm_pkg::*;
import APB_MASTER_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_driver extends uvm_driver #(APB_MASTER_seq_item);
    `uvm_component_utils(APB_MASTER_driver)

    virtual intf vif;
    APB_MASTER_seq_item seq_item;

    function new(string name = "APB_MASTER_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq_item = APB_MASTER_seq_item::type_id::create("seq_item");

        if (!uvm_config_db#(virtual intf)::get(this, "", "my_vif", vif))
            `uvm_fatal(get_full_name(), "Driver - Unable to get the virtual interface")

    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(seq_item);
            vif.drv_cb.PRESETn <= seq_item.PRESETn;
            vif.drv_cb.addr <= seq_item.addr;
            vif.drv_cb.sel <= seq_item.sel;
            vif.drv_cb.transfer <= seq_item.transfer;
            vif.drv_cb.wr_en <= seq_item.wr_en;
            vif.drv_cb.wdata <= seq_item.wdata;
            vif.drv_cb.strb <= seq_item.strb;
            vif.drv_cb.PREADY <= 1'b0;
            vif.drv_cb.PRDATA <= seq_item.PRDATA;
            vif.drv_cb.PSLVERR <= 1'b0;
            repeat(2) @(vif.drv_cb);
            repeat(seq_item.wait_cycles) @(vif.drv_cb);
            vif.drv_cb.PREADY <= (seq_item.PRESETn) ? 1'b1 : 1'b0;
            vif.drv_cb.PSLVERR <= (seq_item.PRESETn) ? (seq_item.addr >= 128): 1'b0;
            @(vif.drv_cb);
            seq_item_port.item_done();
        end
    endtask
endclass
endpackage