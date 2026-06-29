// ============================================
// Testbench — AXI4-Lite Slave
// Nik-Coronics | 7-Day AMBA Sprint — Day 4
// Engineer: Shiwank Gupta
// Date: 29 June 2026
// ============================================

`timescale 1ns/1ps

module tb_axi4_lite_slave;

// ============================================
// COMPONENT 1 — Clock & Reset
// ============================================
logic ACLK, ARESETn;

initial ACLK = 0;
always #5 ACLK = ~ACLK;  // 100 MHz

// ============================================
// COMPONENT 2 — DUT Signals
// ============================================
logic        AWVALID, AWREADY;
logic [31:0] AWADDR;
logic [2:0]  AWPROT;

logic        WVALID, WREADY;
logic [31:0] WDATA;
logic [3:0]  WSTRB;

logic        BVALID, BREADY;
logic [1:0]  BRESP;

logic        ARVALID, ARREADY;
logic [31:0] ARADDR;
logic [2:0]  ARPROT;

logic        RVALID, RREADY;
logic [31:0] RDATA;
logic [1:0]  RRESP;

// ============================================
// DUT INSTANTIATION
// ============================================
axi4_lite_slave DUT (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),
    .AWVALID (AWVALID), .AWADDR  (AWADDR),
    .AWPROT  (AWPROT),  .AWREADY (AWREADY),
    .WVALID  (WVALID),  .WDATA   (WDATA),
    .WSTRB   (WSTRB),   .WREADY  (WREADY),
    .BVALID  (BVALID),  .BRESP   (BRESP),
    .BREADY  (BREADY),
    .ARVALID (ARVALID), .ARADDR  (ARADDR),
    .ARPROT  (ARPROT),  .ARREADY (ARREADY),
    .RVALID  (RVALID),  .RDATA   (RDATA),
    .RRESP   (RRESP),   .RREADY  (RREADY)
);

// ============================================
// COMPONENT 3 — DRIVER TASKS
// ============================================

// Write Task
task axi_write(
    input logic [31:0] addr,
    input logic [31:0] data
);
    @(posedge ACLK);
    AWVALID <= 1'b1;
    AWADDR  <= addr;
    AWPROT  <= 3'b000;
    WVALID  <= 1'b1;
    WDATA   <= data;
    WSTRB   <= 4'b1111;

    wait(AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 1'b0;
    WVALID  <= 1'b0;

    wait(BVALID);
    @(posedge ACLK);
    BREADY <= 1'b1;
    @(posedge ACLK);
    BREADY <= 1'b0;

    $display("[WRITE] addr=0x%08h data=0x%08h BRESP=%0b",
              addr, data, BRESP);
endtask

// Read Task — with CHECKER
task axi_read(
    input logic [31:0] addr,
    input logic [31:0] expected
);
    @(posedge ACLK);
    ARVALID <= 1'b1;
    ARADDR  <= addr;
    ARPROT  <= 3'b000;

    wait(ARREADY);
    @(posedge ACLK);
    ARVALID <= 1'b0;

    wait(RVALID);
    @(posedge ACLK);
    RREADY <= 1'b1;
    @(posedge ACLK);
    RREADY <= 1'b0;

    // ============================================
    // COMPONENT 4 — CHECKER
    // ============================================
    if (RDATA === expected)
        $display("[PASS] addr=0x%08h expected=0x%08h got=0x%08h",
                  addr, expected, RDATA);
    else
        $error("[FAIL] addr=0x%08h expected=0x%08h got=0x%08h",
                addr, expected, RDATA);
endtask

// Back-pressure Write Task
task axi_write_backpressure(
    input logic [31:0] addr,
    input logic [31:0] data,
    input integer      bready_delay  // cycles to wait before BREADY
);
    @(posedge ACLK);
    AWVALID <= 1'b1;
    AWADDR  <= addr;
    AWPROT  <= 3'b000;
    WVALID  <= 1'b1;
    WDATA   <= data;
    WSTRB   <= 4'b1111;

    wait(AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 1'b0;
    WVALID  <= 1'b0;

    wait(BVALID);
    // Delay BREADY — back pressure test
    repeat(bready_delay) @(posedge ACLK);
    BREADY <= 1'b1;
    @(posedge ACLK);
    BREADY <= 1'b0;

    $display("[WRITE-BP] addr=0x%08h data=0x%08h delay=%0d cycles",
              addr, data, bready_delay);
endtask

// ============================================
// COMPONENT 5 — WATCHDOG TIMEOUT
// ============================================
initial begin
    #50000;
    $error("WATCHDOG TIMEOUT — simulation stuck!");
    $finish;
end

// ============================================
// MAIN TEST — Initial Block
// ============================================
initial begin
    // Initialize all signals
    ARESETn = 0;
    AWVALID = 0; WVALID  = 0; BREADY  = 0;
    ARVALID = 0; RREADY  = 0;
    AWADDR  = 0; WDATA   = 0; WSTRB   = 0;
    ARADDR  = 0; AWPROT  = 0; ARPROT  = 0;

    $display("============================================");
    $display("  AXI4-Lite Slave Testbench — Nik-Coronics");
    $display("  Day 4 | Engineer: Shiwank Gupta");
    $display("============================================");

    // Reset sequence
    repeat(5) @(posedge ACLK);
    ARESETn = 1;
    repeat(2) @(posedge ACLK);
    $display("[INFO] Reset released — simulation start");

    // ──────────────────────────────────────
    // TEST 1: Basic Write — 0x04
    // ──────────────────────────────────────
    $display("\n--- TEST 1: Basic Write to 0x04 ---");
    axi_write(32'h00000004, 32'hDEADBEEF);

    // ──────────────────────────────────────
    // TEST 2: Read back — verify 0x04
    // ──────────────────────────────────────
    $display("\n--- TEST 2: Read back from 0x04 ---");
    axi_read(32'h00000004, 32'hDEADBEEF);

    // ──────────────────────────────────────
    // TEST 3: Write — 0x08
    // ──────────────────────────────────────
    $display("\n--- TEST 3: Write to 0x08 ---");
    axi_write(32'h00000008, 32'hCAFEBABE);

    // ──────────────────────────────────────
    // TEST 4: Read back — verify 0x08
    // ──────────────────────────────────────
    $display("\n--- TEST 4: Read back from 0x08 ---");
    axi_read(32'h00000008, 32'hCAFEBABE);

    // ──────────────────────────────────────
    // TEST 5: All 4 registers write
    // ──────────────────────────────────────
    $display("\n--- TEST 5: Write all 4 registers ---");
    axi_write(32'h00000000, 32'hAAAAAAAA);  // reg[0]
    axi_write(32'h00000004, 32'hBBBBBBBB);  // reg[1]
    axi_write(32'h00000008, 32'hCCCCCCCC);  // reg[2]
    axi_write(32'h0000000C, 32'hDDDDDDDD);  // reg[3]

    // ──────────────────────────────────────
    // TEST 6: Read all 4 registers
    // ──────────────────────────────────────
    $display("\n--- TEST 6: Read all 4 registers ---");
    axi_read(32'h00000000, 32'hAAAAAAAA);
    axi_read(32'h00000004, 32'hBBBBBBBB);
    axi_read(32'h00000008, 32'hCCCCCCCC);
    axi_read(32'h0000000C, 32'hDDDDDDDD);

    // ──────────────────────────────────────
    // TEST 7: Back-pressure test
    // ──────────────────────────────────────
    $display("\n--- TEST 7: Back-pressure — 5 cycle BREADY delay ---");
    axi_write_backpressure(32'h00000004, 32'hFACEB00C, 5);
    axi_read(32'h00000004, 32'hFACEB00C);

    // ──────────────────────────────────────
    // TEST 8: WSTRB — byte write only
    // ──────────────────────────────────────
    $display("\n--- TEST 8: WSTRB byte write [7:0] only ---");
    // First write full value
    axi_write(32'h00000000, 32'h12345678);
    // Now write only lower byte
    @(posedge ACLK);
    AWVALID <= 1'b1;
    AWADDR  <= 32'h00000000;
    AWPROT  <= 3'b000;
    WVALID  <= 1'b1;
    WDATA   <= 32'hXXXXXXAB;
    WSTRB   <= 4'b0001;       // only byte[0]
    wait(AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 1'b0;
    WVALID  <= 1'b0;
    wait(BVALID);
    @(posedge ACLK);
    BREADY <= 1'b1;
    @(posedge ACLK);
    BREADY <= 1'b0;
    // Read back — upper bytes same, lower byte = AB
    axi_read(32'h00000000, 32'h123456AB);

    // ──────────────────────────────────────
    // DONE
    // ──────────────────────────────────────
    repeat(10) @(posedge ACLK);
    $display("\n============================================");
    $display("  ALL TESTS COMPLETE");
    $display("============================================");
    $finish;
end

endmodule