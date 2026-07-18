package APB_MASTER_subscriber_pkg;
import uvm_pkg::*;
import APB_MASTER_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_subscriber extends uvm_subscriber #(APB_MASTER_seq_item);
    `uvm_component_utils(APB_MASTER_subscriber)
    APB_MASTER_seq_item seq_item;

    covergroup cg;
        PRESETn_cp : coverpoint seq_item.PRESETn{
            bins rst_on = {0};
            bins rst_off = {1};
            bins rst_on_to_off = (0 => 1);
            bins rst_off_to_on = (1 => 0);
        }
        addr_cp : coverpoint seq_item.addr{
            bins valid_addr[] = {[0:127]};
            bins invalid_addr = {[128:$]};
        }
        sel_cp : coverpoint seq_item.sel;
        transfer_cp : coverpoint seq_item.transfer;
        wr_en_cp : coverpoint seq_item.wr_en;
        strb_cp : coverpoint seq_item.strb{
            bins wr_strb[] = {[1:15]};
            bins rd_strb = {0};
        }
        valid_out_cp : coverpoint seq_item.valid_out;
        PSLVERR_cp: coverpoint seq_item.PSLVERR;
        ready_cp : coverpoint seq_item.PREADY;
        enable_cp : coverpoint seq_item.PENABLE{
            bins low = {0};
            bins high = {1};
        }
        
        sel_trans_crp: cross sel_cp, transfer_cp;
        sel_wr_crp: cross sel_cp, wr_en_cp;
        sel_strb_crp: cross sel_cp, strb_cp;
        sel_valid_crp: cross sel_cp, valid_out_cp;
        sel_PSLVERR_crp: cross sel_cp, PSLVERR_cp;
        sel_addr_crp: cross sel_cp, addr_cp;
        addr_err_crp : cross addr_cp, PSLVERR_cp{
            option.cross_auto_bin_max = 0;
            bins valid_no_error = binsof(addr_cp.valid_addr) && binsof(PSLVERR_cp) intersect {0};
            bins invalid_err = binsof(addr_cp.invalid_addr) && binsof(PSLVERR_cp) intersect {1};   
        }
        valid_wr_crp : cross valid_out_cp, wr_en_cp{
            illegal_bins write_valid = binsof(valid_out_cp) intersect {1} && binsof(wr_en_cp) intersect {1};
        }
        ready_valid_crp : cross ready_cp, valid_out_cp{
            illegal_bins valid_not_ready = binsof(ready_cp) intersect {0} && binsof(valid_out_cp) intersect {1};
        }
        addr_transfer_crp : cross addr_cp, transfer_cp;
        wr_strb_crp: cross strb_cp, wr_en_cp{
            bins wr_strb = binsof(wr_en_cp) intersect {1} && binsof(strb_cp.wr_strb);
            bins rd_strb = binsof(wr_en_cp) intersect {0} && binsof(strb_cp.rd_strb);
            illegal_bins invalid_wr = binsof(wr_en_cp) intersect {1} && binsof(strb_cp.rd_strb);
            illegal_bins invalid_rd = binsof(wr_en_cp) intersect {0} && binsof(strb_cp.wr_strb);
        }
        transfer_ready_crp : cross transfer_cp, ready_cp;
    endgroup 

    function new(string name = "APB_MASTER_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg = new;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq_item = APB_MASTER_seq_item::type_id::create("seq_item", this);
    endfunction

    function void write (APB_MASTER_seq_item t);
        seq_item = t;
        cg.sample();
    endfunction
endclass
endpackage