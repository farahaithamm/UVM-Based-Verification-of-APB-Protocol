package APB_MASTER_transaction_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_seq_item extends uvm_sequence_item;
    `uvm_object_utils(APB_MASTER_seq_item)

    rand logic PRESETn;
    rand logic [31:0] addr;
    rand logic sel; // 0 for slave0, 1 for slave1
    rand logic transfer;
    rand logic wr_en;
    rand logic [31:0] wdata;
    rand logic [3:0] strb;

    // From slave
    logic PREADY;
    rand logic [31:0] PRDATA;
    logic PSLVERR;

    logic [31:0] OUTDATA;
    logic valid_out;

    // To slave
    logic [31:0] PADDR;
    logic [1:0] PSEL; // PSEL[0] for slave0, PSEL[1] for slave1
    logic PENABLE;
    logic PWRITE; // 1 write, 0 read
    logic [31:0] PWDATA;
    logic [3:0] PSTRB;

    rand int wait_cycles = 0;

    function new(string name = "APB_MASTER_seq_item");
        super.new(name);
    endfunction

    constraint reset_c {
        PRESETn dist {0:=3, 1:=97}; 
    }; 
    constraint addr_c {
        addr dist {[0:127] :/ 90, [128:$] :/ 10};
    };

    constraint wr_en_c {
        wr_en dist {0 := 50, 1 := 50};
    }

    constraint sel_c {
        sel dist {0 := 50, 1 := 50};
    }

    constraint transfer_c {
        transfer dist {0 := 50, 1 := 50};
    }

    constraint wrstrb_c {
        if (wr_en == 1'b1) strb inside {[1:15]};
        else strb == 0;
    }

    constraint wstrb_c {
        strb inside {[1:15]};
    }

    constraint wait_cycles_c {
        wait_cycles inside {[0:3]};
    }
endclass
endpackage