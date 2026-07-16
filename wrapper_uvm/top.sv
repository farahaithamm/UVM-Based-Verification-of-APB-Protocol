module APB_top;
import uvm_pkg::*;
import APB_Test_pkg::*;
`include "uvm_macros.svh"

bit PCLK;
always #5 PCLK = ~PCLK;

intf inf(PCLK);

APB_WRAPPER dut(
    .PCLK(PCLK),
    .PRESETn(inf.PRESETn),
    .addr(inf.addr),
    .sel(inf.sel),
    .transfer(inf.transfer),
    .wr_en(inf.wr_en),
    .wdata(inf.wdata),
    .strb(inf.strb),
    .OUTDATA(inf.OUTDATA),
    .valid_out(inf.valid_out),
    .PSLVERR(inf.PSLVERR)
);

bind APB_WRAPPER APB_WRAPPER_SVA apb_wrapper_sva_inst (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .addr(addr),
    .sel(sel),
    .transfer(transfer),
    .wr_en(wr_en),
    .wdata(wdata),
    .strb(strb),
    .OUTDATA(OUTDATA),
    .valid_out(valid_out),
    .PSLVERR(PSLVERR),
    .PREADY(PREADY),
    .PREADY0(PREADY0),
    .PREADY1(PREADY1),
    .PRDATA(PRDATA),
    .PRDATA0(PRDATA0),
    .PRDATA1(PRDATA1),
    .PSLVERR0(PSLVERR0),
    .PSLVERR1(PSLVERR1),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .cs(dut.master.cs)
);

initial begin
    $readmemh("mem.dat", dut.slave0.mem);
    $readmemh("mem.dat", dut.slave1.mem);
    uvm_config_db #(virtual intf)::set(null, "uvm_test_top", "my_vif", inf);
    run_test("APB_Test");
end
endmodule 
