# 5‑Stage Pipelined RISC‑V RV32I CPU in Verilog

![Language](https://img.shields.io/badge/HDL-Verilog-blue)
![Simulator](https://img.shields.io/badge/Sim-Icarus%20Verilog-green)
![Status](https://img.shields.io/badge/Tests-7%2F7%20Passing-brightgreen)

---

## Overview

A compact, synthesizable 5‑stage pipelined implementation of the
**RISC‑V RV32I** base integer ISA, written entirely in Verilog HDL.

Key features:
- Classic IF‑ID‑EX‑MEM‑WB pipeline architecture
- Full **data forwarding** unit resolving RAW hazards without stalls
- **Load‑use hazard detection** with automatic stall and bubble insertion
- **Branch resolution** with pipeline flush on taken branches
- Complete **RV32I instruction set** support including all branch types
- Modular RTL design — each stage and unit is a standalone Verilog module
- 7 self‑checking testbenches with 100% pass rate

---

## Architecture
IF → [IF/ID] → ID → [ID/EX] → EX → [EX/MEM] → MEM → [MEM/WB] → WB

### Pipeline Stages

| Stage | Module(s) | Function |
|-------|-----------|----------|
| IF | `pc_register.v`, `instr_memory.v` | Fetch instruction at current PC |
| ID | `decoder.v`, `register_file.v`, `imm_gen.v` | Decode instruction, read registers |
| EX | `alu.v`, `alu_control.v`, `branch_unit.v` | Execute operation, compute branch |
| MEM | `data_memory.v` | Load from / store to data memory |
| WB | (in `top.v`) | Write result back to register file |

### Source Files (23)

| Datapath Modules | Description |
|------------------|-------------|
| `alu.v` | 32‑bit ALU: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA, LUI |
| `register_file.v` | 32×32‑bit register file, x0 permanently zero |
| `imm_gen.v` | Sign-extends immediates for I, S, B, U, J, shift formats |
| `pc_register.v` | Program counter with synchronous reset and stall support |
| `instr_memory.v` | 256×32‑bit instruction ROM, hex-file loadable |
| `data_memory.v` | 256‑word data RAM, synchronous write, asynchronous read |
| `branch_unit.v` | Computes branch target and taken/not-taken decision |

| Control Modules | Description |
|-----------------|-------------|
| `decoder.v` | Decodes opcode → all pipeline control signals |
| `alu_control.v` | Two-level decode: alu_op + funct3 + funct7[5] → alu_ctrl |
| `forwarding_unit.v` | Detects RAW hazards, selects forwarded operands |
| `hazard_detect.v` | Detects load-use hazards, drives stall and flush signals |

| Pipeline Registers | Description |
|--------------------|-------------|
| `IF_ID_reg.v` | Latches PC and instruction word |
| `ID_EX_reg.v` | Latches all control signals, operands, register addresses |
| `EX_MEM_reg.v` | Latches ALU result, store data, branch signals |
| `MEM_WB_reg.v` | Latches memory read data and ALU result for writeback |

| Integration and Testbenches | Description |
|-----------------------------|-------------|
| `top.v` | Top-level: instantiates and connects all 15 RTL modules |
| `tb_top.v` | Full CPU integration test — 8-instruction program |
| `tb_alu.v` | Unit test: all 11 ALU operations and zero flag |
| `tb_register_file.v` | Unit test: x0 lock, write enable, simultaneous read/write |
| `tb_imm_gen.v` | Unit test: all 6 immediate formats |
| `tb_decoder.v` | Unit test: all 9 RV32I opcodes and control signals |
| `tb_alu_control.v` | Unit test: all 13 operation encodings |
| `tb_pc_instr_mem.v` | Unit test: PC reset, stall, memory addressing |

---

## Hazard Handling

### Data Hazards (RAW)
When an instruction needs a result that is still in the pipeline,
the forwarding unit detects the conflict and routes the result
directly from EX/MEM or MEM/WB back to the EX stage ALU inputs.
No stall is needed for ALU-to-ALU dependencies.
EX/MEM.ALUresult ──→ forward_a / forward_b ──→ ALU input
MEM/WB.WBdata    ──→ forward_a / forward_b ──→ ALU input

### Load‑Use Hazards
A load followed immediately by a dependent instruction cannot
be resolved by forwarding alone (data arrives one cycle too late).
The hazard detection unit stalls the PC and IF/ID register for
one cycle and inserts a bubble into ID/EX.
LW  x1, 0(x0)    ← EX stage (mem_read=1, rd=x1)
ADD x2, x1, x3   ← ID stage (rs1=x1) → STALL detected

### Control Hazards (Branches)
Branch outcome is resolved at the end of the EX stage.
On a taken branch, the pipeline flushes IF/ID and ID/EX
(replacing them with NOPs) and redirects the PC to the
branch target. This incurs a 2-cycle branch penalty.

---

## Simulation Results

| Testbench | What is Verified | Result |
|-----------|-----------------|--------|
| `tb_alu` | 11 ALU operations, zero flag | **PASS** |
| `tb_register_file` | x0 hardwire, write enable, RAW read | **PASS** |
| `tb_imm_gen` | I, S, B, U, J, shift immediates | **PASS** |
| `tb_decoder` | 9 opcode decodings, all control signals | **PASS** |
| `tb_alu_control` | 13 funct3/funct7 encodings | **PASS** |
| `tb_pc_instr_mem` | Reset, stall, word addressing | **PASS** |
| `tb_top` | 8-instruction program, forwarding, LW, BEQ | **PASS** |

**7/7 testbenches passing.**

Three bugs were identified and fixed during verification:
1. **Write-to-read bypass** — WB writeback data was not visible
   to the ID stage register reads in the same cycle
2. **Branch shadow** — one instruction past a taken branch was
   incorrectly allowed to execute
3. **Branch comparison** — signed and unsigned branch comparisons
   (BLT, BGE, BLTU, BGEU) were producing incorrect results

---

## How to Run

**Step 1 — Install Icarus Verilog**
```bash
# Windows (Chocolatey)
choco install iverilog

# Ubuntu / Debian
sudo apt-get install iverilog
```

**Step 2 — Compile**
```bash
cd RISC-V-CPU

iverilog -o cpu_sim \
  alu.v register_file.v imm_gen.v pc_register.v \
  instr_memory.v decoder.v alu_control.v \
  IF_ID_reg.v ID_EX_reg.v EX_MEM_reg.v MEM_WB_reg.v \
  data_memory.v branch_unit.v forwarding_unit.v \
  hazard_detect.v top.v tb_top.v
```

**Step 3 — Simulate**
```bash
vvp cpu_sim
```

**Step 4 — View waveforms (optional)**
```bash
gtkwave cpu_wave.vcd
```

---

## ISA Support

| Type | Instructions | Format |
|------|-------------|--------|
| Arithmetic | ADD, SUB, ADDI | R / I |
| Logical | AND, OR, XOR, ANDI, ORI, XORI | R / I |
| Shift | SLL, SRL, SRA, SLLI, SRLI, SRAI | R / I |
| Compare | SLT, SLTU, SLTI, SLTIU | R / I |
| Memory | LW, LH, LB, SW, SH, SB | I / S |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU | B |
| Jump | JAL, JALR | J / I |
| Upper imm | LUI, AUIPC | U |

---

## Tools Used

- **Icarus Verilog** — open-source Verilog simulator
- **GTKWave** — VCD waveform viewer
- **VS Code + TerosHDL** — HDL development environment
- **RARS** — RISC‑V assembler for test program development

---

## Learning Outcomes

- RTL design and modular Verilog coding style
- 5-stage pipeline architecture and timing
- Hazard classification and mitigation strategies
- Self-checking testbench methodology
- Digital verification workflow

---

## License

MIT License
