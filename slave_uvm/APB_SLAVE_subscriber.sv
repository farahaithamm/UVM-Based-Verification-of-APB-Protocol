package APB_SLAVE_subscriber_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_subscriber extends uvm_subscriber #(APB_SLAVE_seq_item);
    `uvm_component_utils(APB_SLAVE_subscriber)
    APB_SLAVE_seq_item seq_item;

    covergroup cg;
        PRESETn_cp : coverpoint seq_item.PRESETn{
            bins rst_on = {0};
            bins rst_off = {1};
            bins rst_on_to_off = (0 => 1);
            bins rst_off_to_on = (1 => 0);
        }
        addr_cp : coverpoint seq_item.PADDR{
            bins valid_addr[] = {[0:127]};
            bins invalid_addr = {[128:$]};
        }
        sel_cp : coverpoint seq_item.PSEL;
        en_cp : coverpoint seq_item.PENABLE;
        wr_en_cp : coverpoint seq_item.PWRITE;
        strb_cp : coverpoint seq_item.PSTRB{
            bins wr_strb[] = {[1:15]};
            bins rd_strb = {0};
        }
        ready_cp : coverpoint seq_item.PREADY;
        slverr_cp : coverpoint seq_item.PSLVERR;

        wr_addr_crp: cross wr_en_cp, addr_cp;
        sel_en_crp: cross sel_cp, en_cp{
            ignore_bins en_nsel = binsof(sel_cp) intersect {0} && binsof(en_cp) intersect {1};
        }
        wr_strb_crp: cross strb_cp, wr_en_cp{
            bins wr_strb = binsof(wr_en_cp) intersect {1} && binsof(strb_cp.wr_strb);
            bins rd_strb = binsof(wr_en_cp) intersect {0} && binsof(strb_cp.rd_strb);
            illegal_bins invalid_wr = binsof(wr_en_cp) intersect {1} && binsof(strb_cp.rd_strb);
            illegal_bins invalid_rd = binsof(wr_en_cp) intersect {0} && binsof(strb_cp.wr_strb);
        }
        sel_addr_crp: cross addr_cp, sel_cp{
            bins wr_strb = binsof(sel_cp) intersect {1} && binsof(addr_cp.valid_addr);
        }
        ready_slverr_crp: cross ready_cp, slverr_cp{
            illegal_bins nready_slverr = binsof(ready_cp) intersect {0} && binsof(slverr_cp) intersect {1};
        }
        addr_slverr_crp : cross addr_cp, slverr_cp iff(seq_item.PREADY){
            bins high_slv_invalid_addr = binsof(slverr_cp) intersect {1} && binsof(addr_cp.invalid_addr);
            bins low_slv_valid_addr = binsof(slverr_cp) intersect {0} && binsof(addr_cp.valid_addr);
            illegal_bins high_slv_valid_addr = binsof(slverr_cp) intersect {1} && binsof(addr_cp.valid_addr);
            illegal_bins low_slv_invalid_addr = binsof(slverr_cp) intersect {0} && binsof(addr_cp.invalid_addr);
        }
        wr_err_crp : cross wr_en_cp, slverr_cp;
    endgroup 

    function new(string name = "APB_SLAVE_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg = new;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item", this);
    endfunction

    function void write (APB_SLAVE_seq_item t);
        seq_item = t;
        cg.sample();
    endfunction
endclass
endpackage