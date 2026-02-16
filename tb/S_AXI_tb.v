`timescale 1ns/1ps

module tb_S_AXI_TOP;

reg aclk;
reg aresetn;
reg awvalid;
reg [31:0] awaddr;
reg wvalid;
reg [31:0] wdata;
reg bready;
reg arvalid;
reg [31:0] araddr;
reg rready;

wire awready;
wire wready;
wire bvalid;
wire [1:0] bresp;
wire arready;
wire [1:0] rresp;
wire rvalid;
wire [31:0] rdata;

S_AXI_TOP dut(
    .aclk(aclk),
    .aresetn(aresetn),
    .awvalid(awvalid),
    .awaddr(awaddr),
    .wvalid(wvalid),
    .wdata(wdata),
    .bready(bready),
    .arvalid(arvalid),
    .araddr(araddr),
    .rready(rready),
    .awready(awready),
    .wready(wready),
    .bvalid(bvalid),
    .bresp(bresp),
    .arready(arready),
    .rresp(rresp),
    .rvalid(rvalid),
    .rdata(rdata)
);

// Clock
initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;
end

// Main test
initial begin
    $dumpfile("s_axi.vcd");
    $dumpvars(0, tb_S_AXI_TOP);
    
    // Initialize
    aresetn = 0;
    awvalid = 0;
    wvalid = 0;
    arvalid = 0;
    bready = 1;
    rready = 1;
    awaddr = 32'h0;
    wdata = 32'h0;
    araddr = 32'h0;
    
    // Reset
    repeat(5) @(posedge aclk);
    aresetn = 1;
    repeat(5) @(posedge aclk);
    
    // TEST 1
    $display("=== Test 1: Write to 0x04 ===");
    @(posedge aclk);
    #1;  // Small delay after clock edge
    awaddr = 32'h0000_0004;
    wdata = 32'hDEADBEEF;
    awvalid = 1;
    wvalid = 1;
    
    @(posedge aclk);
    #1;
    awvalid = 0;
    wvalid = 0;
    
    repeat(5) @(posedge aclk);
    $display("Write done: bresp=%b\n", bresp);
    
    // TEST 2
    $display("=== Test 2: Read from 0x04 ===");
    @(posedge aclk);
    #1;
    araddr = 32'h0000_0004;
    arvalid = 1;
    
    @(posedge aclk);
    #1;
    arvalid = 0;
    
    repeat(5) @(posedge aclk);
    $display("Read done: rdata=%h rresp=%b\n", rdata, rresp);
    
    // TEST 3
    $display("=== Test 3: Write to 0x2000 (out of range) ===");
    @(posedge aclk);
    #1;
    awaddr = 32'h0000_2000;
    wdata = 32'hAAAA5555;
    awvalid = 1;
    wvalid = 1;
    
    @(posedge aclk);
    #1;
    awvalid = 0;
    wvalid = 0;
    
    repeat(5) @(posedge aclk);
    $display("DEBUG: latched_addr_w = 0x%h", dut.latched_addr_w);
    $display("DEBUG: bits[31:9] = 0x%h", dut.latched_addr_w[31:9]);
    $display("Write done: bresp=%b (should be 10)\n", bresp);
    
    // TEST 4
    $display("=== Test 4: Read from 0x2000 (out of range) ===");
    @(posedge aclk);
    #1;
    araddr = 32'h0000_2000;
    arvalid = 1;
    
    @(posedge aclk);
    #1;
    arvalid = 0;
    
    repeat(5) @(posedge aclk);
    $display("Read done: rdata=%h rresp=%b (should be 10)\n", rdata, rresp);
    
    $display("\n=== ALL TESTS DONE ===");
    repeat(10) @(posedge aclk);
    $finish;
end

// Timeout
initial begin
    #5000;
    $display("TIMEOUT!");
    $finish;
end

endmodule
