package APB_MASTER_monitor_pkg;
    import uvm_pkg::*;
    import APB_MASTER_transaction_pkg::*;
    `include "uvm_macros.svh"

    class APB_MASTER_monitor extends uvm_monitor;
        `uvm_component_utils(APB_MASTER_monitor)

        APB_MASTER_seq_item seq_item;
        virtual intf vif;

        uvm_analysis_port#(APB_MASTER_seq_item) ap;

        function new(string name = "APB_MASTER_monitor", uvm_component parent = null);
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
                seq_item = APB_MASTER_seq_item::type_id::create("seq_item", this);
                @(vif.mon_cb);
                seq_item.PRESETn <= vif.mon_cb.PRESETn;
                seq_item.addr <= vif.mon_cb.addr;
                seq_item.sel <= vif.mon_cb.sel;
                seq_item.transfer <= vif.mon_cb.transfer;
                seq_item.wr_en <= vif.mon_cb.wr_en;
                seq_item.wdata <= vif.mon_cb.wdata;
                seq_item.strb <= vif.mon_cb.strb;
                seq_item.PREADY <= vif.mon_cb.PREADY;
                seq_item.PRDATA <= vif.mon_cb.PRDATA;
                seq_item.PSLVERR <= vif.mon_cb.PSLVERR;
                seq_item.OUTDATA <= vif.mon_cb.OUTDATA;
                seq_item.valid_out <= vif.mon_cb.valid_out;
                seq_item.PADDR <= vif.mon_cb.PADDR;
                seq_item.PSEL <= vif.mon_cb.PSEL;
                seq_item.PENABLE <= vif.mon_cb.PENABLE;
                seq_item.PWRITE <= vif.mon_cb.PWRITE;
                seq_item.PWDATA <= vif.mon_cb.PWDATA;
                seq_item.PSTRB <= vif.mon_cb.PSTRB;
                #1step ap.write(seq_item);
            end
        endtask
    endclass
endpackage