interface intf(input logic PCLK);
    logic PRESETn;
    logic [31:0] PADDR;
    logic PSEL, PENABLE, PWRITE;
    logic [31:0] PWDATA;
    logic [3:0] PSTRB;

    logic PREADY;
    logic [31:0] PRDATA;
    logic PSLVERR;

    clocking cb @(posedge PCLK);
        // default input #1step output #1step;
        output PRESETn, PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB;
        input PREADY, PRDATA, PSLVERR;
    endclocking

endinterface