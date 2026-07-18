module APB_MASTER_SVA #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    localparam PSTRB_WIDTH = DATA_WIDTH/8
)(
    input wire PCLK,
    input wire PRESETn,

    input wire [ADDR_WIDTH-1:0] addr,
    input wire sel,
    input wire transfer,
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [PSTRB_WIDTH-1:0] strb,

    input wire [DATA_WIDTH-1:0] OUTDATA,
    input wire valid_out,

    input wire PREADY,
    input wire [DATA_WIDTH-1:0] PRDATA,
    input wire PSLVERR,

    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire [1:0] PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [DATA_WIDTH-1:0] PWDATA,
    input wire [PSTRB_WIDTH-1:0] PSTRB,

    input wire [1:0] cs
);

    parameter IDLE = 2'b00;
    parameter SETUP = 2'b01;
    parameter ACCESS = 2'b10;

    always_comb begin
        if(!PRESETn) begin
            p_cs_reset: assert final(cs == IDLE);
        end 
    end

    property p_psel_onehot;
        @(posedge PCLK) disable iff(!PRESETn) $onehot(PSEL);
    endproperty
    a_psel_onehot: assert property(p_psel_onehot);
    c_psel_onehot: cover property(p_psel_onehot);

    property p_psel_matches_sel;
        @(posedge PCLK) disable iff(!PRESETn) PSEL == {sel, ~sel};
    endproperty
    a_psel_matches_sel: assert property(p_psel_matches_sel);
    c_psel_matches_sel: cover property(p_psel_matches_sel);

    property p_paddr;
        @(posedge PCLK) disable iff(!PRESETn) PADDR == addr;
    endproperty
    a_paddr: assert property(p_paddr);
    c_paddr: cover property(p_paddr);

    property p_write;
        @(posedge PCLK) disable iff(!PRESETn) PWRITE == wr_en;
    endproperty
    a_write: assert property(p_write);
    c_write: cover property(p_write);

    property p_pwdata;
        @(posedge PCLK) disable iff(!PRESETn) PWDATA == wdata;
    endproperty
    a_pwdata: assert property(p_pwdata);
    c_pwdata: cover property(p_pwdata);

    property p_pstrb;
        @(posedge PCLK) disable iff(!PRESETn) PSTRB == strb;
    endproperty
    a_pstrb: assert property(p_pstrb);
    c_pstrb: cover property(p_pstrb);

    property p_no_x_outdata;
        @(posedge PCLK) disable iff(!PRESETn) valid_out |-> !$isunknown(OUTDATA);
    endproperty
    a_no_x_outdata: assert property(p_no_x_outdata);
    c_no_x_outdata: cover property(p_no_x_outdata);

    property p_en_access;
        @(posedge PCLK) disable iff(!PRESETn) PENABLE |-> (cs == ACCESS);
    endproperty
    a_en_access: assert property(p_en_access);
    c_en_access: cover property(p_en_access);

    property p_enable_idle;
        @(posedge PCLK) disable iff(!PRESETn) (cs==IDLE) |-> !PENABLE;
    endproperty
    a_enable_idle: assert property(p_enable_idle);
    c_enable_idle: cover property(p_enable_idle);
    
    property p_outdata_pready_pslverr;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && PREADY && !PSLVERR && !wr_en) |-> (OUTDATA == PRDATA);
    endproperty
    a_outdata_pready_pslverr: assert property(p_outdata_pready_pslverr);
    c_outdata_pready_pslverr: cover property(p_outdata_pready_pslverr);

    property p_valid_out_pready_pslverr;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && PREADY && !PSLVERR && !wr_en) |-> (valid_out == 1'b1);
    endproperty
    a_valid_out_pready_pslverr: assert property(p_valid_out_pready_pslverr);
    c_valid_out_pready_pslverr: cover property(p_valid_out_pready_pslverr);

    property p_pslverr_high;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && (addr > 127) && PREADY) |-> PSLVERR;
    endproperty
    a_pslverr_high: assert property(p_pslverr_high);
    c_pslverr_high: cover property(p_pslverr_high);

    property p_setup_state;
        @(posedge PCLK) disable iff(!PRESETn) (cs == SETUP) |=> (cs == ACCESS);
    endproperty
    a_setup_state: assert property(p_setup_state);
    c_setup_state: cover property(p_setup_state);

    property p_setup_psel_penable;
        @(posedge PCLK) disable iff(!PRESETn) (cs == SETUP) |-> (PSEL != 2'b00 && !PENABLE);
    endproperty
    a_setup_psel_penable: assert property(p_setup_psel_penable);
    c_setup_psel_penable: cover property(p_setup_psel_penable);

    property p_min_two_cycle_transfer;
        @(posedge PCLK) disable iff(!PRESETn) (cs == IDLE && transfer) |=> (cs == SETUP) ##1 (cs == ACCESS);
    endproperty
    a_min_two_cycle_transfer: assert property(p_min_two_cycle_transfer);
    c_min_two_cycle_transfer: cover property(p_min_two_cycle_transfer);

    property p_access_psel_penable;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS) |-> (PSEL != 2'b00 && PENABLE);
    endproperty
    a_access_psel_penable: assert property(p_access_psel_penable);
    c_access_psel_penable: cover property(p_access_psel_penable);
    
    property p_access_setup;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && transfer && PREADY) |=> (cs == SETUP);
    endproperty
    a_access_setup: assert property(p_access_setup);
    c_access_setup: cover property(p_access_setup);

    property p_access_idle;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && !transfer && PREADY) |=> (cs == IDLE);
    endproperty
    a_access_idle: assert property(p_access_idle);
    c_access_idle: cover property(p_access_idle);

    property p_access_wait;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && !PREADY) |=> (cs == ACCESS);
    endproperty
    a_access_wait: assert property(p_access_wait);
    c_access_wait: cover property(p_access_wait);

    property p_stable_access_wait;
        @(posedge PCLK) disable iff(!PRESETn)
            (cs == ACCESS && !PREADY) |=> ($stable(PADDR) && $stable(PWRITE) && $stable(PSEL) && $stable(PWDATA) && $stable(PSTRB));
    endproperty
    a_stable_access_wait: assert property(p_stable_access_wait);
    c_stable_access_wait: cover property(p_stable_access_wait);

    property p_stable_setup;
    @(posedge PCLK) disable iff(!PRESETn)
            (cs == SETUP) |=> ($stable(PADDR) && $stable(PWRITE) && $stable(PSEL)  && $stable(PWDATA));
    endproperty
    a_stable_setup: assert property(p_stable_setup);
    c_stable_setup: cover property(p_stable_setup);

    property p_pstrb_low_on_read;
        @(posedge PCLK) disable iff(!PRESETn) !PWRITE |-> (strb == 0);
    endproperty
    a_pstrb_low_on_read: assert property(p_pstrb_low_on_read);
    c_pstrb_low_on_read: cover property(p_pstrb_low_on_read);

    property p_pstrb_not_low_on_write;
        @(posedge PCLK) disable iff(!PRESETn) PWRITE |-> (strb != 0);
    endproperty
    a_pstrb_not_low_on_write: assert property(p_pstrb_not_low_on_write);
    c_pstrb_not_low_on_write: cover property(p_pstrb_not_low_on_write);

    property p_valid_out_read_only;
        @(posedge PCLK) disable iff(!PRESETn) valid_out |-> !wr_en;
    endproperty
    a_valid_out_read_only: assert property(p_valid_out_read_only);
    c_valid_out_read_only: cover property(p_valid_out_read_only);

    property p_valid_out_no_error;
        @(posedge PCLK) disable iff(!PRESETn) !(valid_out && PSLVERR);
    endproperty
    a_valid_out_no_error: assert property(p_valid_out_no_error);
    c_valid_out_no_error: cover property(p_valid_out_no_error);

    property p_prdata_outdata;
        @(posedge PCLK) disable iff(!PRESETn) valid_out |-> (OUTDATA==PRDATA);
    endproperty
    a_prdata_outdata: assert property(p_prdata_outdata);
    c_prdata_outdata: cover property(p_prdata_outdata);

endmodule