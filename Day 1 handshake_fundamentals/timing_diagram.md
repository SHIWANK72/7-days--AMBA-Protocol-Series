# Day 1 — AXI4-Lite Handshake Timing Diagrams

---

## DIAGRAM 1 — Legal Handshake (Normal Case)

```
CLK     : __|‾|__|‾|__|‾|__|‾|__|‾|__
AWVALID : ______|‾‾‾‾‾‾‾‾‾‾‾‾|_______
AWREADY : __________|‾‾‾‾‾‾‾‾‾‾‾‾|___
                     ↑
               Transfer HERE
               (both HIGH, same edge)
```

**Rule:** VALID assert hua → HOLD karo jab tak READY na aaye.  
**Handshake complete** = VALID & READY both 1 on same clock edge.

---

## DIAGRAM 2 — DROP RULE VIOLATION (Illegal ❌)

```
CLK     : __|‾|__|‾|__|‾|__|‾|__|‾|__
AWVALID : ______|‾‾‾‾|________________  ← ILLEGAL DROP
AWREADY : ____________________________  ← Slave still waiting
                        ↑
                 VALID dropped here
                 READY never came
                 = Silent Corruption / Deadlock
```

**Violation:** Master ne READY aane se pehle VALID gira diya.  
**Result:** Slave ghost address pe wait karega — silent bus hang.

---

## DIAGRAM 3 — Circular Dependency / Deadlock (Illegal ❌)

```
CLK     : __|‾|__|‾|__|‾|__|‾|__|‾|__
AWVALID : ____________________________  ← Master waiting for READY
AWREADY : ____________________________  ← Slave waiting for VALID

T=0 : AWVALID=0, AWREADY=0
T=1 : AWVALID=0, AWREADY=0
T=2 : AWVALID=0, AWREADY=0
T=∞ : FROZEN. No transfer ever.
```

**Root cause:** Master VALID → READY pe dependent = ILLEGAL  
**Spec rule:** Master must assert VALID independently.

---

## DIAGRAM 4 — Legal: Slave asserts READY before VALID ✅

```
CLK     : __|‾|__|‾|__|‾|__|‾|__|‾|__
AWREADY : __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__  ← Slave ready early
AWVALID : ____________|‾‾‾‾‾‾‾‾‾‾|__  ← Master asserts later
                       ↑
                 Handshake HERE ✅
```

**This is perfectly legal.**  
Slave READY → VALID pe dependent hona allowed hai.  
Slave pehle se ready baith sakta hai — koi issue nahi.

---

## DIAGRAM 5 — AW vs W Channel Ordering

### Case 1 — AW First ✅

```
CLK  : __|‾|__|‾|__|‾|__|‾|__|‾|__
AW   : ______|‾‾‾‾|________________  ← Address first
W    : __________|‾‾‾‾|____________  ← Data after
B    : ______________|‾‾‾‾|________  ← Response after both
```

### Case 2 — W First ✅

```
CLK  : __|‾|__|‾|__|‾|__|‾|__|‾|__
W    : ______|‾‾‾‾|________________  ← Data first
AW   : __________|‾‾‾‾|____________  ← Address after
B    : ______________|‾‾‾‾|________  ← Response after both
```

### Case 3 — Simultaneous ✅

```
CLK  : __|‾|__|‾|__|‾|__|‾|__|‾|__
AW   : ______|‾‾‾‾|________________  ← Address + Data
W    : ______|‾‾‾‾|________________     same time
B    : __________|‾‾‾‾|____________  ← Fastest response
```

**Spec rule:** Koi bhi ordering legal hai.  
**Slave FSM** ko teeno cases handle karne padte hain.

---

## DIAGRAM 6 — Complete Write Transaction Flow

```
CLK      : __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
AWVALID  : ______|‾‾‾‾‾‾‾‾‾‾‾‾|___________________
AWREADY  : __________|‾‾‾‾‾‾‾‾‾‾‾‾|_______________
                      ↑ AW Handshake
WVALID   : ______|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|_______________
WREADY   : ______________|‾‾‾‾‾‾‾‾‾‾‾‾|___________
                          ↑ W Handshake
BVALID   : ____________________________|‾‾‾‾‾‾|___
BREADY   : ________________________________|‾‾‾‾|_
                                            ↑ B Handshake
```

**Full write = AW handshake + W handshake + B handshake**  
Teeno complete hone ke baad transaction done.

---

## Summary Table — Legal vs Illegal

| Scenario | Legal? | Consequence if violated |
|---|---|---|
| VALID drop before READY | ❌ ILLEGAL | Silent corruption, deadlock |
| READY before VALID (Slave) | ✅ LEGAL | Normal operation |
| Master VALID depends on READY | ❌ ILLEGAL | Circular deadlock |
| Slave READY depends on VALID | ✅ LEGAL | Normal operation |
| AW always before W | ❌ Wrong assumption | Slave FSM hang |
| Any AW/W ordering | ✅ LEGAL | FSM must handle all 3 |