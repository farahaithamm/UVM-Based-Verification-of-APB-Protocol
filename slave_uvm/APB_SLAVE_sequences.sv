package APB_SLAVE_sequences_pkg;
import uvm_pkg::*;
import APB_SLAVE_transaction_pkg::*;
`include "uvm_macros.svh"

class APB_SLAVE_reset_sequence extends uvm_sequence;
    `uvm_object_utils(APB_SLAVE_reset_sequence)
    APB_SLAVE_seq_item seq_item;

    function new(string name = "APB_SLAVE_reset_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.PRESETn = 1'b0;
        seq_item.PADDR = 32'b0;
        seq_item.PSEL = 1'b0;
        seq_item.PENABLE = 1'b0;
        seq_item.PWRITE = 1'b0;
        seq_item.PWDATA = 32'b0;
        seq_item.PSTRB = 4'b0;
        finish_item(seq_item);
    endtask
endclass

class APB_SLAVE_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_SLAVE_write_sequence)
    APB_SLAVE_seq_item seq_item;
    
    function new(string name = "APB_SLAVE_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            seq_item.wrstrb_c.constraint_mode(0);
            assert(seq_item.randomize());
            seq_item.PWRITE = 1'b1;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_SLAVE_read_sequence extends uvm_sequence;
    `uvm_object_utils(APB_SLAVE_read_sequence)
    APB_SLAVE_seq_item seq_item;

    function new(string name = "APB_SLAVE_read_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item");
        repeat(500) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            seq_item.PWRITE = 1'b0;
            seq_item.PSTRB = 4'b0000;
            finish_item(seq_item);
        end
    endtask
endclass

class APB_SLAVE_read_write_sequence extends uvm_sequence;
    `uvm_object_utils(APB_SLAVE_read_write_sequence)
    APB_SLAVE_seq_item seq_item;

    function new(string name = "APB_SLAVE_read_write_sequence");
        super.new(name);
    endfunction

    task body();
        seq_item = APB_SLAVE_seq_item::type_id::create("seq_item");
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