package APB_SLAVE_scoreboard_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(APB_SLAVE_scoreboard)

    uvm_analysis_imp #(APB_SLAVE_seq_item, APB_SLAVE_scoreboard) imp;

    logic [31:0] ref_mem [127:0];
    logic [31:0] mask, expected_rdata;
    int match_cnt = 0, mismatch_cnt = 0;
    logic slverr_expected;


    function new(string name = "APB_SLAVE_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function void write(APB_SLAVE_seq_item t);
        if (!t.PRESETn) begin
            foreach (ref_mem[i]) ref_mem[i] = '0;
        end
        
        else begin
            mask = '0;
            slverr_expected = (t.PADDR >= 128);
            if(t.PSEL && t.PENABLE) begin
                if(!slverr_expected) begin
                    if (t.PWRITE) begin
                        for (int i = 0; i < 8; i++) mask[(i*8) +: 8] = {8{t.PSTRB[i]}};
                        ref_mem[t.PADDR] = (ref_mem[t.PADDR] & ~mask) | (mask & t.PWDATA);
                        // `uvm_info("SCB",
                        // $sformatf("WRITE PADDR=%0h PSEL=%0d PSTRB=%b PWDATA=%h new=%h",
                        // t.PADDR,
                        // t.PSEL,
                        // t.PSTRB,
                        // t.PWDATA,
                        // ref_mem[t.PADDR]),
                        // UVM_HIGH)
                    end
                    else begin
                        expected_rdata = ref_mem[t.PADDR];
                        if (!t.PREADY) begin
                            `uvm_error("SCB", $sformatf(
                                "Expected PREADY=1 for read @PADDR=%0h PSEL=%0d, got 0",
                                t.PADDR, t.PSEL))
                            mismatch_cnt++;
                        end
                        else begin
                            // `uvm_info("SCB", "true PREADY, t 1", UVM_HIGH)
                            match_cnt++;
                        end
                        if (t.PRDATA !== expected_rdata) begin
                            `uvm_error("SCB", $sformatf(
                                "MISMATCH @PADDR=%0h PSEL=%0d: expected=%h actual=%h",
                                t.PADDR, t.PSEL, expected_rdata, t.PRDATA))
                            mismatch_cnt++;
                        end
                        else begin
                            // `uvm_info("SCB", "true data out t 1", UVM_HIGH)
                            match_cnt++;
                        end
                    end
                    if(t.PSLVERR) begin
                        `uvm_error("SCB", $sformatf(
                                "Expected PSLVERR=0 for read @PADDR=%0h PSEL=%0d, got 1",
                                t.PADDR, t.PSEL))
                            mismatch_cnt++;
                    end
                    else begin
                        // `uvm_info("SCB", $sformatf(
                        //         "PSLVERR=0 for read @PADDR=%0h PSEL=%0d",
                        //         t.PADDR, t.PSEL), UVM_HIGH)
                        match_cnt++;
                    end
                    if (!t.PREADY) begin
                        `uvm_error("SCB", $sformatf(
                            "Expected PREADY=1 @PADDR=%0h PSEL=%0d, got 0",
                            t.PADDR, t.PSEL))
                        mismatch_cnt++;
                    end
                    else begin
                        // `uvm_info("SCB", "true valid out, t 0", UVM_HIGH)
                        // `uvm_info("SCB",
                        // $sformatf("else  PADDR=%0h PSEL=%0d PSTRB=%b PWDATA=%h",
                        // t.PADDR,
                        // t.PSEL,
                        // t.PSTRB,
                        // t.PWDATA),
                        // UVM_HIGH)
                        match_cnt++;
                    end
                end
                else if(slverr_expected) begin
                    if(!t.PSLVERR) begin
                        `uvm_error("SCB", $sformatf(
                                "Expected PSLVERR=1 for read @PADDR=%0h PSEL=%0d, got 0",
                                t.PADDR, t.PSEL))
                            mismatch_cnt++;
                    end
                    else begin
                        // `uvm_info("SCB", $sformatf(
                        //         "PSLVERR=1 for read @PADDR=%0h PSEL=%0d",
                        //         t.PADDR, t.PSEL), UVM_HIGH)
                        match_cnt++;
                    end
                    if (!t.PREADY) begin
                        `uvm_error("SCB", $sformatf(
                            "Expected PREADY=1 (PSLVERR case) @PADDR=%0h PSEL=%0d, got 0",
                            t.PADDR, t.PSEL))
                        mismatch_cnt++;
                    end
                    else begin
                        // `uvm_info("SCB", "true valid out, t 0", UVM_HIGH)
                        // `uvm_info("SCB",
                        // $sformatf("else  PADDR=%0h PSEL=%0d PSTRB=%b PWDATA=%h",
                        // t.PADDR,
                        // t.PSEL,
                        // t.PSTRB,
                        // t.PWDATA),
                        // UVM_HIGH)
                        match_cnt++;
                    end
                end
            end
            else begin
                if (t.PREADY) begin
                    `uvm_error("SCB", $sformatf(
                        "Expected PREADY=0 @PADDR=%0h PSEL=%0d, got 1",
                        t.PADDR, t.PSEL))
                    mismatch_cnt++;
                end
                else begin
                    // `uvm_info("SCB", "true valid out, t 0", UVM_HIGH)
                    // `uvm_info("SCB",
                    // $sformatf("else  PADDR=%0h PSEL=%0d PSTRB=%b PWDATA=%h",
                    // t.PADDR,
                    // t.PSEL,
                    // t.PSTRB,
                    // t.PWDATA),
                    // UVM_HIGH)
                    match_cnt++;
                end
                if(t.PSLVERR) begin
                    `uvm_error("SCB", $sformatf(
                            "Expected PSLVERR=0 for read @PADDR=%0h PSEL=%0d, got 1",
                            t.PADDR, t.PSEL))
                        mismatch_cnt++;
                end
                else begin
                    // `uvm_info("SCB", $sformatf(
                    //         "PSLVERR=0 for read @PADDR=%0h PSEL=%0d",
                    //         t.PADDR, t.PSEL), UVM_HIGH)
                    match_cnt++;
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