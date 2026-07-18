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

    // From slave
    logic PREADY;
    logic [31:0] PRDATA;
    logic PSLVERR;

    // To slave
    logic [31:0] PADDR;
    logic [1:0] PSEL; // PSEL[0] for slave0, PSEL[1] for slave1
    logic PENABLE;
    logic PWRITE; // 1 write, 0 read
    logic [31:0] PWDATA;
    logic [3:0] PSTRB;

    clocking drv_cb @(posedge PCLK);
        // default input #1step output #1step;
        output PRESETn, addr, sel, transfer, wr_en, wdata, strb, PREADY, PRDATA, PSLVERR;
    endclocking

    clocking mon_cb @(posedge PCLK);
        // default input #1step output #1step;
        input PRESETn, addr, sel, transfer, wr_en, wdata, strb;
        input PREADY, PRDATA, PSLVERR;
        input OUTDATA, valid_out;
        input PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB;
    endclocking

endinterface