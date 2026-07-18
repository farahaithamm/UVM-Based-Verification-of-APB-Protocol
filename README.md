# UVM-Based Verification of APB Protocol

UVM verification environment for an AMBA APB (Advanced Peripheral Bus) design — master, slave, and full wrapper (1 master + 2 slaves).

Specification reference: [AMBA APB Protocol Specification (IHI0024C)](IHI0024C_amba_apb_protocol_spec.pdf).

---

## Architecture Overview

```
                    ┌─────────────────────────────────────────┐
  Host side         │              APB_WRAPPER                │
  ─────────         │                                         │
  addr, sel,        │   ┌────────────┐      PSEL[0]  ┌──────┐ │
  transfer,         │   │            │──────────────►│Slave0│ │
  wr_en, wdata, ───►│──►│ APB_MASTER │  APB bus      │ mem  │ │
  strb              │   │  FSM       │──────────────►│      │ │
                    │   │            │  PSEL[1]      └──────┘ │
  OUTDATA,          │   │            │──────────────►┌──────┐ │
  valid_out,   ◄────│◄──│            │               │Slave1│ │
  PSLVERR           │   └────────────┘               │ mem  │ │
                    │         ▲                      └──────┘ │
                    │         │ mux PREADY/PRDATA/PSLVERR     │
                    │         └──────── by sel ───────────────┘
                    └─────────────────────────────────────────┘
```

| Module | Role |
|--------|------|
| **APB Master** | Converts host requests into APB transfers via a 3-state FSM (`IDLE → SETUP → ACCESS`) |
| **APB Slave** | 128-word memory with byte-strobe writes and slave-error on out-of-range addresses |
| **APB Wrapper** | Integrates one master with two slaves and routes responses based on slave select |

**Parameters:** 32-bit address/data, 4-bit strobes, slave memory depth 128.

RTL sources: [`rtl/`](rtl/).

---

## DUT Behavior

### APB Master FSM

States: `IDLE`, `SETUP`, `ACCESS`.

| Current | Condition | Next |
|---------|-----------|------|
| IDLE | transfer requested | SETUP |
| IDLE | no transfer | IDLE |
| SETUP | always | ACCESS |
| ACCESS | ready + another transfer | SETUP (back-to-back) |
| ACCESS | ready + transfer done | IDLE |
| ACCESS | not ready | ACCESS (wait state) |

Host controls (address, write/read, data, strobes, slave select) are forwarded onto the APB bus. Enable is asserted only during ACCESS. On a successful read (ready, no error), the master returns read data to the host with a valid indication; otherwise the host output stays inactive.

### APB Slave

- Memory-mapped peripheral with 128 valid locations
- Byte-strobe writes (partial-word updates)
- Reads return the stored word
- Ready is asserted when the slave is selected and in the access phase (no internal wait states in this RTL)
- Slave error is raised for addresses outside the legal memory range

### APB Wrapper

Connects one master to two identical slaves. The host select chooses which slave is active and which slave’s ready / read-data / error response is returned to the master.

---

## Verification Goals

The environment aims to prove:

1. **Protocol compliance** — APB timing (SETUP/ACCESS), enable/select rules, control stability during waits  
2. **Functional correctness** — correct data path for reads/writes, strobe masking, dual-slave routing  
3. **Error handling** — illegal addresses produce slave error and do not corrupt valid read indication  
4. **Corner cases** — wait states, back-to-back transfers, reset during traffic, mixed R/W  

Verification is organized **bottom-up**: unit TBs for master and slave first, then a system TB for the full wrapper.

---

## Verification Architecture


| Testbench | DUT | Stimulus approach | Main focus |
|-----------|-----|-------------------|------------|
| **Master TB** | Master only | Host stimulus; driver models slave responses (ready, read data, error, wait cycles) | FSM, host↔APB behavior, wait states, read-data path |
| **Slave TB** | Slave only | Driver acts as an APB master BFM (SETUP then ACCESS) | Memory, strobes, ready/error responses |
| **Wrapper TB** | Full wrapper | Host stimulus only; real slaves respond | Integration, dual-slave mux, end-to-end integrity |

---

## Verification Plan by Testbench

### 1. Master unit verification

Isolates the master FSM and host/APB behavior. The driver models slave responses so wait states and errors are fully controllable.

**Verified:** host fields on the APB bus, one-hot slave select, enable only in ACCESS, wait-state hold, back-to-back transfers, successful read data/valid, no valid on write or error, control stability while waiting.

**Checks:** scoreboard with an independent FSM predictor; **27** SVA assertions.

---

### 2. Slave unit verification
Isolates memory and response logic using a protocol-accurate master BFM.

**Verified:** byte-strobed writes, correct read data, ready only when selected and enabled, error for illegal addresses, strobe legality (active on write, clear on read).

**Checks:** scoreboard with a reference memory; **11** SVA assertions.


### 3. System (wrapper) verification
Catches integration issues that unit TBs cannot (muxing, dual memories, real ready timing).

**Verified:** slave selection and response routing, end-to-end write→read integrity on both slaves, error propagation, back-to-back transfers, select stable during an active transfer.

**Checks:** dual reference memories in the scoreboard; **25** SVA assertions.

---

## Stimulus Strategy

### Sequence plan (all tests)

| Sequence | Purpose |
|----------|---------|
| **Reset** | Initialize DUT and clear scoreboard state |
| **Write** | Stress writes and strobes (~500 transactions) |
| **Read** | Stress the read-data path (~500) |
| **Read/Write** | Mixed traffic with strobe constraints (~500) |

### Constrained-random policy

| Aspect | Intent |
|--------|--------|
| Address | Mostly legal range; smaller share of illegal addresses for error injection |
| Read / Write | Balanced |
| Slave select | Balanced across both slaves |
| Reset | Rare during traffic |
| Strobes | Legal combinations enforced (non-zero on write, zero on read) |
| Wait cycles (master TB) | Random 0–3 cycle delays before ready to hit wait-state coverage |
| Transfer patterning (wrapper TB) | Alternating transfer intent to hit back-to-back SETUP after ACCESS |

---

## Checking Strategy (3 layers)

| Layer | What it catches |
|-------|-----------------|
| **Scoreboard** | Functional mismatches: wrong data, missing valid, incorrect error, bad FSM-related outputs |
| **SVA** | Protocol/temporal violations: illegal timing, unstable controls, enable/select rules |
| **Monitor + clocking blocks** | Clean sampling without races between driver and checker |

Scoreboards report total match / mismatch counts at end of test (`report_phase`).

---

## Coverage Strategy

Functional coverage is collected in a subscriber covergroup, sampled on every monitored transaction.

### Coverpoints
- Reset levels and transitions
- Full legal address space + illegal-address bin
- Transfer, write/read, select, strobes, ready, enable, valid, error

### Crosses & illegal bins
- Address × error (legal↔no-error, illegal↔error)
- Write × strobe (illegal: write with empty strobes, read with active strobes)
- Valid × write (illegal: valid during write)
- Ready × valid (illegal: valid while not ready)
- Select × enable (ignore impossible enable-without-select on slave TB)

### Results

| Testbench | Total | Functional coverage | Assertion coverage |
|-----------|-------|---------------------|--------------------|
| Master | 99.98% | 99.96% | 100% (27) |
| Slave | 99.98% | 99.94% | 100% (11) |
| Wrapper | 99.99% | 99.97% | 100% (25) |

Reports: each TB’s `sim/coverage.txt` and `coverage.ucdb`.

---

## Repository Layout

```
├── rtl/              Design RTL (master, slave, wrapper)
├── master_uvm/       Master unit testbench
├── slave_uvm/        Slave unit testbench
├── wrapper_uvm/      System (wrapper) testbench
└── IHI0024C_*.pdf    APB protocol specification
```

Each UVM directory is self-contained: interface, agent stack, sequences, scoreboard, coverage, assertions, test, top, and simulation scripts.

---

## Tools & How to Run

- **Language:** SystemVerilog + UVM  
- **Simulator:** Siemens Questa / ModelSim  

From each testbench’s `sim/` folder, run `run.do` for coverage-enabled simulation, waves, and coverage report/UCDB generation.

---

## Protocol Summary

APB uses a minimum **two-cycle** transfer:

1. **SETUP** — select high, enable low; address/control valid  
2. **ACCESS** — enable high; completes when ready is high  

Wait states extend ACCESS while ready is low; controls must stay stable. Writes carry write data and strobes; reads return read data. Slaves may assert error on the completing cycle of a transfer.
