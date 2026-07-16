package APB_subscriber_pkg;
import uvm_pkg::*;
import APB_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_subscriber extends uvm_subscriber #(APB_seq_item);
    `uvm_component_utils(APB_subscriber)
    APB_seq_item seq_item;

    covergroup cg;
        PRESETn_cp : coverpoint seq_item.PRESETn{
            bins rst_on = {0};
            bins rst_off = {1};
            bins rst_on_to_off = (0 => 1);
            bins rst_off_to_on = (1 => 0);
        }
        addr_cp : coverpoint seq_item.addr{
            bins valid_addr[] = {[0:127]};
            // illegal_bins invalid_addr = default;
        }
        sel_cp : coverpoint seq_item.sel;
        transfer_cp : coverpoint seq_item.transfer;
        wr_en_cp : coverpoint seq_item.wr_en;
        strb_cp : coverpoint seq_item.strb;
        valid_out_cp : coverpoint seq_item.valid_out;
        PSLVERR_cp: coverpoint seq_item.PSLVERR;

        sel_trans_crp: cross sel_cp, transfer_cp;
        sel_wr_crp: cross sel_cp, wr_en_cp;
        sel_strb_crp: cross sel_cp, strb_cp;
        sel_valid_crp: cross sel_cp, valid_out_cp;
        sel_PSLVERR_crp: cross sel_cp, PSLVERR_cp;
        sel_addr_crp: cross sel_cp, addr_cp;
    endgroup 

    function new(string name = "APB_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg = new;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq_item = APB_seq_item::type_id::create("seq_item", this);
    endfunction

    function void write (APB_seq_item t);
        seq_item = t;
        cg.sample();
    endfunction
endclass
endpackage