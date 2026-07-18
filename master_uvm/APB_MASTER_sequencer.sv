package APB_MASTER_sequencer_pkg;
import uvm_pkg::*;
import APB_MASTER_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_sequencer extends uvm_sequencer #(APB_MASTER_seq_item);
    `uvm_component_utils(APB_MASTER_sequencer)

    function new(string name = "APB_MASTER_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
endpackage