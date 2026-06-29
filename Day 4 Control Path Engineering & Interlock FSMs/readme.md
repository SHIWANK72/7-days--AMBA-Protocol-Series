# Day 4 — Control Path Engineering & Testbench Verification

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 29 June 2026

---

## 🎯 What I Built Today

A complete **SystemVerilog Testbench** for the AXI4-Lite Slave —
8 directed tests covering write, read, back-pressure, and WSTRB.

**Result: 8/8 PASSED. 0 errors. 0 warnings. 1055 ns.**

---

## 📁 Files In This Folder

| File | Description |
|------|-------------|
| `tb_axi4_lite_slave.sv` | Complete testbench — 8 tests |
| `notes.md` | Theory + cycle-by-cycle analysis |
| `console_output.png` | ModelSim — 8/8 PASS |
| `waveform_full.png` | All 5 channels visible |
| `waveform_awaddr.png` | Address bits detail |
| `waveform_wdata.png` | Data bits + WSTRB |
| `write_transaction.jpg` | Handwritten timing diagram |
| `back_pressure.jpg` | Handwritten back-pressure test |
| `wstrb_byte_write.jpg` | Handwritten WSTRB diagram |
| `test_results.jpg` | Handwritten 8/8 summary |

---

## 🏗️ Testbench Architecture

```
tb_axi4_lite_slave
├── COMPONENT 1 — Clock & Reset Generator
│   initial ACLK = 0;
│   always #5 ACLK = ~ACLK;  // 100 MHz
│
├── COMPONENT 2 — Driver Tasks
│   ├── axi_write()              — AW+W simultaneous
│   ├── axi_read()               — AR channel
│   └── axi_write_backpressure() — BREADY delay test
│
├── COMPONENT 3 — Checker
│   if (RDATA === expected) → [PASS]
│   else                    → [FAIL] $error
│
└── COMPONENT 4 — Watchdog Timeout
    #50000 → TIMEOUT → $finish
```

---

## 📊 Test Results

```
╔══════╦══════════════════════════════╦════════╗
║ TEST ║ DESCRIPTION                  ║ RESULT ║
╠══════╬══════════════════════════════╬════════╣
║  T1  ║ Write 0xDEADBEEF → 0x04     ║ ✅ PASS ║
║  T2  ║ Read  0xDEADBEEF ← 0x04     ║ ✅ PASS ║
║  T3  ║ Write 0xCAFEBABE → 0x08     ║ ✅ PASS ║
║  T4  ║ Read  0xCAFEBABE ← 0x08     ║ ✅ PASS ║
║  T5  ║ Write all 4 registers        ║ ✅ PASS ║
║  T6  ║ Read  all 4 registers        ║ ✅ PASS ║
║  T7  ║ Back-pressure — 5 cycle delay║ ✅ PASS ║
║  T8  ║ WSTRB byte write [7:0]       ║ ✅ PASS ║
╠══════╬══════════════════════════════╬════════╣
║      ║ TOTAL                        ║ 8/8 ✅  ║
╚══════╩══════════════════════════════╩════════╝

Errors   : 0
Warnings : 0
Sim time : 1055 ns
```

---

## 📐 Control Path — WSTRB Verified

```
WSTRB = Write Strobe — 1 bit per byte lane

Test 8 proof:
Step 1: Write 0x12345678 → reg[0]  WSTRB=1111
Step 2: Write 0xXXXXXXAB → reg[0]  WSTRB=0001
Step 3: Read  0x123456AB ← reg[0]  ✅ PASS

Upper 3 bytes: UNCHANGED ✅
Lower byte:    UPDATED   ✅
```

---

## 📐 Interlock FSM — Back-Pressure Verified

```
Test 7 — 5 cycle BREADY delay:

CLK    : __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
BVALID : ______|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
BREADY : ____________________|‾‾‾‾‾|____
FSM    : ______[WRITE_RESP_________][IDLE]

FSM held in WRITE_RESP — data not lost
BVALID held HIGH — AXI4 compliant ✅
Transaction completed cleanly ✅
```

---

## 📐 Write Transaction — Cycle by Cycle

```
T=0: ARESETn=0 — reset active, FSM=IDLE
T=1: ARESETn=1 — reset released
T=2: AWVALID=1 AWADDR=0x04
     WVALID=1  WDATA=0xDEADBEEF WSTRB=1111
T=3: AWREADY=1 WREADY=1 — HANDSHAKE ✅
     FSM → WRITE_RESP
     slv_reg[1] <= 0xDEADBEEF
T=4: BVALID=1 BRESP=00(OKAY) BREADY=1
T=5: BVALID=0 FSM → IDLE — DONE ✅
```

---

## 🔑 Key Learnings

```
1. Testbench = Driver + Checker + Watchdog
   Stimulus alone is not enough

2. Always use <= in tasks driving DUT
   Blocking = causes race conditions

3. Back-pressure = interlock FSM
   BVALID holds until BREADY — spec rule

4. WSTRB = control path granularity
   Per-byte write enable — critical

5. === vs == in checker
   === checks X/Z states too
   == misses X propagation bugs
```

---

## 📅 What's Next — Day 5

```
Day 5: SystemVerilog VIP + Master BFM
├── Verification IP environment
├── Master BFM — reusable driver
├── Transaction classes
└── Directed + random test scenarios
```

---

## 📊 Sprint Progress

| Day | Topic | Status |
|-----|-------|--------|
| Day 1 | Handshake Mechanics | ✅ Complete |
| Day 2 | 5-Channel Architecture | ✅ Complete |
| Day 3 | RTL — 301 MHz Synthesis | ✅ Complete |
| Day 4 | Testbench — 8/8 PASS | ✅ Complete |
| Day 5 | VIP + Master BFM | ⬜ Tomorrow |
| Day 6 | SVA Protocol Checker | ⬜ Pending |
| Day 7 | Coverage + Sign-off | ⬜ Pending |

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*