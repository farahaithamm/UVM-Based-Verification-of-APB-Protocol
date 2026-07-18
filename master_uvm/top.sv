module APB_MASTER_top;
import uvm_pkg::*;
import APB_MASTER_Test_pkg::*;
`include "uvm_macros.svh"

bit PCLK;
always #5 PCLK = ~PCLK;

intf inf(PCLK);

APB_MASTER dut (
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
    .PREADY(inf.PREADY),
    .PRDATA(inf.PRDATA),
    .PSLVERR(inf.PSLVERR),
    .PADDR(inf.PADDR),
    .PSEL(inf.PSEL),
    .PENABLE(inf.PENABLE),
    .PWRITE(inf.PWRITE),
    .PWDATA(inf.PWDATA),
    .PSTRB(inf.PSTRB)
);

initial begin
    uvm_config_db #(virtual intf)::set(null, "uvm_test_top", "my_vif", inf);
    run_test("APB_MASTER_Test");
end
endmodule 
