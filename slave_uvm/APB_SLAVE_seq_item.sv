package APB_SLAVE_transaction_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_seq_item extends uvm_sequence_item;
    `uvm_object_utils(APB_SLAVE_seq_item)

    rand logic PRESETn;
    rand logic [31:0] PADDR;
    logic PSEL, PENABLE;
    rand logic PWRITE;
    rand logic [31:0] PWDATA;
    rand logic [3:0] PSTRB;

    logic PREADY;
    logic [31:0] PRDATA;
    logic PSLVERR;

    function new(string name = "APB_SLAVE_seq_item");
        super.new(name);
    endfunction

    constraint reset_c {
        PRESETn dist {0:=3, 1:=97}; 
    }; 
    constraint addr_c {
        PADDR dist {[0:127] :/ 90, [128:$] :/ 10};
    };

    constraint wr_c {
        PWRITE dist {0 := 50, 1 := 50};
    }

    constraint wrstrb_c {
        if (PWRITE == 1'b1) PSTRB inside {[1:15]};
        else PSTRB == 0;
    }

    constraint wstrb_c {
        PSTRB inside {[1:15]};
    }
endclass
endpackage