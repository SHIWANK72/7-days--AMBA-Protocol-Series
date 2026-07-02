# Day 7 — Functional Coverage + Regression + Sprint Sign-off

**7-Days AMBA AXI4-Lite Protocol Sprint | Nik-Coronics — Independent R&D**
**Engineer:** Shiwank Gupta · **Date:** 02 July 2026

---

## 🎯 Objective

Close the 7-day sprint with **Functional Coverage** — measuring how much of the AXI4-Lite design space was actually exercised — and a full **Regression Sign-off** confirming the complete RTL-to-Verification pipeline passes cleanly in a single simulation run.

---

## ⚠️ Implementation Note — Where Coverage Lives

> `functional_coverage.sv` in this folder contains the **raw, standalone covergroup code** for reference and documentation.
>
> The **actual working implementation** was added directly into the Day 5 testbench file (`axi_master_bfm.sv`) — covergroup declaration at module level, `cov_inst = new()` in the initial block, and `get_coverage()` in the final report. This is standard practice — covergroups live inside the testbench environment, not as standalone modules.
>
> If you want to study the coverage model in isolation, read `functional_coverage.sv`. If you want to see it running inside the full VIP flow, refer to the updated `axi_master_bfm.sv` in the Day 5 folder.

---

## 📐 Why Coverage — The Missing Piece

![Verification Triangle](VERIFICATION%20TRIANGLE.jpg)

```
Day 4 Scoreboard → checks correctness of what was tested
Day 6 SVA        → catches protocol violations automatically
Day 7 Coverage   → measures HOW MUCH of the design was tested

Without coverage: PASS means "the tests I wrote passed."
With coverage:    PASS means "X% of the design space was exercised."
```

**Real gap this sprint exposed:**
`$random` never generated address `0x0C` (reg3) across all 12 transactions.
Scoreboard: 12/12 PASS — didn't notice.
SVA: 0 violations — didn't notice.
Coverage: **80%** — reg3 bin never hit. **Caught it.**

---

## 📐 Coverage Model

![Covergroup Syntax](COVERGROUP%20SYNTAX.jpg)

```systemverilog
covergroup axi_cov @(posedge ACLK);

    cp_addr: coverpoint vif.AWADDR {
        bins reg0 = {32'h00000000};
        bins reg1 = {32'h00000004};
        bins reg2 = {32'h00000008};
        bins reg3 = {32'h0000000C};  // ← never hit by $random → 80%
    }

    cp_wvalid: coverpoint vif.WVALID {
        bins active = {1};
        bins idle   = {0};
    }

    cp_arvalid: coverpoint vif.ARVALID {
        bins active = {1};
        bins idle   = {0};
    }

    cp_bresp: coverpoint vif.BRESP {
        bins okay   = {2'b00};
        bins slverr = {2'b10};
    }

    // Cross: 4 addr bins × 2 wvalid bins = 8 combinations
    cx_addr_wvalid: cross cp_addr, cp_wvalid;

endgroup
```

---

## 📐 Regression — Full Pipeline in One Run

![Regression Block](REGRESSION%20BLOCK.jpg)

```
Day 3 RTL (axi4_lite_slave.sv)
  ↓
Day 5 VIP Testbench (axi_master_bfm.sv) — with coverage added
  ↓
Day 6 SVA Checker (axi4_lite_checker.sv)
  ↓
Day 7 Coverage (covergroup inside testbench)
  ↓
Single Vivado XSim behavioral simulation
All layers active simultaneously — one run, full sign-off
```

---

## ✅ Final Simulation Results

![Console Output](CONSOLE.jpg)

```
============================================
  SCOREBOARD REPORT
  PASS: 12   FAIL: 0
============================================

============================================
  COVERAGE REPORT - Day 7
  Functional Coverage: 80.0%
============================================

============================================
  7-DAY SPRINT - REGRESSION SIGN-OFF
  Nik-Coronics | Engineer: Shiwank Gupta
============================================
  Day 3 - RTL Synthesis    : 301 MHz       ✓
  Day 4 - Directed Tests   : 8/8  PASS     ✓
  Day 5 - VIP + BFM        : 12/12 PASS   ✓
  Day 6 - SVA Assertions   : 0 Violations  ✓
  Day 7 - Coverage         : 80.0%         ✓
--------------------------------------------
  OVERALL STATUS: AXI4-Lite COMPLIANT
  SPRINT STATUS : COMPLETE
============================================

============================================
  SVA CHECKER REPORT
  Assertions Checked : 9
  Violations Found   : 0
  Protocol Status    : AXI4-Lite COMPLIANT
============================================
```

**Waveform — Full Pipeline:**

![Waveform 1](WAVE%201.jpg)
![Waveform 2](WAV2.jpg)

---

## 📐 Sprint Sign-off

![Sign-off Table](SIGN%20OFF%20TABLE.jpg)

---

## 🔑 Key Learnings

```
1. Verification triangle: Coverage + SVA + Scoreboard
   Each catches a different class of problem.
   No single tool is enough alone.

2. 80% is honest engineering
   Reporting 80% with a documented gap is better than
   forcing 100% with tests designed to game the metric.
   The gap (reg3/0x0C never hit) is real — and documented.

3. Cross coverage catches corner cases
   "Address written" ≠ "Address written while WVALID HIGH"
   Cross tracks the combination — 4 × 2 = 8 bins.

4. get_coverage() — SystemVerilog built-in
   Returns real-time percentage of bins hit.
   Used in $display for clean console reporting.

5. Regression = confidence after change
   Every day's work stacked on the previous.
   Final single run proves the full stack holds together.

6. Tool limitation documented honestly
   XSim does not support SVA cover properties.
   Workaround: covergroup at testbench module level.
   QuestaSim/VCS needed for full coverage closure flow.
```

---

## 📁 Files In This Folder

| File | Description |
|------|-------------|
| `functional_coverage.sv` | Raw standalone covergroup — reference/study only |
| `notes.md` | Coverage theory, syntax, key learnings |
| `readme.md` | This file — Day 7 full documentation |
| `CAT.jpg` | Collaboration/connect card — open to mentor, guide, collab |
| `COVERGROUP SYNTAX.jpg` | Hand-drawn covergroup syntax diagram |
| `REGRESSION BLOCK.jpg` | Hand-drawn regression flow diagram |
| `SIGN OFF TABLE.jpg` | Hand-drawn 7-day sprint sign-off table |
| `VERIFICATION TRIANGLE.jpg` | Hand-drawn verification triangle concept |
| `WAVE 1.jpg` | Vivado waveform — upper half |
| `WAV2.jpg` | Vivado waveform — lower half |
| `CONSOLE.jpg` | Final regression sign-off console output |

> **Note:** The actual coverage implementation (working code) is in `Day 5 SystemVerilog VIP & Master BFM/axi_master_bfm.sv` — covergroup added at module level, instantiated and sampled inside the testbench initial block.

---

## 📊 Complete Sprint Summary

| Day | Topic | Result |
|-----|-------|--------|
| Day 0 | Foundation — AMBA family, AXI4-Lite blueprint | ✅ |
| Day 1 | Handshake Mechanics — Drop Rule, Circular Dependency | ✅ |
| Day 2 | 5-Channel Architecture — AW/W/B/AR/R, WSTRB, BRESP | ✅ |
| Day 3 | RTL — axi4_lite_slave.sv, 301 MHz on Cyclone V | ✅ |
| Day 4 | Testbench — 8/8 directed tests PASS | ✅ |
| Day 5 | VIP + Master BFM — 12/12 PASS (directed + random + back-pressure) | ✅ |
| Day 6 | SVA Protocol Checker — 9 assertions, 0 violations | ✅ |
| Day 7 | Coverage 80% + Regression Sign-off — SPRINT COMPLETE | ✅ |

---

## 📬 Connect

Open to research collaborations, mentoring students breaking into VLSI,
freelance RTL/DV/FPGA work, and technical discussions on AMBA/AXI protocols.

**Email:** NIKORONICS@proton.me
**GitHub:** github.com/SHIWANK72/7-days--AMBA-Protocol-Series
**LinkedIn:** linkedin.com/in/guptashiwank

---

*Shiwank Gupta | Independent VLSI Researcher | Nik-Coronics*