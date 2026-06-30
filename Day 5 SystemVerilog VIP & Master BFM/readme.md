# Day 5 — SystemVerilog VIP & Master BFM

**7-Days AMBA AXI4-Lite Protocol Sprint | Nik-Coronics — Independent R&D**
**Engineer:** Shiwank Gupta · **Date:** 30 June 2026

---

## 🎯 Objective

Convert Day 4's hardcoded, signal-coupled testbench into a **reusable, class-based Verification IP (VIP)** environment — built around a Master Bus Functional Model (BFM), a transaction class, and a scoreboard.

---

## 📐 Why Classes — The Reusability Problem

```
Day 4 Problem:
task axi_write(addr, data) was hardcoded to
exact DUT signal names — not reusable across DUTs/projects.

Day 5 Solution:
Transaction Class = pure data        (addr, data, strb)
Master BFM Class  = behavior         (drives signals via virtual interface)
Virtual Interface = single connection point to DUT

→ Change the DUT? Only the interface binding updates.
→ Transaction + BFM logic stays identical.
```

---

## 📐 VIP Architecture

![VIP Architecture](day5_vip_architecture.png)

| # | Component | Role |
|---|---|---|
| 1 | **Interface** (`axi_if`) | Bundles all 20 AXI4-Lite signals; single connection to DUT |
| 2 | **Transaction Class** (`axi_transaction`) | `rand bit [31:0] addr, data`, `rand bit [3:0] strb`, `is_write`, `resp` |
| 3 | **Master BFM** (`axi_master_bfm`) | `drive_write()`, `drive_read()`, `drive_write_backpressure()`, `apply_reset()` |
| 4 | **Scoreboard** (`axi_scoreboard`) | `check()` — expected vs actual; `report()` — PASS/FAIL summary |

The Transaction Class feeds the Master BFM (passed in as a parameter), the BFM drives the DUT through the Virtual Interface, and results are checked independently by the Scoreboard.

---

## 📐 Address Alignment Constraint

```systemverilog
constraint addr_align {
    addr[1:0] == 2'b00;
}
```

32-bit registers occupy 4 bytes each, so valid register-start addresses are `0x00, 0x04, 0x08, 0x0C…` — never `0x01, 0x02, 0x03…`. The register-select formula `slv_reg[AWADDR[3:2]]` only resolves correctly when `AWADDR[1:0] = 00`, so this constraint keeps randomization inside legal address space.

---

## 📐 Directed vs Randomized Testing

![Directed vs Random](day5_directed_vs_random.jpg)

```
Day 4: Directed tests only
  Tested: 0x04, 0x08, 0x00, 0x0C
  Missed: every other combination

Day 5: Constrained randomization
  rand bit [31:0] data        — random every run
  constraint addr_align       — restricted to valid space
  10 random write+read pairs per simulation

rand  → new random value each call (can repeat)
randc → cyclic — all values once before repeat
```

**Tooling note:** ModelSim Starter Edition has no license for SV's native `randomize()` constraint solver. Worked around this by driving randomization through the `$random` system function instead — functionally equivalent for this scope, fully simulator-license-compatible.

---

## 📐 Transaction & BFM Class Relationship

![Transaction and BFM Classes](day5_transaction_bfm_classes.jpg)

---

## ✅ Test Structure & Results

```
1. DIRECTED TEST   — known value (0xDEADBEEF) sanity check, same as Day 4
2. RANDOMIZED TEST — 10 iterations, wtx.randomize() per call, scoreboard checks every transaction
3. BACK-PRESSURE   — 5-cycle BREADY delay, now wrapped in a reusable BFM task
```

**Simulation result (ModelSim):**

```
====================================
SCOREBOARD REPORT
PASS: 12   FAIL: 0
====================================
ALL TESTS COMPLETE
```

12/12 tests passing — 1 directed + 10 randomized + 1 back-pressure.

Waveform confirms correct 5-channel handshaking (AW/W/B/AR/R) across all transactions, with `WDATA` varying per randomized iteration and the DUT FSM cycling cleanly through `IDLE → WRITE → IDLE`.

---

## 🔑 Key Learnings

```
1. Virtual interface = the reusability key
   The class holds a HANDLE to the interface, not the signals directly.

2. Constructor pattern:
   function new(virtual axi_if vif);
       this.vif = vif;
   endfunction

3. Constraints restrict the randomization space —
   without them, random could generate illegal/meaningless values.

4. Scoreboard separates checking from driving
   (BFM drives, Scoreboard verifies — Single Responsibility Principle).

5. $sformatf() builds dynamic strings for readable per-iteration logging.
```

---

## 📊 Sprint Progress

| Day | Topic | Status |
|---|---|---|
| Day 0 | Foundation — AMBA family, blueprint | ✅ |
| Day 1 | Handshake Mechanics | ✅ |
| Day 2 | 5-Channel Architecture | ✅ |
| Day 3 | RTL — 301 MHz synthesis (Cyclone V) | ✅ |
| Day 4 | Testbench — 8/8 directed tests PASS | ✅ |
| Day 5 | VIP + Master BFM — 12/12 tests PASS | ✅ |
| Day 6 | SVA Protocol Checker | ⬜ Next |
| Day 7 | Coverage + Regression + Sign-off | ⬜ Pending |

## 📅 Coming Up — Day 6

```
SVA Protocol Checker
├── Concurrent assertions
├── Drop Rule checker      — VALID can't drop before READY
├── Deadlock detector      — circular dependency check
├── Channel ordering checker
└── Bind into existing testbench
```

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*