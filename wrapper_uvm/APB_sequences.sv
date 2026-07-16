package APB_sequences_pkg;
import uvm_pkg::*;
import APB_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_reset_sequence extends uvm_sequence;
    `uvm_object_utils(APB_reset_sequence)
    APB_seq_item seq_item;

    function new(string name = "APB_reset_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.PRESETn = 1'b0;
        seq_item.addr = 32'b0;
        seq_item.sel = 1'b0;
        seq_item.transfer = 1'b0;
        seq_item.wr_en = 1'b0;
        seq_item.wdata = 32'b0;
        seq_item.strb = 4'b0;
        finish_item(seq_item);
    endtask
endclass

class APB_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_write_sequence)
    APB_seq_item seq_item;
    
    function new(string name = "APB_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            seq_item.wr_en = 1'b1;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_read_sequence extends uvm_sequence;
    `uvm_object_utils(APB_read_sequence)
    APB_seq_item seq_item;

    function new(string name = "APB_read_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            seq_item.wr_en = 1'b0;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_read_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_read_write_sequence)
    APB_seq_item seq_item;

    function new(string name = "APB_read_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            finish_item(seq_item);
        end
    endtask
endclass
endpackage