# Day 3 — RTL Coding: AXI4-Lite Slave Architecture

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 28 June 2026

---

## Port Declaration — Complete

```systemverilog
module axi4_lite_slave (
    // Global Signals
    input  logic        ACLK,
    input  logic        ARESETn,    // Active LOW reset

    // AW Channel — Master → Slave
    input  logic        AWVALID,
    input  logic [31:0] AWADDR,
    input  logic [2:0]  AWPROT,
    output logic        AWREADY,

    // W Channel — Master → Slave
    input  logic        WVALID,
    input  logic [31:0] WDATA,
    input  logic [3:0]  WSTRB,
    output logic        WREADY,

    // B Channel — Slave → Master
    output logic        BVALID,
    output logic [1:0]  BRESP,
    input  logic        BREADY,

    // AR Channel — Master → Slave
    input  logic        ARVALID,
    input  logic [31:0] ARADDR,
    input  logic [2:0]  ARPROT,
    output logic        ARREADY,

    // R Channel — Slave → Master
    output logic        RVALID,
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    input  logic        RREADY
);
```

---

## Internal Architecture

```systemverilog
// Register File — 4 registers, 32-bit each
logic [31:0] slv_reg [0:3];

// Register Map:
// 0x00 → slv_reg[0] — Control Register
// 0x04 → slv_reg[1] — Status Register
// 0x08 → slv_reg[2] — Data Register
// 0x0C → slv_reg[3] — Config Register

// Address mapping formula:
// slv_reg[ AWADDR[3:2] ]

// FSM State Declaration
typedef enum logic [1:0] {
    IDLE       = 2'b00,
    GOT_AW     = 2'b01,
    GOT_W      = 2'b10,
    WRITE_RESP = 2'b11
} state_t;

state_t state, next_state;

// Internal latches
logic [31:0] awaddr_lat;  // latch address
logic [31:0] wdata_lat;   // latch data
logic [3:0]  wstrb_lat;   // latch strobe
```

---

## Write FSM — State Transitions

```
IDLE:
  AW only    → GOT_AW
  W only     → GOT_W
  AW + W     → WRITE_RESP
  nothing    → IDLE

GOT_AW:
  W arrives  → WRITE_RESP
  no W       → GOT_AW

GOT_W:
  AW arrives → WRITE_RESP
  no AW      → GOT_W

WRITE_RESP:
  BREADY=1   → IDLE
  BREADY=0   → WRITE_RESP
```

---

## Key Rules Learned Today

```
1. Port naming = Channel prefix + Signal type
   AW + VALID = AWVALID
   W  + DATA  = WDATA
   B  + RESP  = BRESP

2. Register address mapping:
   slv_reg[ AWADDR[3:2] ] ← core formula

3. FSM must handle 3 cases:
   AW first, W first, simultaneous

4. BVALID asserts only after BOTH
   AW and W handshakes complete

5. ARESETn is active LOW —
   logic inverts on reset check
```