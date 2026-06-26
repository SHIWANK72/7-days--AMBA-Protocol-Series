# Day 1 — AXI4-Lite Handshake Fundamentals

> **7-Days AMBA AXI4-Lite Protocol Sprint**  
> **Nik-Coronics | Independent R&D Initiative**  
> **Date:** 26 June 2026

---

## 🎯 What I Learned Today

The **VALID/READY handshake** is the heartbeat of every AXI4 channel.  
Every bug in an AXI system traces back to a misunderstanding of this mechanism.  
Today I mastered 3 critical rules that govern it.

---

## 📐 Rule 1 — The Drop Rule

> **"Once VALID is asserted, it MUST remain asserted until READY is seen HIGH on the same clock edge."**

- Handshake completes **only when** `VALID = 1` AND `READY = 1` on the **same clock edge**
- Master cannot deassert VALID mid-transaction — **ever**
- Violation = silent data corruption or permanent bus deadlock

```
CLK     : __|‾|__|‾|__|‾|__|‾|__
AWVALID : ______|‾‾‾‾‾‾‾‾‾‾‾‾|___   ← must HOLD
AWREADY : __________|‾‾‾‾|______    ← slave responds
                     ↑
               Transfer HERE (both HIGH same edge)
```

---

## 📐 Rule 2 — Source Dependency / Circular Dependency

> **"Master VALID must NEVER depend on Slave READY."**

| Who | Dependency | Legal? |
|-----|-----------|--------|
| Master | VALID waits for READY | ❌ ILLEGAL |
| Slave | READY waits for VALID | ✅ LEGAL |
| Slave | READY asserted before VALID | ✅ LEGAL |

**Violation = Circular Dependency = Permanent Deadlock**

```
CLK     : __|‾|__|‾|__|‾|__|‾|__
AWREADY : ________________________  ← never asserts (waiting for VALID)
AWVALID : ________________________  ← never asserts (waiting for READY)
T=0, T=1, T=2 ... T=∞ → FROZEN. No transfer ever.
```

---

## 📐 Rule 3 — Write Channel Ordering (AW vs W)

> **"AXI4 spec mandates NO fixed ordering between AW and W channels."**

All 3 cases are **legal**:

| Case | Order | Legal? |
|------|-------|--------|
| Case 1 | AW first, then W | ✅ |
| Case 2 | W first, then AW | ✅ |
| Case 3 | AW and W simultaneous | ✅ |

**Slave FSM must handle all 3 cases. Assuming AW-always-first = design bug = silent deadlock.**

Minimum FSM states required:

```
[IDLE] → GOT_AW (waiting for W)
[IDLE] → GOT_W  (waiting for AW)
[IDLE] → BOTH_RECEIVED (simultaneous)
GOT_AW + W arrives → BOTH_RECEIVED
GOT_W  + AW arrives → BOTH_RECEIVED
BOTH_RECEIVED → Write to memory → Assert BVALID → Wait BREADY → [IDLE]
```

---

## 🖊️ Timing Diagrams

All 4 diagrams hand-sketched and stored in this folder:

| File | Content |
|------|---------|
| `legal handshake.png` | Normal valid handshake flow |
| `drop rule.png` | VALID drop violation |
| `circular dependency-deadlock.png` | Master-Slave deadlock scenario |
| `channel ordering.png` | AW vs W — all 3 legal cases |

---

## 📊 Day 1 Score

| Concept | Self-Assessment | Coach Score |
|---------|----------------|-------------|
| Drop Rule | Understood direction | 8/10 |
| Circular Dependency | Deadlock caught, name missed | 7/10 |
| Channel Ordering | Software thinking caught | 8/10 |
| **End of Day understanding** | **Corrected & solid** | **8/10** |

> *Mistakes made → mistakes corrected → concepts locked. That's the process.*

---

## 🔗 Part of

**[7-Days AMBA AXI4-Lite Protocol Sprint]**  
`7-days--AMBA-Protocol-Series` repository  
Goal: Build a Memory-Mapped AXI4-Lite Slave + Verification IP from scratch.

---

*Shiwank Gupta | Nik-Coronics | VLSI R&D*