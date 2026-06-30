# Day 5 — SystemVerilog VIP & Master BFM

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 30 June 2026

---

## 🎯 What I Built Today

Converted Day 4's hardcoded testbench into a reusable
**class-based Verification IP (VIP)** environment.

---

## 📐 Why Classes — Reusability Explained

```
Day 4 Problem:
task axi_write(addr, data) was hardcoded to 
exact DUT signal names — not reusable.

Day 5 Solution:
Transaction Class = pure data (addr, data, strb)
Master BFM Class  = behavior, connects via 
                    virtual interface
Virtual Interface = single connection point to DUT

Change DUT → only update interface
Transaction + BFM logic stays identical
```

---

## 📐 VIP Architecture — 4 Components

```
1. INTERFACE (axi_if)
   Single bundle of all 20 AXI4-Lite signals
   Connects testbench to DUT

2. TRANSACTION CLASS (axi_transaction)
   rand bit [31:0] addr, data
   rand bit [3:0]  strb
   bit             is_write, resp
   Constraint: addr[1:0] == 2'b00 (4-byte align)

3. MASTER BFM (axi_master_bfm)
   drive_write()              — AW+W+B handshake
   drive_read()                — AR+R handshake
   drive_write_backpressure()  — delayed BREADY
   apply_reset()                — signal init

4. SCOREBOARD (axi_scoreboard)
   check() — compares expected vs actual
   report() — PASS/FAIL summary
```

---

## 📐 Address Alignment Constraint

```systemverilog
constraint addr_align {
    addr[1:0] == 2'b00;
}
```

**Why bits[1:0] must be zero:**
```
32-bit registers occupy 4 bytes each.
Valid register-start addresses: 0x00, 0x04, 0x08, 0x0C
Invalid (mid-register): 0x01, 0x02, 0x03, 0x05...

slv_reg[ AWADDR[3:2] ] — register select formula
Only works correctly when AWADDR[1:0] = 00
```

---

## 📐 Randomization — Why It Matters

```
Day 4: Directed tests only
  Tested: 0x04, 0x08, 0x00, 0x0C
  Missed: every other combination

Day 5: Constrained randomization
  rand bit [31:0] data — random every run
  constraint addr_range — restricted to valid space
  10 random write+read pairs per simulation run

rand  → new random value each call (can repeat)
randc → cyclic — all values once before repeat
```

---

## 📐 Test Structure

```
1. DIRECTED TEST — known value (0xDEADBEEF)
   Sanity check — same as Day 4

2. RANDOMIZED TEST — 10 iterations
   wtx.randomize() — new addr+data each time
   Scoreboard checks every transaction

3. BACK-PRESSURE TEST
   5 cycle BREADY delay — reused from Day 4
   Now wrapped in reusable BFM task
```

---

## 🔑 Key Learnings — Day 5

```
1. Virtual interface = the reusability key
   class holds a HANDLE to interface,
   not the signals directly

2. Constructor pattern:
   function new(virtual axi_if vif);
       this.vif = vif;
   endfunction

3. Constraints restrict randomization space
   without them — random could generate
   illegal/meaningless values

4. Scoreboard separates checking from driving
   BFM drives — Scoreboard verifies
   Single Responsibility Principle

5. $sformatf() — builds dynamic strings
   for readable per-iteration logging
```

---

## 📅 What's Next — Day 6

```
Day 6: SVA Protocol Checker
├── Concurrent assertions
├── Drop Rule checker — VALID can't drop early
├── Deadlock detector — circular dependency
├── Channel ordering checker
└── Bind into existing testbench
```

---

## 📊 Sprint Progress

| Day | Topic | Status |
|-----|-------|--------|
| Day 1 | Handshake Mechanics | ✅ |
| Day 2 | 5-Channel Architecture | ✅ |
| Day 3 | RTL — 301 MHz Synthesis | ✅ |
| Day 4 | Testbench — 8/8 PASS | ✅ |
| Day 5 | VIP + Master BFM | ✅ |
| Day 6 | SVA Protocol Checker | ⬜ Tomorrow |
| Day 7 | Coverage + Sign-off | ⬜ Pending |

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*