package APB_scoreboard_pkg;
import uvm_pkg::*;
import APB_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(APB_scoreboard)

    uvm_analysis_imp #(APB_seq_item, APB_scoreboard) imp;

    localparam int MEM_DEPTH = 128;
    localparam int DATA_WIDTH = 32;
    localparam int PSTRB_WIDTH = DATA_WIDTH/8;

    logic [DATA_WIDTH-1:0] ref_mem0 [MEM_DEPTH-1:0];
    logic [DATA_WIDTH-1:0] ref_mem1 [MEM_DEPTH-1:0];

    typedef enum logic[1:0] {IDLE, SETUP, ACCESS} states_e;

    int match_cnt;
    int mismatch_cnt;
    logic [DATA_WIDTH-1:0] mask;
    logic [DATA_WIDTH-1:0] expected_rdata;
    logic slverr_expected;
    states_e cs, cs_before;    

    function new(string name = "APB_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
        match_cnt = 0;
        mismatch_cnt = 0;
        cs = IDLE;
        foreach (ref_mem0[i]) ref_mem0[i] = '0;
        foreach (ref_mem1[i]) ref_mem1[i] = '0;
    endfunction

    function void write(APB_seq_item t);
        if (!t.PRESETn) begin
            foreach (ref_mem0[i]) ref_mem0[i] = '0;
            foreach (ref_mem1[i]) ref_mem1[i] = '0;
            cs = IDLE;
            cs_before = IDLE;
        end
        
        else begin
            mask = '0;
            slverr_expected = (t.addr >= MEM_DEPTH);

            cs_before = cs;
            if(cs_before == IDLE && t.transfer) cs = SETUP;
            else if(cs_before == SETUP) cs = ACCESS;
            else if(cs_before == ACCESS && t.transfer) cs = SETUP;
            else cs = IDLE;
            
            if(!slverr_expected && cs_before == ACCESS) begin
                if (t.wr_en) begin
                    for (int i = 0; i < PSTRB_WIDTH; i++) mask[(i*8) +: 8] = {8{t.strb[i]}};
                    if (t.sel == 0) ref_mem0[t.addr] = (ref_mem0[t.addr] & ~mask) | (mask & t.wdata);
                    else ref_mem1[t.addr] = (ref_mem1[t.addr] & ~mask) | (mask & t.wdata);
                end
                else begin
                    expected_rdata = (t.sel == 0) ? ref_mem0[t.addr] : ref_mem1[t.addr];
                    if (!t.valid_out) begin
                        `uvm_error("SCB", $sformatf(
                            "Expected valid_out=1 for read @addr=%0h sel=%0d, got 0",
                            t.addr, t.sel))
                        mismatch_cnt++;
                    end
                    else match_cnt++;
                    if (t.OUTDATA !== expected_rdata) begin
                        `uvm_error("SCB", $sformatf(
                            "MISMATCH @addr=%0h sel=%0d: expected=%h actual=%h",
                            t.addr, t.sel, expected_rdata, t.OUTDATA))
                        mismatch_cnt++;
                    end
                    else match_cnt++;
                    
                end
            end
            else if(slverr_expected && cs_before == ACCESS) begin
                if(!t.PSLVERR) begin
                    `uvm_error("SCB", $sformatf(
                            "Expected PSLVERR=1 for read @addr=%0h sel=%0d, got 0",
                            t.addr, t.sel))
                        mismatch_cnt++;
                end
                else match_cnt++;
                if (t.valid_out) begin
                    `uvm_error("SCB", $sformatf(
                        "Expected valid_out=0 (PSLVERR case) @addr=%0h sel=%0d, got 1",
                        t.addr, t.sel))
                    mismatch_cnt++;
                end
                else match_cnt++;
            end
            else begin
                if (t.valid_out) begin
                    `uvm_error("SCB", $sformatf(
                        "Expected valid_out=0 (PSLVERR case) @addr=%0h sel=%0d, got 1",
                        t.addr, t.sel))
                    mismatch_cnt++;
                end
                else match_cnt++;
                if(t.PSLVERR) begin
                    `uvm_error("SCB", $sformatf(
                            "Expected PSLVERR=0 for read @addr=%0h sel=%0d, got 1",
                            t.addr, t.sel))
                        mismatch_cnt++;
                end
                else match_cnt++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf("Total match=%0d mismatch=%0d",
            match_cnt, mismatch_cnt), UVM_LOW)
    endfunction

endclass
endpackage