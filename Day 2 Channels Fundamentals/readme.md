# Day 2 — 5-Channel Architecture & Signal Mapping

> **7-Days AMBA AXI4-Lite Protocol Sprint**
> **Nik-Coronics | Independent R&D Initiative**
> **Date:** 27 June 2026

---

## 🎯 What I Learned Today

AXI4-Lite has 5 completely independent, decoupled channels.
Each channel has its own VALID/READY handshake.
No channel blocks another — this is the core advantage over AHB.

---

## 📐 The 5 Channels — Complete Signal Map

### Write Path: AW + W + B

| Signal | Width | Direction | Purpose |
|--------|-------|-----------|---------|
| AWVALID | 1b | M→S | Address valid |
| AWREADY | 1b | S→M | Slave ready |
| AWADDR | 32b | M→S | Target address |
| AWPROT | 3b | M→S | Access protection |
| WVALID | 1b | M→S | Data valid |
| WREADY | 1b | S→M | Slave ready |
| WDATA | 32b | M→S | Write data |
| WSTRB | 4b | M→S | Byte lane enables |
| BVALID | 1b | S→M | Response valid |
| BREADY | 1b | M→S | Master ready |
| BRESP | 2b | S→M | Write response |

### Read Path: AR + R

| Signal | Width | Direction | Purpose |
|--------|-------|-----------|---------|
| ARVALID | 1b | M→S | Address valid |
| ARREADY | 1b | S→M | Slave ready |
| ARADDR | 32b | M→S | Read address |
| ARPROT | 3b | M→S | Access protection |
| RVALID | 1b | S→M | Data valid |
| RREADY | 1b | M→S | Master ready |
| RDATA | 32b | S→M | Read data |
| RRESP | 2b | S→M | Read response |

---

## 📐 WSTRB — Byte Lane Control

```
WSTRB = 4'b1111 → Full 32-bit write
WSTRB = 4'b0001 → Byte write  [7:0]
WSTRB = 4'b0011 → Halfword   [15:0]
WSTRB = 4'b1100 → Upper half [31:16]
```

---

## 📐 Response Codes — BRESP / RRESP

```
2'b00 = OKAY    — Transaction successful
2'b01 = EXOKAY  — Exclusive access OK
2'b10 = SLVERR  — Slave error
2'b11 = DECERR  — Decode error (no slave at address)
```

---

## 📐 AHB vs AXI4 — Why Decoupled Wins

```
AHB — Sequential:
Cycle 1: Write Address
Cycle 2: Write Data
Cycle 3: Write Done
Cycle 4: Read Address   ← blocked until write done
Cycle 5: Read Data

AXI4 — Parallel:
Cycle 1: AW + AR simultaneously
Cycle 2: W  + R  simultaneously
Cycle 3: B  (write response)
= Same work in 3 cycles vs 5 cycles
```

**Key property:** Channel Independence / Decoupled Architecture

---

## 🖊️ Hand-Sketched Diagrams

| File | Content |
|------|---------|
| `5channel-architecture.jpg` | Master↔Slave 5-channel overview |
| `aw-w-signals.jpg` | Write channel signal detail |
| `bresp-rresp-codes.jpg` | Response codes table |
| `ahb-vs-axi4.jpg` | Sequential vs parallel comparison |

---

## 📊 Day 2 Score

| Concept | Coach Score |
|---------|-------------|
| Channel identification & direction | 4/10 → corrected: 9/10 |
| Signal anatomy | 2/10 → corrected: 8/10 |
| Why 5 channels — physics | 3.5/10 → corrected: 9/10 |

> *Direction: Concepts click ho rahe hain. Signal-level detail aur roz improve hogi.*

---

## 🔗 Part of
**[7-Days AMBA AXI4-Lite Protocol Sprint]**
`7-days--AMBA-Protocol-Series` repository

---
*Shiwank Gupta | Nik-Coronics | VLSI R&D*