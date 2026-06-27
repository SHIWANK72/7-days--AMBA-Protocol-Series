# Day 3 — RTL Coding: AXI4-Lite Memory-Mapped Slave

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 28 June 2026

---

## 🎯 What I Built Today

A complete **AXI4-Lite Memory-Mapped Slave** in SystemVerilog —
from blank file to synthesized netlist — in one day.

---

## 📐 Design Specifications

```
Device    : Cyclone V (5CGXFC7C7F23C8)
Language  : SystemVerilog
Logic     : 90 ALMs (<1% utilization)
Registers : 207 Flip-Flops
Fmax      : 301.02 MHz (85°C worst case)
           306.37 MHz (0°C)
Pins      : 154 (5 AXI4-Lite channels)
Status    : TIMING CLOSED ✅
```

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `axi4_lite_slave.sv` | Main RTL — AXI4-Lite Slave |
| `notes.md` | Day 3 theory + architecture notes |
| `screenshots/` | Quartus RTL, FSM, Timing, Chip views |

---

## 🔌 Port Map — All 5 Channels

```systemverilog
module axi4_lite_slave (
    // Global
    input  logic        ACLK,       // Clock
    input  logic        ARESETn,    // Active LOW reset

    // AW — Write Address (Master → Slave)
    input  logic        AWVALID,
    input  logic [31:0] AWADDR,
    input  logic [2:0]  AWPROT,
    output logic        AWREADY,

    // W — Write Data (Master → Slave)
    input  logic        WVALID,
    input  logic [31:0] WDATA,
    input  logic [3:0]  WSTRB,
    output logic        WREADY,

    // B — Write Response (Slave → Master)
    output logic        BVALID,
    output logic [1:0]  BRESP,
    input  logic        BREADY,

    // AR — Read Address (Master → Slave)
    input  logic        ARVALID,
    input  logic [31:0] ARADDR,
    input  logic [2:0]  ARPROT,
    output logic        ARREADY,

    // R — Read Data (Slave → Master)
    output logic        RVALID,
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    input  logic        RREADY
);
```

---

## 🗺️ Register Map

| Address | Register | Purpose |
|---------|----------|---------|
| `0x00` | `slv_reg[0]` | Control Register |
| `0x04` | `slv_reg[1]` | Status Register |
| `0x08` | `slv_reg[2]` | Data Register |
| `0x0C` | `slv_reg[3]` | Config Register |

**Address mapping formula:**
```systemverilog
slv_reg[ AWADDR[3:2] ]  // bits [3:2] = register index
```

---

## 🔄 Write FSM — 4 States

```
         Reset
           │
           ▼
        [IDLE]
       /   |   \
   AW     AW+W    W
  only    both   only
   │       │      │
[GOT_AW]   │   [GOT_W]
   │       │      │
   W       │     AW
  arrives  │   arrives
   └───────▼───────┘
      [WRITE_RESP]
      Assert BVALID
      Wait BREADY
           │
           ▼
        [IDLE]
```

**State encoding:**
```systemverilog
typedef enum logic [1:0] {
    IDLE       = 2'b00,
    GOT_AW     = 2'b01,
    GOT_W      = 2'b10,
    WRITE_RESP = 2'b11
} state_t;
```

---

## ✍️ WSTRB — Byte Lane Write Control

```
WSTRB[3:0] controls which bytes get written:

WSTRB = 4'b1111 → Full 32-bit write
WSTRB = 4'b0001 → Byte write  [7:0]
WSTRB = 4'b0011 → Half-word  [15:0]
WSTRB = 4'b1100 → Upper half [31:16]

RTL implementation:
if (WSTRB[0]) slv_reg[addr][7:0]   <= WDATA[7:0];
if (WSTRB[1]) slv_reg[addr][15:8]  <= WDATA[15:8];
if (WSTRB[2]) slv_reg[addr][23:16] <= WDATA[23:16];
if (WSTRB[3]) slv_reg[addr][31:24] <= WDATA[31:24];
```

---

## 📊 Quartus Synthesis Results

### Flow Summary
```
Status   : Successful ✅
Device   : Cyclone V 5CGXFC7C7F23C8
Logic    : 90 / 56,480 ALMs  (<1%)
Registers: 207
Pins     : 154 / 268  (57%)
```

### Timing — Fmax
```
Slow 85°C corner : 301.02 MHz ✅
Slow  0°C corner : 306.37 MHz ✅
Clock            : ACLK
Industry typical : 200-250 MHz
Result           : ABOVE INDUSTRY TYPICAL
```

### Chip Utilization
```
Design footprint : <1% of Cyclone V
Placement        : Compact single region
Routing          : Clean, no congestion
```

---

## 🖼️ Screenshots

| View | What it shows |
|------|--------------|
| `state_machine.png` | FSM — 4 states auto-extracted by Quartus |
| `rtl_viewer.png` | Gate-level netlist |
| `tech_map.png` | Post-synthesis primitive mapping |
| `flow_summary.png` | Resource utilization |
| `fmax_85c.png` | Timing — 301 MHz worst case |
| `chip_planner.png` | Physical placement on Cyclone V |
| `chip_fullview.png` | Full die — design footprint |

---

## 📅 What's Next — Day 4

```
Day 4: Control Path Engineering & Testbench
├── tb_axi4_lite_slave.sv — write from scratch
├── ModelSim waveform — all 5 channels
├── Write transaction — T=0 to complete
└── Read transaction — verified on waveform
```

---

## 📊 Day 3 Score

| Task | Status |
|------|--------|
| Port declaration | ✅ All 20 signals |
| Register file | ✅ 4 x 32-bit |
| Write FSM | ✅ 4 states |
| Read path | ✅ Single cycle |
| Synthesis | ✅ Timing closed |
| Fmax | ✅ 301 MHz |

---

## 🔗 Part of

**[7-Days AMBA AXI4-Lite Protocol Sprint]**
`7-days--AMBA-Protocol-Series` repository

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*