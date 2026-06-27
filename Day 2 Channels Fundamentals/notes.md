5 CHANNELS:
AW — Write Address  — Master → Slave
W  — Write Data     — Master → Slave
B  — Write Response — Slave  → Master
AR — Read Address   — Master → Slave
R  — Read Data      — Slave  → Master

WRITE GROUP: AW + W + B
READ GROUP:  AR + R

AW CHANNEL SIGNALS:
AWVALID  [1]   — Master: address is valid
AWREADY  [1]   — Slave: ready to accept
AWADDR   [32]  — Write address (32-bit = 4GB space)
AWPROT   [3]   — Protection: [Privileged, Secure, Instruction]
                 bit0: 0=Normal    1=Privileged
                 bit1: 0=Secure    0=Non-Secure  
                 bit2: 0=Data      1=Instruction

WHY 5 CHANNELS — DECOUPLED ARCHITECTURE:

AHB: Single shared bus — sequential only
AXI4: 5 independent channels — decoupled

Key property: "Channel Independence / Decoupled Channels"
Result: Write + Read can happen SIMULTANEOUSLY

Concrete example:
  AHB Cycle 1-3: Write completes → then read starts (cycle 4)
  AXI4 Cycle 1:  AW + AR fire simultaneously
  AXI4 Cycle 2:  W + R simultaneously
  = 2x throughput on same clock

W CHANNEL — WSTRB:
WSTRB[3:0] — 1 bit per byte lane
1111 = full 32b write
0001 = byte write (lowest)
0011 = halfword write

B CHANNEL — BRESP:
00 = OKAY
01 = EXOKAY  
10 = SLVERR  ← slave error
11 = DECERR  ← decode error

B channel = only 3 signals (BVALID, BREADY, BRESP)

AR CHANNEL SIGNALS:
ARVALID  [1]   — Master: read address valid
ARREADY  [1]   — Slave: ready to accept
ARADDR   [32]  — Read address
ARPROT   [3]   — Protection type (same as AWPROT)

R CHANNEL SIGNALS:
RVALID   [1]   — Slave: read data valid
RREADY   [1]   — Master: ready to accept data
RDATA    [32]  — Read data
RRESP    [2]   — Read response (00=OKAY, 10=SLVERR)

W CHANNEL SIGNALS:
WVALID   [1]   — Master: write data valid
WREADY   [1]   — Slave: ready to accept
WDATA    [32]  — Write data
WSTRB    [4]   — Byte lane strobes