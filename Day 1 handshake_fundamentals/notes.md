\# Day 1 — AXI4-Lite Handshake Fundamentals (Notes)



\---



\## Q1 — DROP RULE



\*\*Rule:\*\* VALID, once asserted, cannot be deasserted  

until READY is seen HIGH in the same clock cycle.  

Handshake = VALID \& READY both HIGH on same edge.  

Violation = silent data corruption or bus deadlock.



```

CLK    : \_\_|‾|\_\_|‾|\_\_|‾|\_\_|‾|\_\_

AWVALID: \_\_\_\_\_\_|‾‾‾‾‾‾‾‾‾‾‾‾|\_\_\_   ← must HOLD

AWREADY: \_\_\_\_\_\_\_\_\_\_|‾‾‾‾|\_\_\_\_\_\_    ← slave responds

&#x20;                   ↑

&#x20;             Transfer happens HERE

&#x20;             (both HIGH same edge)

```



\---



\## Q2 — SOURCE DEPENDENCY / CIRCULAR DEPENDENCY



\- Master VALID must NOT depend on Slave READY  

\- Slave READY CAN be asserted before seeing VALID — legal ✅  

\- Violation = Circular Dependency = permanent deadlock  

\- Both signals stay LOW forever, no transfer ever happens  



\### LEGAL ✅ — Slave asserts READY before VALID:



```

CLK     : \_\_|‾|\_\_|‾|\_\_|‾|\_\_|‾|\_\_

AWREADY : \_\_|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|\_\_   ← Slave already waiting

AWVALID : \_\_\_\_\_\_\_\_|‾‾‾‾‾‾‾‾‾‾|\_\_   ← Master asserts whenever ready

&#x20;                  ↑

&#x20;            Handshake here ✅

```



\### ILLEGAL ❌ — Both waiting for each other:



```

CLK     : \_\_|‾|\_\_|‾|\_\_|‾|\_\_|‾|\_\_

AWREADY : \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_  ← never asserts (waiting for VALID)

AWVALID : \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_  ← never asserts (waiting for READY)

&#x20;                  DEADLOCK ❌

```



\---



\## Q3 — WRITE CHANNEL ORDERING



\- AXI4 spec: NO fixed ordering between AW and W channels  

\- All 3 cases legal: AW first, W first, simultaneous  

\- Slave FSM must handle all 3 cases  

\- Minimum states needed: IDLE, GOT\_AW, GOT\_W, BOTH\_RECEIVED  

\- Assuming AW-always-first = design bug = silent deadlock  



\### Slave FSM State Flow:



```

&#x20;        Reset

&#x20;          |

&#x20;          ▼

&#x20;       IDLE ──────────────────────────────┐

&#x20;        |                    |            |

&#x20;   AW aaya,             W aaya,      AW+W simultaneously

&#x20;   W nahi               AW nahi          aaye

&#x20;        |                    |            |

&#x20;        ▼                    ▼            ▼

&#x20;     GOT\_AW              GOT\_W      BOTH\_RECEIVED

&#x20;     (W ka wait)       (AW ka wait)      |

&#x20;        |                    |           |

&#x20;        └────────────────────┴───────────┘

&#x20;                             |

&#x20;                      Write to memory

&#x20;                      Assert BVALID

&#x20;                             |

&#x20;                      Wait for BREADY

&#x20;                             |

&#x20;                         Back to IDLE

```



\---



\## Key Takeaways — Day 1



| Rule | Who | Legal? |

|---|---|---|

| VALID drop before READY | Master | ❌ ILLEGAL |

| READY before VALID | Slave | ✅ LEGAL |

| VALID depends on READY | Master | ❌ ILLEGAL |

| READY depends on VALID | Slave | ✅ LEGAL |

| AW before W always | Anyone | ❌ Wrong assumption |

| Any ordering AW/W | Master | ✅ LEGAL |

