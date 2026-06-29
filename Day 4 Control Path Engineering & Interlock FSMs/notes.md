# Day 4 — Control Path Engineering & Testbench Verification

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 29 June 2026

---

## 🎯 What I Did Today

Wrote a complete SystemVerilog Testbench for the AXI4-Lite Slave.
Ran 8 directed tests in ModelSim — **8/8 PASSED. 0 errors. 0 warnings.**

---

## 📐 Testbench Architecture — 4 Components

```
COMPONENT 1 — Clock & Reset Generator
  initial ACLK = 0;
  always #5 ACLK = ~ACLK;  // 100 MHz

COMPONENT 2 — Driver (Tasks)
  axi_write() — drives AW + W channels
  axi_read()  — drives AR channel
  axi_write_backpressure() — tests BREADY delay

COMPONENT 3 — Checker
  if (RDATA === expected) → PASS
  else                    → FAIL + $error

COMPONENT 4 — Watchdog Timeout
  #50000 → $error("TIMEOUT") → $finish
```

---

## 📐 Control Path — What Was Verified

### WSTRB Byte Lane Control:
```
WSTRB = 4'b1111 → full 32-bit write
WSTRB = 4'b0001 → only byte [7:0] written

Test 8 proof:
  Write 0x12345678 → reg[0]  (full write)
  Write 0xXXXXXXAB → reg[0]  (WSTRB=0001)
  Read  0x123456AB ← reg[0]  ✅
  Upper 3 bytes unchanged — byte lane works
```

### Address Decode — AWADDR[3:2]:
```
0x00 → slv_reg[0] ✅
0x04 → slv_reg[1] ✅
0x08 → slv_reg[2] ✅
0x0C → slv_reg[3] ✅
```

---

## 📐 Interlock FSM — Back-Pressure Verified

```
Test 7 — 5 cycle BREADY delay:

BVALID asserted by Slave  →  1
BREADY held LOW by Master →  0 (5 cycles)

FSM behavior:
WRITE_RESP state — HOLDS BVALID
Does NOT move to IDLE
Does NOT drop data
Does NOT corrupt transaction

After 5 cycles — BREADY = 1
Handshake complete → IDLE ✅
Data preserved: 0xFACEB00C ✅

KEY RULE:
BVALID must HOLD until BREADY arrives
= Same as VALID/READY Drop Rule
= AXI4 compliant behavior ✅
```

---

## 📊 Test Results — ModelSim

```
Simulation time: 1055 ns
Clock: 100 MHz (10ns period)

TEST 1: Write 0xDEADBEEF → 0x04    ✅ PASS
TEST 2: Read  0xDEADBEEF ← 0x04    ✅ PASS
TEST 3: Write 0xCAFEBABE → 0x08    ✅ PASS
TEST 4: Read  0xCAFEBABE ← 0x08    ✅ PASS
TEST 5: Write all 4 registers       ✅ PASS
TEST 6: Read  all 4 registers       ✅ PASS
TEST 7: Back-pressure 5 cycle       ✅ PASS
TEST 8: WSTRB byte write            ✅ PASS

RESULT: 8/8 PASSED
ERRORS: 0
WARNINGS: 0
```

---

## 📐 Write Transaction — Cycle by Cycle

```
T=0: ARESETn=0 — all signals = 0, FSM=IDLE
T=1: ARESETn=1 — reset released
T=2: AWVALID=1, AWADDR=0x04
     WVALID=1,  WDATA=0xDEADBEEF, WSTRB=1111
T=3: AWREADY=1, WREADY=1 — handshake!
     FSM → WRITE_RESP
     slv_reg[1] <= 0xDEADBEEF
T=4: BVALID=1, BRESP=00 (OKAY)
     BREADY=1 — master ready
T=5: Transaction complete
     BVALID=0, FSM → IDLE ✅
```

---

## 📐 Back-Pressure — Timing

```
CLK    : __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
BVALID : ______|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
BREADY : ____________________|‾‾‾‾‾|____
                               ↑
                        Transfer HERE
                        (5 cycles later)

FSM stays in WRITE_RESP — data held safely
```

---

## 🔑 Key Learnings — Day 4

```
1. Testbench = Driver + Checker + Watchdog
   Not just stimulus — must verify output

2. Blocking (=) vs Non-Blocking (<=):
   always_ff  → use <=
   always_comb → use =
   Tasks driving DUT → use <=

3. Back-pressure = FSM interlock
   BVALID holds until BREADY arrives
   Same rule as VALID/READY Drop Rule

4. WSTRB = control path granularity
   Per-byte write enable
   Critical for register updates

5. Checker pattern:
   if (RDATA === expected) PASS
   else $error FAIL
   Always use === not == for 4-state logic
```

---

## 📁 Files This Folder

| File | Description |
|------|-------------|
| `tb_axi4_lite_slave.sv` | Complete testbench |
| `console_output.png` | ModelSim — 8/8 PASS |
| `waveform_full.png` | All channels visible |
| `waveform_awaddr.png` | Address bits |
| `waveform_wdata.png` | Data bits + WSTRB |

---

## 📅 What's Next — Day 5

```
Day 5: SystemVerilog VIP + Master BFM
├── Verification IP environment
├── Master BFM — drives all channels
├── Reusable transaction classes
└── Directed test scenarios
```

---

## 📊 Sprint Progress

```
Day 1 ✅ Handshake Mechanics
Day 2 ✅ 5-Channel Architecture  
Day 3 ✅ RTL — 301 MHz synthesis
Day 4 ✅ Testbench — 8/8 PASS
Day 5 ⬜ VIP + Master BFM
Day 6 ⬜ SVA Protocol Checker
Day 7 ⬜ Coverage + Sign-off
```

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*