<div align="center">

# 🚀 7-Day AMBA AXI4-Lite Protocol Sprint
**Architecting, Coding, and Verifying an Industry-Standard SoC Interconnect IP**

[![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-00599C?style=for-the-badge&logo=c&logoColor=white)](https://github.com/SHIWANK72)
[![Protocol](https://img.shields.io/badge/Protocol-AMBA%20AXI4--Lite-FFB300?style=for-the-badge&logo=arm&logoColor=black)](https://github.com/SHIWANK72)
[![Status](https://img.shields.io/badge/Status-Active%20Sprint-00E5FF?style=for-the-badge)](https://github.com/SHIWANK72)

</div>

---

## 📌 Overview
Following the completion of my [14-Day RTL-to-DV Series](https://github.com/SHIWANK72), I am leveling up by diving deep into the backbone of modern System on Chips (SoCs): **The AMBA Protocol**.

This repository documents my intensive 7-day sprint (June 26 - July 02) focused entirely on the **AXI4-Lite** protocol. The objective is to design a Memory-Mapped AXI4-Lite Slave and build a robust Verification IP (VIP) using SystemVerilog.

### 🛠️ Daily Engineering Deliverables
This is not just about writing simulation code. Every day, this repository will be updated with comprehensive hardware design logs:
- **`[</>]`** **Synthesizable RTL:** SystemVerilog code for Datapath and Control logic.
- **`[👁️]`** **Schematics & FSMs:** Elaborated RTL Views and State Machine visualizations.
- **`[🗺️]`** **Physical Insights:** Pre/Post-Mapping results and Chip Planner logic lock layouts.
- **`[📈]`** **Verification:** Deep-dive Simulation Waveforms and strict SystemVerilog Assertions (SVA) logs.

---

## 📅 The 7-Day Execution Blueprint

| Day | Date | Focus Area | Deliverables | Status |
|:---:|:---:|:---|:---|:---:|
| **01** | June 26 | **Protocol Fundamentals & VALID/READY Handshake** | Handshake interlocks, Timing Diagrams | ⏳ *Upcoming* |
| **02** | June 27 | **Internal Signal Mapping & 5-Channel Architecture** | AW, W, B, AR, R Channel Deconstruction | ⏳ *Upcoming* |
| **03** | June 28 | **RTL Coding of Memory-Mapped AXI4-Lite Slave** | SV Modules, Interface Definitions | ⏳ *Upcoming* |
| **04** | June 29 | **Control Path Engineering & Interlock FSMs** | FSM Views, Concurrent R/W Logic | ⏳ *Upcoming* |
| **05** | June 30 | **SystemVerilog Verification IP (VIP) Environment** | Master BFM, Testbench Architecture | ⏳ *Upcoming* |
| **06** | July 01 | **Strict Protocol Checker via SV Assertions (SVA)** | Concurrent Assertions, Violation Catching | ⏳ *Upcoming* |
| **07** | July 02 | **Functional Coverage & Regression Sign-off** | Covergroups, Cross-coverage, Wrap-up | ⏳ *Upcoming* |

> **Note:** *Click on the respective "Day" folders in the repository to access the complete code, testbenches, and EDA tool screenshots.*

---

## 📂 Repository Structure

```text
📁 AMBA-AXI4-Lite-7Days-Sprint
 ├── 📂 Day_01_VALID_READY_Mechanics
 ├── 📂 Day_02_5_Channel_Architecture
 ├── 📂 Day_03_Slave_RTL_Design
 ├── 📂 Day_04_FSM_Control_Path
 ├── 📂 Day_05_VIP_Environment
 ├── 📂 Day_06_SVA_Protocol_Checker
 └── 📂 Day_07_Coverage_Signoff