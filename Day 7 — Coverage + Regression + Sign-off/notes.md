# Day 7 — Functional Coverage + Regression + Sign-off

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 02 July 2026

---

## 🎯 What I Built Today

Added **Functional Coverage** to the existing VIP environment —
covergroups, cross-coverage, and a full **Regression Sign-off** report
closing the 7-day sprint.

---

## 📐 Why Coverage — SVA + Scoreboard Already There

```
Scoreboard = checks correctness of what was tested
SVA        = catches protocol violations automatically
Coverage   = measures HOW MUCH of the design was tested

Gap example:
  $random never generated 0x0C address →
  Scoreboard: all PASS (correct for what ran)
  SVA: 0 violations (protocol fine)
  Coverage: 80% — reg3 (0x0C) bin never hit ← caught it!

Without coverage, you don't know what you didn't test.
```

---

## 📐 Covergroup Syntax

```systemverilog
covergroup axi_cov @(posedge ACLK);

    // COVERPOINT — what to measure
    cp_addr: coverpoint vif.AWADDR {
        bins reg0 = {32'h00000000};
        bins reg1 = {32'h00000004};
        bins reg2 = {32'h00000008};
        bins reg3 = {32'h0000000C};
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

    // CROSS — combinations (addr × wvalid = 4×2 = 8 bins)
    cx_addr_wvalid: cross cp_addr, cp_wvalid;

endgroup
```

---

## 📐 3 Coverage Concepts

```
1. COVERPOINT
   Tracks individual signal values.
   cp_addr → did 0x00, 0x04, 0x08, 0x0C all get hit?

2. BINS
   Divides the value space into named buckets.
   Each bin = one coverage point to hit.

3. CROSS COVERAGE
   Tracks combinations of two coverpoints.
   cp_addr × cp_wvalid = 8 combinations
   "Was 0x04 written with WVALID HIGH?"
   Directed tests can't easily guarantee this — randomization + cross does.
```

---

## 📐 Regression — What It Means

```
Each day built on the previous:
Day 3 → RTL
Day 4 → TB
Day 5 → VIP
Day 6 → SVA
Day 7 → Coverage

Regression = run ALL of it in ONE simulation.
Confirms no new change broke any old behavior.
Single run, full pipeline, clean sign-off.
```

---

## 📊 Final Results

```
SCOREBOARD REPORT
  PASS: 12   FAIL: 0

COVERAGE REPORT
  Functional Coverage: 80.0%
  (reg3/0x0C not hit by $random — documented gap)

SVA CHECKER REPORT
  Assertions Checked : 9
  Violations Found   : 0
  Protocol Status    : AXI4-Lite COMPLIANT

7-DAY SPRINT — REGRESSION SIGN-OFF
  Day 3 — RTL Synthesis  : 301 MHz       ✓
  Day 4 — Directed Tests : 8/8  PASS     ✓
  Day 5 — VIP + BFM      : 12/12 PASS   ✓
  Day 6 — SVA Assertions : 0 Violations  ✓
  Day 7 — Coverage       : 80.0%         ✓
  OVERALL: AXI4-Lite COMPLIANT | SPRINT: COMPLETE
```

---

## 🔑 Key Learnings — Day 7

```
1. Coverage + SVA + Scoreboard = complete verification triangle
   No single tool is enough alone.

2. 80% not 100% = still valuable
   It revealed a real gap — 0x0C never tested.
   100% coverage with bad tests is worse than
   80% coverage that honestly reports the gap.

3. get_coverage() — built-in SV function
   Returns percentage of bins hit.
   Used in $display for console reporting.

4. Regression = confidence, not repetition
   Running old tests after new changes = proof
   that nothing broke.

5. XSim limitation — cover properties not supported
   Workaround: covergroup in testbench module level.
   QuestaSim/VCS needed for full coverage flow.
```

---

## 📊 Sprint Progress — COMPLETE

| Day | Topic | Result |
|-----|-------|--------|
| Day 0 | Foundation | ✅ |
| Day 1 | Handshake Mechanics | ✅ |
| Day 2 | 5-Channel Architecture | ✅ |
| Day 3 | RTL — 301 MHz Synthesis | ✅ |
| Day 4 | Testbench — 8/8 PASS | ✅ |
| Day 5 | VIP + Master BFM — 12/12 PASS | ✅ |
| Day 6 | SVA — 9 Assertions, 0 Violations | ✅ |
| Day 7 | Coverage 80% + Regression Sign-off | ✅ |

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*