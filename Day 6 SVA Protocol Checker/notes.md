# Day 6 — SVA Protocol Checker

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 01 July 2026

---

## 🎯 What I Built Today

A complete **SystemVerilog Assertion (SVA) Protocol Checker** —
9 concurrent assertions that automatically catch AXI4-Lite
protocol violations on every clock edge.

---

## 📐 SVA vs Testbench Checker — Key Difference

```
Testbench Checker (Day 4):
  if (RDATA === expected) → PASS
  else → FAIL
  
  Problem: Only checks what YOU wrote tests for
           Silent bugs pass through undetected

SVA Concurrent Assertion:
  Checks on EVERY clock edge — automatically
  Forever — no manual triggering needed
  Catches violations testbench never saw

Example bug SVA catches, testbench misses:
  AWVALID drops before AWREADY arrives
  Testbench: RDATA matched → PASS (wrong!)
  SVA: Drop Rule fires → VIOLATION caught!
```

---

## 📐 Assertion Syntax — Key Operators

```systemverilog
// Implication operator
A |-> B        // If A then B (same cycle)
A |-> ##1 B   // If A then B (next cycle)
A |-> ##[1:3] B // If A then B (1 to 3 cycles later)

// Disable during reset
disable iff (!ARESETn)

// Rose/Fell edge detection
$rose(signal)  // 0→1 transition
$fell(signal)  // 1→0 transition

// Assert vs Cover
assert property (p) else $error("violation!");
cover  property (p);  // checks if p ever happens
```

---

## 📐 9 Assertions — Complete

### Write Path:

```systemverilog
// 1. AW Drop Rule
(AWVALID && !AWREADY) |-> ##1 AWVALID
// AWVALID must hold until AWREADY arrives

// 2. W Drop Rule  
(WVALID && !WREADY) |-> ##1 WVALID
// WVALID must hold until WREADY arrives

// 3. BVALID Hold
(BVALID && !BREADY) |-> ##1 BVALID
// BVALID must hold until BREADY arrives

// 4. No Deadlock
($rose(AWREADY)) |-> AWVALID
// AWREADY can only rise when AWVALID is HIGH

// 5. BRESP must be OKAY
(BVALID) |-> (BRESP === 2'b00)
// Normal transaction response = OKAY
```

### Read Path:

```systemverilog
// 6. AR Drop Rule
(ARVALID && !ARREADY) |-> ##1 ARVALID

// 7. RVALID Hold
(RVALID && !RREADY) |-> ##1 RVALID

// 8. RRESP must be OKAY
(RVALID) |-> (RRESP === 2'b00)
```

### Global:

```systemverilog
// 9. Reset Check
(!ARESETn) |-> (AWVALID === 1'b0 &&
                WVALID  === 1'b0 &&
                BVALID  === 1'b0)
// All signals must be LOW during reset
```

---

## 📐 Cover Properties — Traffic Verification

```systemverilog
// Ensure all 5 handshakes actually happened
cover property (AWVALID && AWREADY);  // AW transfer seen
cover property (WVALID  && WREADY);   // W  transfer seen
cover property (BVALID  && BREADY);   // B  transfer seen
cover property (ARVALID && ARREADY);  // AR transfer seen
cover property (RVALID  && RREADY);   // R  transfer seen
```

---

## 📐 How SVA Integrates With Testbench

```
Checker instantiated inside testbench:

axi4_lite_checker CHK (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),
    .AWVALID (vif.AWVALID),
    ...
);

Now during simulation:
Every posedge ACLK → all 9 assertions check
Any violation → immediate $error with timestamp
No manual check needed — always on
```

---

## 🔑 Key Learnings — Day 6

```
1. SVA = always-on protocol guardian
   Testbench = test-specific checker
   Both needed — complementary roles

2. disable iff (!ARESETn)
   Critical — without this, assertions fire
   during reset and give false violations

3. ##1 = next clock cycle
   |-> = overlapping implication
   These two operators cover most AXI4 rules

4. cover property ≠ assert property
   assert = catches violations (bad things)
   cover  = confirms coverage  (good things happened)

5. BRESP/RRESP = 2'b00 (OKAY) for normal ops
   Any other value = error condition

6. SVA can be synthesized for formal verification
   Not just simulation — used in real chip sign-off
```

---

## 📁 Files In This Folder

| File | Description |
|------|-------------|
| `axi4_lite_checker.sv` | 9 SVA assertions + 5 cover properties |
| `notes.md` | Theory + assertion explanations |
| `README.md` | Day 6 documentation |

---

## 📅 What's Next — Day 7

```
Day 7: Functional Coverage + Regression + Sign-off
├── Covergroups — define what to measure
├── Cross-coverage — addr × data combinations
├── Regression suite — run all days together
└── Final sprint sign-off report
```

---

## 📊 Sprint Progress

| Day | Topic | Status |
|-----|-------|--------|
| Day 1 | Handshake Mechanics | ✅ |
| Day 2 | 5-Channel Architecture | ✅ |
| Day 3 | RTL — 301 MHz Synthesis | ✅ |
| Day 4 | Testbench — 8/8 PASS | ✅ |
| Day 5 | VIP + Master BFM — 12/12 PASS | ✅ |
| Day 6 | SVA Protocol Checker — 9 assertions | ✅ |
| Day 7 | Coverage + Sign-off | ⬜ Tomorrow |

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*