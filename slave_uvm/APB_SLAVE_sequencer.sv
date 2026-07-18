package APB_SLAVE_sequencer_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_sequencer extends uvm_sequencer #(APB_SLAVE_seq_item);
    `uvm_component_utils(APB_SLAVE_sequencer)

    function new(string name = "APB_SLAVE_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
endpackage