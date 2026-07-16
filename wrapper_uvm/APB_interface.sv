interface intf(input logic PCLK);
    logic PRESETn;
    logic [31:0] addr;
    logic sel; // 0 for slave0, 1 for slave1
    logic transfer;
    logic wr_en;
    logic [31:0] wdata;
    logic [3:0] strb;
    
    logic [31:0] OUTDATA;
    logic valid_out;
    logic PSLVERR;

    clocking cb @(posedge PCLK);
        // default input #1step output #1step;
        output PRESETn, addr, sel, transfer, wr_en, wdata, strb;
        input OUTDATA, valid_out, PSLVERR;
    endclocking

endinterface