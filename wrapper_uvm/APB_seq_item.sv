package APB_transaction_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class APB_seq_item extends uvm_sequence_item;
    `uvm_object_utils(APB_seq_item)

    rand logic PRESETn;
    rand logic [31:0] addr;
    rand logic sel; // 0 for slave0, 1 for slave1
    rand logic transfer;
    rand logic wr_en;
    rand logic [31:0] wdata;
    rand logic [3:0] strb;

    logic [31:0] OUTDATA;
    logic valid_out;
    logic PSLVERR;

    logic continue_transfer = 0;

    function new(string name = "APB_seq_item");
        super.new(name);
    endfunction

    function void pre_randomize();
        continue_transfer = ~continue_transfer;
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
        transfer == continue_transfer;
    }

    constraint strb_c {
        (wr_en == 1'b1) -> strb inside {[1:15]};
    }
endclass
endpackage