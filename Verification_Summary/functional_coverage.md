# Functional Coverage Report — `mod12_pkg::sb::mod12_cg`

Generated from Synopsys Unified Coverage Report (`urg`) for [`env_lib/sb.sv`](../env_lib/sb.sv).

## 1. Group Overview

| Metric | Value |
| :--- | :---: |
| **Covergroup** | `mod12_pkg::sb::mod12_cg` |
| **Instance** | `top.test_h.env_h.sb_h.mod12_cg` |
| **Score** | `100.00%` |
| **Instances** | `100.00%` (`1` instance) |
| **Weight** | `1` |
| **Goal** | `100` |
| **At Least** | `1` |
| **Per Instance** | `1` |
| **Auto Bin Max** | `64` |
| **Print Missing** | `64` |

---

## 2. Category Summary

| Category | Expected | Uncovered | Covered | Percent |
| :--- | :---: | :---: | :---: | :---: |
| **Variables** | 10 | 0 | 10 | **100.00%** |
| **Crosses** | 2 | 0 | 2 | **100.00%** |
| **Total** | **12** | **0** | **12** | **100.00%** |

---

## 3. Coverpoint Summary

| Variable | Expected | Uncovered | Covered | Percent | Goal | Weight | At Least |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `RESET` | 2 | 0 | 2 | `100.00%` | 100 | 1 | 1 |
| `MODE` | 2 | 0 | 2 | `100.00%` | 100 | 1 | 1 |
| `LOAD` | 2 | 0 | 2 | `100.00%` | 100 | 1 | 1 |
| `DATA_IN` | 3 | 0 | 3 | `100.00%` | 100 | 1 | 1 |
| `COUNT` | 1 | 0 | 1 | `100.00%` | 100 | 1 | 1 |

---

## 4. Cross Summary

| Cross | Samples Crossed | Expected | Uncovered | Covered | Percent | Goal | Weight | At Least |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `COUNT2` | `MODE`, `COUNT` | 2 | 0 | 2 | `100.00%` | 100 | 1 | 1 |

---

## 5. Detailed Bin Breakdown

### `RESET` (100.00% — 2/2 User-Defined Bins)
| Bin Name | Hit Count | At Least | Status |
| :--- | :---: | :---: | :---: |
| `reset_deasserted` | 21 | 1 | Covered |
| `reset_asserted` | 3 | 1 | Covered |

### `MODE` (100.00% — 2/2 User-Defined Bins)
| Bin Name | Hit Count | At Least | Status |
| :--- | :---: | :---: | :---: |
| `up_count` | 11 | 1 | Covered |
| `down_count` | 13 | 1 | Covered |

### `LOAD` (100.00% — 2/2 User-Defined Bins)
| Bin Name | Hit Count | At Least | Status |
| :--- | :---: | :---: | :---: |
| `load_enabled` | 6 | 1 | Covered |
| `load_disabled` | 18 | 1 | Covered |

### `DATA_IN` (100.00% — 3/3 User-Defined Bins)
| Bin Name | Hit Count | At Least | Status |
| :--- | :---: | :---: | :--- |
| `valid_data` (`[0:4]`) | 20 | 1 | Covered |
| `count_values1` (`[5:9]`) | 4 | 1 | Covered |
| `count_values2` (`[9:11]`) | 1 | 1 | Covered |
| `invalid_data` (`[12:15]`) | 0 | — | Illegal (0 hits) |

### `COUNT` (100.00% — 1/1 User-Defined Bin)
| Bin Name | Hit Count | At Least | Status |
| :--- | :---: | :---: | :--- |
| `count_values` (`[0:11]`) | 22 | 1 | Covered |
| `invalid_count` (`[12:15]`) | 0 | — | Illegal (0 hits) |

### `COUNT2` (`cross MODE, COUNT` — 100.00% — 2/2 Cross Bins)
| `MODE` | `COUNT` | Hit Count | At Least | Status |
| :--- | :--- | :---: | :---: | :---: |
| `up_count` | `count_values` | 11 | 1 | Covered |
| `down_count` | `count_values` | 11 | 1 | Covered |
