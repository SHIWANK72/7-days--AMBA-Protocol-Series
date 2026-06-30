// ============================================
// AXI4-Lite Master BFM + VIP Environment
// Nik-Coronics | 7-Day AMBA Sprint — Day 5
// Engineer: Shiwank Gupta
// Date: 30 June 2026
// ============================================

`timescale 1ns/1ps

// ============================================
// INTERFACE — DUT Connection Point
// ============================================
interface axi_if (input logic ACLK, input logic ARESETn);
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
endinterface

// ============================================
// TRANSACTION CLASS — Pure Data
// ============================================
class axi_transaction;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    bit             is_write;
    bit [1:0]       resp;

    // Address must be 4-byte aligned
    constraint addr_align {
        addr[1:0] == 2'b00;
    }

    // Restrict to our 4-register space (0x00-0x0C)
    constraint addr_range {
        addr inside {32'h00, 32'h04, 32'h08, 32'h0C};
    }

    function void display(string tag);
        $display("[%s] addr=0x%08h data=0x%08h strb=%0b write=%0b resp=%0b",
                   tag, addr, data, strb, is_write, resp);
    endfunction
endclass

// ============================================
// MASTER BFM — Behavior Model
// ============================================
class axi_master_bfm;
    virtual axi_if vif;

    function new(virtual axi_if vif);
        this.vif = vif;
    endfunction

    // ----------------------------------------
    // Write Transaction
    // ----------------------------------------
    task drive_write(axi_transaction tx);
        @(posedge vif.ACLK);
        vif.AWVALID <= 1'b1;
        vif.AWADDR  <= tx.addr;
        vif.AWPROT  <= 3'b000;
        vif.WVALID  <= 1'b1;
        vif.WDATA   <= tx.data;
        vif.WSTRB   <= tx.strb;

        wait(vif.AWREADY && vif.WREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 1'b0;
        vif.WVALID  <= 1'b0;

        wait(vif.BVALID);
        tx.resp = vif.BRESP;
        @(posedge vif.ACLK);
        vif.BREADY <= 1'b1;
        @(posedge vif.ACLK);
        vif.BREADY <= 1'b0;
    endtask

    // ----------------------------------------
    // Read Transaction
    // ----------------------------------------
    task drive_read(axi_transaction tx);
        @(posedge vif.ACLK);
        vif.ARVALID <= 1'b1;
        vif.ARADDR  <= tx.addr;
        vif.ARPROT  <= 3'b000;

        wait(vif.ARREADY);
        @(posedge vif.ACLK);
        vif.ARVALID <= 1'b0;

        wait(vif.RVALID);
        @(posedge vif.ACLK);
        vif.RREADY <= 1'b1;
        tx.data = vif.RDATA;
        tx.resp = vif.RRESP;
        @(posedge vif.ACLK);
        vif.RREADY <= 1'b0;
    endtask

    // ----------------------------------------
    // Back-pressure Write — delayed BREADY
    // ----------------------------------------
    task drive_write_backpressure(axi_transaction tx, int delay_cycles);
        @(posedge vif.ACLK);
        vif.AWVALID <= 1'b1;
        vif.AWADDR  <= tx.addr;
        vif.AWPROT  <= 3'b000;
        vif.WVALID  <= 1'b1;
        vif.WDATA   <= tx.data;
        vif.WSTRB   <= tx.strb;

        wait(vif.AWREADY && vif.WREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 1'b0;
        vif.WVALID  <= 1'b0;

        wait(vif.BVALID);
        repeat(delay_cycles) @(posedge vif.ACLK);
        tx.resp = vif.BRESP;
        vif.BREADY <= 1'b1;
        @(posedge vif.ACLK);
        vif.BREADY <= 1'b0;
    endtask

    // ----------------------------------------
    // Reset Task
    // ----------------------------------------
    task apply_reset();
        vif.AWVALID = 0; vif.WVALID = 0; vif.BREADY = 0;
        vif.ARVALID = 0; vif.RREADY = 0;
        vif.AWADDR  = 0; vif.WDATA  = 0; vif.WSTRB  = 0;
        vif.ARADDR  = 0; vif.AWPROT = 0; vif.ARPROT = 0;
    endtask

endclass

// ============================================
// SCOREBOARD — Pass/Fail Tracking
// ============================================
class axi_scoreboard;
    int pass_count = 0;
    int fail_count = 0;

    function void check(axi_transaction tx, bit [31:0] expected);
        if (tx.data === expected) begin
            $display("[SCOREBOARD] PASS — addr=0x%08h data=0x%08h",
                       tx.addr, tx.data);
            pass_count++;
        end else begin
            $error("[SCOREBOARD] FAIL — addr=0x%08h expected=0x%08h got=0x%08h",
                     tx.addr, expected, tx.data);
            fail_count++;
        end
    endfunction

    function void report();
        $display("============================================");
        $display("  SCOREBOARD REPORT");
        $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
        $display("============================================");
    endfunction
endclass

// ============================================
// TOP MODULE — Environment
// ============================================
module tb_axi4_lite_vip;

    logic ACLK, ARESETn;
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    axi_if vif(ACLK, ARESETn);

    // DUT instantiation
    axi4_lite_slave DUT (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),
        .AWVALID (vif.AWVALID), .AWADDR  (vif.AWADDR),
        .AWPROT  (vif.AWPROT),  .AWREADY (vif.AWREADY),
        .WVALID  (vif.WVALID),  .WDATA   (vif.WDATA),
        .WSTRB   (vif.WSTRB),   .WREADY  (vif.WREADY),
        .BVALID  (vif.BVALID),  .BRESP   (vif.BRESP),
        .BREADY  (vif.BREADY),
        .ARVALID (vif.ARVALID), .ARADDR  (vif.ARADDR),
        .ARPROT  (vif.ARPROT),  .ARREADY (vif.ARREADY),
        .RVALID  (vif.RVALID),  .RDATA   (vif.RDATA),
        .RRESP   (vif.RRESP),   .RREADY  (vif.RREADY)
    );

    axi_master_bfm   bfm;
    axi_scoreboard   sb;

    initial begin
        bfm = new(vif);
        sb  = new();

        $display("============================================");
        $display("  AXI4-Lite VIP Environment — Nik-Coronics");
        $display("  Day 5 | Engineer: Shiwank Gupta");
        $display("============================================");

        ARESETn = 0;
        bfm.apply_reset();
        repeat(5) @(posedge ACLK);
        ARESETn = 1;
        repeat(2) @(posedge ACLK);
        $display("[INFO] Reset released");

        // ──────────────────────────────────
        // DIRECTED TEST — known values
        // ──────────────────────────────────
        $display("\n--- DIRECTED TEST: Write+Read 0x04 ---");
        begin
            axi_transaction wtx = new();
            axi_transaction rtx = new();

            wtx.addr = 32'h04;
            wtx.data = 32'hDEADBEEF;
            wtx.strb = 4'b1111;
            bfm.drive_write(wtx);
            wtx.display("WRITE");

            rtx.addr = 32'h04;
            bfm.drive_read(rtx);
            rtx.display("READ");
            sb.check(rtx, 32'hDEADBEEF);
        end

        // ──────────────────────────────────
        // RANDOMIZED TEST — 10 transactions
        // ──────────────────────────────────
        $display("\n--- RANDOMIZED TEST: 10 write+read pairs ---");
        for (int i = 0; i < 10; i++) begin
    automatic axi_transaction wtx = new();
    automatic axi_transaction rtx = new();
    automatic bit [1:0] addr_sel;

    // Manual randomization — no license needed
    addr_sel = $random;
    case (addr_sel)
        2'b00: wtx.addr = 32'h00;
        2'b01: wtx.addr = 32'h04;
        2'b10: wtx.addr = 32'h08;
        2'b11: wtx.addr = 32'h0C;
    endcase
    wtx.data = $random;
    wtx.strb = 4'b1111;

    bfm.drive_write(wtx);
    wtx.display($sformatf("RAND-WRITE-%0d", i));

    rtx.addr = wtx.addr;
    bfm.drive_read(rtx);
    rtx.display($sformatf("RAND-READ-%0d", i));
    sb.check(rtx, wtx.data);
end
        // ──────────────────────────────────
        // BACK-PRESSURE TEST
        // ──────────────────────────────────
        $display("\n--- BACK-PRESSURE TEST: 5 cycle BREADY delay ---");
        begin
            axi_transaction wtx = new();
            axi_transaction rtx = new();

            wtx.addr = 32'h08;
            wtx.data = 32'hFACEB00C;
            wtx.strb = 4'b1111;
            bfm.drive_write_backpressure(wtx, 5);
            wtx.display("BP-WRITE");

            rtx.addr = 32'h08;
            bfm.drive_read(rtx);
            sb.check(rtx, 32'hFACEB00C);
        end

        repeat(10) @(posedge ACLK);
        sb.report();
        $display("\nALL TESTS COMPLETE");
        $finish;
    end

    // Watchdog
    initial begin
        #100000;
        $error("WATCHDOG TIMEOUT");
        $finish;
    end

endmodule