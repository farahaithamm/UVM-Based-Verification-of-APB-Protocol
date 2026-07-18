module APB_SLAVE_SVA #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    localparam PSTRB_WIDTH = DATA_WIDTH/8
)(
    input wire PCLK,
    input wire PRESETn,

    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [DATA_WIDTH-1:0] PWDATA,
    input wire [PSTRB_WIDTH-1:0] PSTRB,

    input wire PREADY,
    input wire [DATA_WIDTH-1:0] PRDATA,
    input wire PSLVERR
);

    property p_psel_seq;
        @(posedge PCLK) disable iff(!PRESETn) PSEL && !PENABLE |=> ($stable(PSEL) && PENABLE);
    endproperty
    a_psel_seq: assert property(p_psel_seq);
    c_psel_seq: cover property(p_psel_seq);

    property p_enable_with_psel;
        @(posedge PCLK) disable iff(!PRESETn) PENABLE |-> PSEL;
    endproperty
    a_enable_with_psel: assert property(p_enable_with_psel);
    c_enable_with_psel: cover property(p_enable_with_psel);

    property p_control_stable;
        @(posedge PCLK) disable iff(!PRESETn) (PENABLE && PSEL) |-> $stable({PADDR,PWRITE,PSEL,PSTRB,PWDATA});
    endproperty
    a_control_stable: assert property(p_control_stable);
    c_control_stable: cover property(p_control_stable);

    property p_wstrb;
        @(posedge PCLK) disable iff(!PRESETn) PWRITE |-> (PSTRB != 0);
    endproperty
    a_wstrb: assert property(p_wstrb);
    c_wstrb: cover property(p_wstrb);

    property p_rstrb;
        @(posedge PCLK) disable iff(!PRESETn) !PWRITE |-> (PSTRB == 0);
    endproperty
    a_rstrb: assert property(p_rstrb);
    c_rstrb: cover property(p_rstrb);

    property p_pready;
        @(posedge PCLK) disable iff(!PRESETn) PREADY |-> (PSEL & PENABLE);
    endproperty
    a_pready: assert property(p_pready);
    c_pready: cover property(p_pready);

    property p_slverr_last_cycle;
        @(posedge PCLK) disable iff(!PRESETn) PSLVERR |-> (PREADY & PSEL & PENABLE);
    endproperty
    a_slverr_last_cycle: assert property(p_slverr_last_cycle);
    c_slverr_last_cycle: cover property(p_slverr_last_cycle);

    property p_slverr_high;
        @(posedge PCLK) disable iff(!PRESETn) (PADDR > 127 && PREADY) |-> PSLVERR;
    endproperty
    a_slverr_high: assert property(p_slverr_high);
    c_slverr_high: cover property(p_slverr_high);

    property p_slverr_low;
        @(posedge PCLK) disable iff(!PRESETn) (PADDR < 128 || !PREADY) |-> !PSLVERR;
    endproperty
    a_slverr_low: assert property(p_slverr_low);
    c_slverr_low: cover property(p_slverr_low);

    property p_prdata_read;
        @(posedge PCLK) disable iff(!PRESETn) (PSEL && PENABLE && !PWRITE)|-> !$isunknown(PRDATA);
    endproperty
    a_prdata_read: assert property(p_prdata_read);
    c_prdata_read: cover property(p_prdata_read);

    property p_prdata_slverr;
        @(posedge PCLK) disable iff(!PRESETn) (PSLVERR) |-> (PRDATA == 0);
    endproperty
    a_prdata_slverr: assert property(p_prdata_slverr);
    c_prdata_slverr: cover property(p_prdata_slverr);

endmodule