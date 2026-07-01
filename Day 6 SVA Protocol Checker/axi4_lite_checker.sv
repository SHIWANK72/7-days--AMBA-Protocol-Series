// ============================================
// SVA Protocol Checker — AXI4-Lite
// Nik-Coronics | Day 6
// Engineer: Shiwank Gupta
// Date: 01 July 2026
// ============================================

module axi4_lite_checker (
    input logic        ACLK, ARESETn,
    input logic        AWVALID, AWREADY,
    input logic        WVALID,  WREADY,
    input logic        BVALID,  BREADY,
    input logic        ARVALID, ARREADY,
    input logic        RVALID,  RREADY,
    input logic [1:0]  BRESP,   RRESP
);

// ============================================
// ASSERTION 1 — AW Drop Rule
// ============================================
property aw_drop_rule;
    @(posedge ACLK) disable iff (!ARESETn)
    (AWVALID && !AWREADY) |-> ##1 AWVALID;
endproperty
assert property (aw_drop_rule)
    else $error("[SVA] AW Drop Rule violated — AWVALID dropped before AWREADY!");

// ============================================
// ASSERTION 2 — W Drop Rule
// ============================================
property w_drop_rule;
    @(posedge ACLK) disable iff (!ARESETn)
    (WVALID && !WREADY) |-> ##1 WVALID;
endproperty
assert property (w_drop_rule)
    else $error("[SVA] W Drop Rule violated — WVALID dropped before WREADY!");

// ============================================
// ASSERTION 3 — BVALID Hold
// ============================================
property bvalid_hold;
    @(posedge ACLK) disable iff (!ARESETn)
    (BVALID && !BREADY) |-> ##1 BVALID;
endproperty
assert property (bvalid_hold)
    else $error("[SVA] BVALID dropped before BREADY!");

// ============================================
// ASSERTION 4 — No Deadlock
// ============================================
property no_deadlock;
    @(posedge ACLK) disable iff (!ARESETn)
    ($rose(AWREADY)) |-> AWVALID;
endproperty
assert property (no_deadlock)
    else $error("[SVA] Deadlock detected — AWREADY without AWVALID!");

// ============================================
// ASSERTION 5 — Reset Check
// ============================================
property reset_check;
    @(posedge ACLK)
    (!ARESETn) |-> (AWVALID === 1'b0 &&
                    WVALID  === 1'b0 &&
                    BVALID  === 1'b0);
endproperty
assert property (reset_check)
    else $error("[SVA] Reset violation — signals not LOW during reset!");

// ============================================
// ASSERTION 6 — BRESP must be OKAY
// ============================================
property bresp_okay;
    @(posedge ACLK) disable iff (!ARESETn)
    (BVALID) |-> (BRESP === 2'b00);
endproperty
assert property (bresp_okay)
    else $error("[SVA] BRESP not OKAY — unexpected response code!");

// ============================================
// ASSERTION 7 — AR Drop Rule
// ============================================
property ar_drop_rule;
    @(posedge ACLK) disable iff (!ARESETn)
    (ARVALID && !ARREADY) |-> ##1 ARVALID;
endproperty
assert property (ar_drop_rule)
    else $error("[SVA] AR Drop Rule violated — ARVALID dropped before ARREADY!");

// ============================================
// ASSERTION 8 — RVALID Hold
// ============================================
property rvalid_hold;
    @(posedge ACLK) disable iff (!ARESETn)
    (RVALID && !RREADY) |-> ##1 RVALID;
endproperty
assert property (rvalid_hold)
    else $error("[SVA] RVALID dropped before RREADY!");

// ============================================
// ASSERTION 9 — RRESP must be OKAY
// ============================================
property rresp_okay;
    @(posedge ACLK) disable iff (!ARESETn)
    (RVALID) |-> (RRESP === 2'b00);
endproperty
assert property (rresp_okay)
    else $error("[SVA] RRESP not OKAY!");

// ============================================
// COVER PROPERTIES — Protocol traffic seen
// ============================================
cover property (@(posedge ACLK) AWVALID && AWREADY);
cover property (@(posedge ACLK) WVALID  && WREADY);
cover property (@(posedge ACLK) BVALID  && BREADY);
cover property (@(posedge ACLK) ARVALID && ARREADY);
cover property (@(posedge ACLK) RVALID  && RREADY);

endmodule