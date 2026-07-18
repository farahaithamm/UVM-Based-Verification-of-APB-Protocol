package APB_MASTER_sequences_pkg;
import uvm_pkg::*;
import APB_MASTER_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_MASTER_reset_sequence extends uvm_sequence;
    `uvm_object_utils(APB_MASTER_reset_sequence)
    APB_MASTER_seq_item seq_item;

    function new(string name = "APB_MASTER_reset_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_MASTER_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.PRESETn = 1'b0;
        seq_item.addr = 32'b0;
        seq_item.sel = 1'b0;
        seq_item.transfer = 1'b0;
        seq_item.wr_en = 1'b0;
        seq_item.wdata = 32'b0;
        seq_item.strb = 4'b0;
        seq_item.PREADY = 1'b0;
        seq_item.PRDATA = 32'b0;
        seq_item.PSLVERR = 1'b0;
        finish_item(seq_item);
    endtask
endclass

class APB_MASTER_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_MASTER_write_sequence)
    APB_MASTER_seq_item seq_item;
    
    function new(string name = "APB_MASTER_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_MASTER_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            seq_item.wrstrb_c.constraint_mode(0);
            assert(seq_item.randomize());
            seq_item.wr_en = 1'b1;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_MASTER_read_sequence extends uvm_sequence;
    `uvm_object_utils(APB_MASTER_read_sequence)
    APB_MASTER_seq_item seq_item;

    function new(string name = "APB_MASTER_read_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_MASTER_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            seq_item.wr_en = 1'b0;
            seq_item.strb = 4'b0000;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_MASTER_read_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_MASTER_read_write_sequence)
    APB_MASTER_seq_item seq_item;

    function new(string name = "APB_MASTER_read_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_MASTER_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            seq_item.wrstrb_c.constraint_mode(1);
            seq_item.wstrb_c.constraint_mode(0);
            assert(seq_item.randomize());
            finish_item(seq_item);
        end
    endtask
endclass
endpackage