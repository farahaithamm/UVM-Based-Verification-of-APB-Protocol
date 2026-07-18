module APB_SLAVE_top;
import uvm_pkg::*;
import APB_SLAVE_Test_pkg::*;
`include "uvm_macros.svh"

bit PCLK;
always #5 PCLK = ~PCLK;

intf inf(PCLK);

APB_SLAVE dut(
    .PCLK(inf.PCLK), 
    .PRESETn(inf.PRESETn), 
    .PADDR(inf.PADDR), 
    .PSEL(inf.PSEL), 
    .PENABLE(inf.PENABLE), 
    .PWRITE(inf.PWRITE),
    .PWDATA(inf.PWDATA), 
    .PSTRB(inf.PSTRB), 
    .PREADY(inf.PREADY), 
    .PRDATA(inf.PRDATA), 
    .PSLVERR(inf.PSLVERR)
);

bind APB_SLAVE APB_SLAVE_SVA apb_slave_sva_inst (
    .PCLK(PCLK), 
    .PRESETn(PRESETn), 
    .PADDR(PADDR), 
    .PSEL(PSEL), 
    .PENABLE(PENABLE), 
    .PWRITE(PWRITE),
    .PWDATA(PWDATA), 
    .PSTRB(PSTRB), 
    .PREADY(PREADY), 
    .PRDATA(PRDATA), 
    .PSLVERR(PSLVERR)
);

initial begin
    $readmemh("mem.dat", dut.mem);
    uvm_config_db #(virtual intf)::set(null, "uvm_test_top", "my_vif", inf);
    run_test("APB_SLAVE_Test");
end
endmodule 
