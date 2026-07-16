module APB_WRAPPER_SVA #(
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
    input wire PSLVERR,

    input wire PREADY, PREADY0, PREADY1,
    input wire [DATA_WIDTH-1:0] PRDATA, PRDATA0, PRDATA1,
    input wire PSLVERR0, PSLVERR1,
    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire [DATA_WIDTH-1:0] PWDATA,
    input wire [1:0] PSEL,
    input wire PENABLE,
    input wire PWRITE,

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

    property p_pready_mux;
        @(posedge PCLK) disable iff(!PRESETn) PREADY == (sel ? PREADY1 : PREADY0);
    endproperty
    a_pready_mux: assert property(p_pready_mux);
    c_pready_mux: cover property(p_pready_mux);

    property p_prdata_mux;
        @(posedge PCLK) disable iff(!PRESETn) PRDATA == (sel ? PRDATA1 : PRDATA0);
    endproperty
    a_prdata_mux: assert property(p_prdata_mux);
    c_prdata_mux: cover property(p_prdata_mux);

    property p_pslverr_mux;
        @(posedge PCLK) disable iff(!PRESETn) PSLVERR == (sel ? PSLVERR1 : PSLVERR0);
    endproperty
    a_pslverr_mux: assert property(p_pslverr_mux);
    c_pslverr_mux: cover property(p_pslverr_mux);

    property p_valid_out_noerr;
        @(posedge PCLK) disable iff(!PRESETn) valid_out |-> (PREADY && !PSLVERR);
    endproperty
    a_valid_out_noerr: assert property(p_valid_out_noerr);
    c_valid_out_noerr: cover property(p_valid_out_noerr);

    property p_no_x_outdata;
        @(posedge PCLK) disable iff(!PRESETn) valid_out |-> !$isunknown(OUTDATA);
    endproperty
    a_no_x_outdata: assert property(p_no_x_outdata);
    c_no_x_outdata: cover property(p_no_x_outdata);

    property p_sel_stable;
        @(posedge PCLK) disable iff(!PRESETn) PENABLE |-> $stable(sel);
    endproperty
    a_sel_stable: assert property(p_sel_stable);
    c_sel_stable: cover property(p_sel_stable);
    
    property p_no_x_pready_pslverr;
        @(posedge PCLK) disable iff(!PRESETn) !$isunknown({PREADY, PSLVERR});
    endproperty
    a_no_x_pready_pslverr: assert property(p_no_x_pready_pslverr);
    c_no_x_pready_pslverr: cover property(p_no_x_pready_pslverr);

    property p_pslverr_high;
        @(posedge PCLK) disable iff(!PRESETn) (addr > 127 && PREADY) |-> PSLVERR;
    endproperty
    a_pslverr_high: assert property(p_pslverr_high);
    c_pslverr_high: cover property(p_pslverr_high);

    property p_pslverr_low;
        @(posedge PCLK) disable iff(!PRESETn) (addr < 128 || !PREADY) |-> !PSLVERR;
    endproperty
    a_pslverr_low: assert property(p_pslverr_low);
    c_pslverr_low: cover property(p_pslverr_low);

    property p_setup_state;
        @(posedge PCLK) disable iff(!PRESETn) (cs == SETUP) |=> (cs == ACCESS);
    endproperty
    a_setup_state: assert property(p_setup_state);
    c_setup_state: cover property(p_setup_state);

    property p_access_setup;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS && transfer && PREADY) |=> (cs == SETUP);
    endproperty
    a_access_setup: assert property(p_access_setup);
    c_access_setup: cover property(p_access_setup);

    property p_access_psel_penable;
        @(posedge PCLK) disable iff(!PRESETn) (cs == ACCESS) |-> (PSEL != 2'b00 && PENABLE);
    endproperty
    a_access_psel_penable: assert property(p_access_psel_penable);
    c_access_psel_penable: cover property(p_access_psel_penable);

    property p_idle_to_setup;
        @(posedge PCLK) disable iff(!PRESETn) (cs == IDLE && transfer) |=> (cs == SETUP);
    endproperty
    a_idle_to_setup: assert property(p_idle_to_setup);
    c_idle_to_setup: cover property(p_idle_to_setup);


    property p_idle_stays;
        @(posedge PCLK) disable iff(!PRESETn) (cs == IDLE && !transfer) |=> (cs == IDLE);
    endproperty
    a_idle_stays: assert property(p_idle_stays);
    c_idle_stays: cover property(p_idle_stays);

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
    
endmodule