package APB_MASTER_scoreboard_pkg;
import uvm_pkg::*;
import APB_MASTER_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(APB_MASTER_scoreboard)

    uvm_analysis_imp #(APB_MASTER_seq_item, APB_MASTER_scoreboard) imp;

    typedef enum logic[1:0] {IDLE, SETUP, ACCESS} states_e;

    int match_cnt;
    int mismatch_cnt;
    logic [31:0] expected_rdata;
    states_e cs, cs_before;    

    function new(string name = "APB_MASTER_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
        match_cnt = 0;
        mismatch_cnt = 0;
        cs = IDLE;
    endfunction

    function void write(APB_MASTER_seq_item t);
        if(t.PSEL != {t.sel,~t.sel}) begin
            `uvm_error("SCB","Wrong PSEL");
            mismatch_cnt++;
        end
        else match_cnt++;

        if(t.PADDR != t.addr) begin
            `uvm_error("SCB","Wrong PADDR");
            mismatch_cnt++;
        end
        else match_cnt++;

        if(t.PWRITE != t.wr_en) begin
            `uvm_error("SCB","Wrong PWRITE");
            mismatch_cnt++;
        end
        else match_cnt++;

        if(t.PWDATA != t.wdata) begin
            `uvm_error("SCB","Wrong PWDATA");
            mismatch_cnt++;
        end
        else match_cnt++;

        if(t.PSTRB != t.strb) begin
            `uvm_error("SCB","Wrong PSTRB");
            mismatch_cnt++;
        end
        else match_cnt++;
            
        if (!t.PRESETn) begin
            cs = IDLE;
            cs_before = IDLE;
        end
        else begin
            cs_before = cs;
            if(cs_before == IDLE && t.transfer) cs = SETUP;
            else if(cs_before == SETUP) cs = ACCESS;
            else if(cs_before == ACCESS) begin
                if (t.PREADY) cs = (t.transfer) ? SETUP : IDLE;
                else cs = ACCESS;
            end
            else cs = IDLE;
            
            if(t.PREADY && !t.PSLVERR && !t.wr_en && cs_before == ACCESS) begin
                if (!t.valid_out) begin
                    `uvm_error("SCB", $sformatf(
                        "Expected valid_out=1 for read @addr=%0h sel=%0d, got 0",
                        t.addr, t.sel))
                    mismatch_cnt++;
                end
                else begin
                    // `uvm_info("SCB", "true valid out, t 1", UVM_HIGH)
                    match_cnt++;
                end
                if(t.OUTDATA !== t.PRDATA) begin
                    `uvm_error("SCB", $sformatf(
                        "EXPECTED OUTPUT == PRDATA for read @addr=%0h sel=%0d, got OUTDATA=%h PRDATA=%h", 
                        t.addr, t.sel, t.OUTDATA,t.PRDATA));
                    mismatch_cnt++;
                end
                else match_cnt++;
                if(!t.PENABLE) begin
                    `uvm_error("SCB",$sformatf(
                        "Expected PENABLE=1 for read @addr=%0h sel=%0d, got 0",
                        t.addr, t.sel));
                    mismatch_cnt++;
                end
                else match_cnt++;
            end
            else begin
                if (t.valid_out) begin
                    `uvm_error("SCB", "Expected valid_out=0, got 1")
                    mismatch_cnt++;
                end
                else begin
                    // `uvm_info("SCB", "true valid out, t 0", UVM_HIGH)
                    match_cnt++;
                end
                if(t.OUTDATA != 0) begin
                    `uvm_error("SCB", $sformatf(
                        "EXPECTED OUTPUT == 0, got OUTDATA=%h", 
                        t.OUTDATA));
                    mismatch_cnt++;
                end
                else match_cnt++;
                if(cs_before == ACCESS) begin
                    if(!t.PENABLE) begin
                        `uvm_error("SCB","PENABLE should be high at ACCESS");
                        mismatch_cnt++;
                    end
                    else match_cnt++;
                end
                else begin
                    if(t.PENABLE) begin
                        `uvm_error("SCB","PENABLE should be low in any state but ACCESS && !SLVERR");
                        mismatch_cnt++;
                    end
                    else match_cnt++;
                end
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf("Total match=%0d mismatch=%0d",
            match_cnt, mismatch_cnt), UVM_LOW)
    endfunction

endclass
endpackage