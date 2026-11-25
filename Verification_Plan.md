# Verification Plan — Mod-12 Up/Down Loadable Counter

## 1. Objective
This verification plan defines the strategy, architecture, test scenarios, functional coverage goals, and sign-off criteria for verifying the **Mod-12 Synchronous Up/Down Loadable Counter** (`mod12_counter` in `rtl/counter.sv`) using a layered SystemVerilog class-based testbench.

---

## 2. Design Under Test (DUT) Specification

### 2.1 Module & Interface
- **DUT Module:** `mod12_counter` (`rtl/counter.sv`)
- **Interface:** `mod_12_if` (`env_lib/interface.sv`)

| Signal | Width | Direction (DUT) | Description |
| :--- | :---: | :---: | :--- |
| `clk` | 1-bit | Input | System clock (`10 ns` period, `#5` toggle in `test/top.sv`) |
| `rst` | 1-bit | Input | Synchronous active-high reset (`count <= 4'd0`) |
| `load` | 1-bit | Input | Synchronous active-high parallel load (`count <= data_in`) |
| `mode` | 1-bit | Input | Count direction (`1` = Up-count, `0` = Down-count) |
| `data_in` | 4-bit | Input | Parallel load input value (valid range `0`–`11`) |
| `count` | 4-bit | Output | Current counter output (`0`–`11`) |

### 2.2 Functional Priority & Behavior
On every `posedge clk`:
1. **Reset (`rst == 1`):** Highest priority. Forces `count` to `4'd0`.
2. **Parallel Load (`load == 1`):** Second priority. Loads `data_in` into `count`.
3. **Up-Count (`mode == 1`):** Increments `count` by `1`; wraps `4'd11` $\rightarrow$ `4'd0`.
4. **Down-Count (`mode == 0`):** Decrements `count` by `1`; wraps `4'd0` $\rightarrow$ `4'd11`.

---

## 3. Verification Architecture

The testbench (`env/env.sv`, `env_lib/`, `test/`) follows a modular, mailbox-driven SystemVerilog architecture:

```text
+-------------+     gen2wr     +-------------+
|  mod12_gen  | -------------> |  write_drv  |
+-------------+                +-------------+
                                      | (wr_drv_cb)
                                      v
                               +-------------+
                               | mod12_counter| (DUT)
                               +-------------+
                                 ^         |
                   (wr_mon_cb)   |         | (rd_mon_cb)
                                 |         v
+-------------+    mon2rm      +-----------+     +----------+
|  write_mon  | -------------> | ref_model |     | read_mon |
+-------------+                +-----------+     +----------+
                                     |                 |
                               rm2sb |                 | mon2sb
                                     v                 v
                               +---------------------------+
                               |        sb (Scoreboard)    |
                               |  Checker + mod12_cg Cov   |
                               +---------------------------+
```

### Component Breakdown
| Component | File | Responsibility |
| :--- | :--- | :--- |
| **Interface** | `env_lib/interface.sv` | Defines `wr_drv_cb`, `wr_mon_cb`, `rd_mon_cb` (`default input #1 output #1`) and modports (`WR_DRV`, `WR_MON`, `RD_MON`, `DUT`). |
| **Transaction** | `env_lib/trans.sv` | `mod12_trans` encapsulates `rst`, `mode`, `load`, `data_in`, `count` with constrained randomization. |
| **Generator** | `env_lib/gen.sv` | `mod12_gen` randomizes `no_of_transactions` (`24` in `test/package.sv`) and puts them into `gen2wr`. |
| **Write Driver** | `env_lib/wr_drv.sv` | `write_drv` drives `rst`, `mode`, `load`, `data_in` onto `wr_drv_cb` on each clock edge. |
| **Write Monitor** | `env_lib/wr_mon.sv` | `write_mon` samples stimulus pins via `wr_mon_cb` and forwards to `ref_model` (`mon2rm`). |
| **Read Monitor** | `env_lib/rd_mon.sv` | `read_mon` samples DUT `count` via `rd_mon_cb` and forwards to `sb` (`mon2sb`). |
| **Reference Model** | `env_lib/rm.sv` | `ref_model` mirrors DUT priority (`rst` > `load` > `mode` up/down) to compute expected `ref_count`. |
| **Scoreboard** | `env_lib/sb.sv` | `sb` compares expected vs. actual `count` (`===`), logs pass/fail counts, samples `mod12_cg`, and triggers `DONE`. |
| **Environment & Test** | `env/env.sv`, `test/test.sv`, `test/top.sv` | Builds, connects, and runs all components; dumps FSDB waveforms (`wave_file1.fsdb`). |

---

## 4. Stimulus & Constraint Strategy

Constrained-random stimulus is defined in `mod12_trans` (`env_lib/trans.sv`):
- **Reset Distribution (`rst_c`):** `rst dist {0 := 90, 1 := 10}` — exercises normal operation while periodically testing synchronous reset recovery.
- **Mode Sequencing (`mode_c` & `mode_c2`):** `value_c` cycles `0`–`23`, holding `mode == 0` (down-count) for the first 12 transactions (`0..11`) and `mode == 1` (up-count) for the next 12 transactions (`12..23`), ensuring full wrap-around in both directions.
- **Load Distribution (`load_c`):** `load dist {0 := 60, 1 := 40}` — balances counting sequences with parallel load operations.
- **Input Data Validity (`data_in_c`):** When `load == 1`, `data_in inside {[0:11]}`; when `load == 0`, `data_in == 0`.

---

## 5. Verification Scenarios & Feature Matrix

| ID | Feature / Scenario | Stimulus Condition | Expected Behavior | Verification Method |
| :---: | :--- | :--- | :--- | :--- |
| **F1** | Synchronous Reset | `rst == 1` (regardless of `load`, `mode`, `data_in`) | `count` resets to `4'd0` on next `posedge clk` | Scoreboard (`sb`) + `RESET` coverpoint |
| **F2** | Parallel Load | `rst == 0`, `load == 1`, `data_in in [0:11]` | `count` loads `data_in` on next `posedge clk` | Scoreboard (`sb`) + `LOAD`, `DATA_IN` coverpoints |
| **F3** | Up-Count Increment | `rst == 0`, `load == 0`, `mode == 1`, `count < 11` | `count` increments by `1` | Scoreboard (`sb`) + `MODE`, `COUNT` coverpoints |
| **F4** | Up-Count Rollover | `rst == 0`, `load == 0`, `mode == 1`, `count == 11` | `count` wraps to `4'd0` | Scoreboard (`sb`) + `COUNT2` cross |
| **F5** | Down-Count Decrement | `rst == 0`, `load == 0`, `mode == 0`, `count > 0` | `count` decrements by `1` | Scoreboard (`sb`) + `MODE`, `COUNT` coverpoints |
| **F6** | Down-Count Underflow | `rst == 0`, `load == 0`, `mode == 0`, `count == 0` | `count` wraps to `4'd11` | Scoreboard (`sb`) + `COUNT2` cross |
| **F7** | Priority Arbitration | Simultaneous `rst=1, load=1` or `load=1, mode=0/1` | `rst` overrides `load`; `load` overrides `mode` | Constrained-random overlap + Scoreboard (`sb`) |
| **F8** | Out-of-Range Guard | `data_in` or `count` in `[12:15]` | Illegal bins in `DATA_IN` and `COUNT` must never hit | `illegal_bins` in `mod12_cg` |

---

## 6. Functional Coverage Plan (`mod12_cg`)

Defined in `env_lib/sb.sv`:
- **`RESET`:** `reset_asserted` (`{1}`), `reset_deasserted` (`{0}`)
- **`MODE`:** `down_count` (`{0}`), `up_count` (`{1}`)
- **`LOAD`:** `load_disabled` (`{0}`), `load_enabled` (`{1}`)
- **`DATA_IN`:** `valid_data` (`[0:4]`), `count_values1` (`[5:9]`), `count_values2` (`[9:11]`), `illegal_bins invalid_data` (`[12:15]`)
- **`COUNT`:** `count_values` (`[0:11]`), `illegal_bins invalid_count` (`[12:15]`)
- **`COUNT2` (Cross):** `cross MODE, COUNT` — verifies all `0..11` counter values are reached in both up and down modes.

---

## 7. Simulation & Regression Flow

The project supports both **Synopsys VCS / Verdi** and **Mentor QuestaSim** via `sim/Makefile`:
- **VCS:** `make TC1_VCS`, `make regress_123_VCS`, `make view_wave_VCS`
- **QuestaSim:** `make TC1_Questa`, `make regress_123_Questa`, `make view_wave_Questa`
- **Waveform Evidence:** `Wave_VCS.png` and `Wave_Questa.png`
- **Simulation Log:** `Verification_Summary/result.md`

---

## 8. Sign-Off Criteria & Current Status

| Criterion | Target | Observed Status (`Verification_Summary/result.md`) |
| :--- | :---: | :---: |
| Transactions Verified | `24` (`no_of_transactions`) | `24` |
| Scoreboard Pass / Fail | `FAIL COUNT == 0` | `PASS = 24`, `FAIL = 0` |
| Functional Coverage (`mod12_cg`) | `100.00%` | `100.00%` |
| Illegal Bins Hit | `0` | `0` |

---

## 9. Recommended Future Enhancements
1. **RTL Coding Style Fix:** Line 17 of `rtl/counter.sv` uses a blocking assignment (`intf.count = intf.count + 1;`) inside `always_ff`; update to non-blocking (`<=`) for strict synthesis/simulation safety.
2. **Enable Cross Coverage:** Uncomment `MODE_LOAD` and `RESET_LOAD` crosses in `env_lib/sb.sv` to explicitly track priority-override combinations.
3. **SVA Assertions:** Add SystemVerilog Assertions in `mod_12_if` to check reset priority, valid `count <= 11` bounds, and rollover transitions directly at the interface.
