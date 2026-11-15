# HW05 – Performance Testing (HW05-AI)

- **Student ID:** `23120264` | **Name:** Nguyễn Phúc Hoàng | **Class:** CQ2023/3
- **SUT:** EShop – https://github.com/ttbhanh/eshop-sut (local copy: `../eshop-sut-fithcmus`), backend API on `:3000`
- **Tools:** Apache JMeter, AI: Claude Code (claude-sonnet-5-5), resource monitor: Activity Monitor / htop
- **GitHub repo (public):** https://github.com/nphoang-itus/hw05-performance-testing
- **Demo video (unlisted YouTube):** `TODO`
- **Skill demo video:** `TODO`

## Workflow under test (endpoint option A)
`POST /api/login` (auth-heavy) → `GET /api/products?search=` and `GET /api/products/:id` (read-heavy) → `POST /api/cart` and `POST /api/checkout` (transactional). See `docs/endpoint-proposal.md`.

## Layout
| Path | Content |
|---|---|
| `testplans/` | `23120264_{Load,Stress,Spike}_<YYYYMMDD>.jmx` |
| `data/` | CSV inputs (credentials, products, order payloads) |
| `results/<scenario>/` | raw `.jtl` + HTML report folder (load, stress, spike, endurance) |
| `evidence/` | resource-monitor screenshots, hardware report |
| `docs/` | report, AI analysis, AI critique, AI audit report, bug report, CI proposal |
| `scripts/` | SUT start/reset, prompt log, PDF, commit log, zip |
| `.claude/skills/perf-testing/` | Agent Skill |

## Test summary
| Metric | Value |
|---|---|
| Scenarios run | TODO |
| Endpoint groups covered | TODO |
| Endurance threshold | TODO (max stable RPS / memory ceiling) |
| Bugs / performance issues | TODO |

## Self-assessment
| No. | Criteria | Grade | Self-Assessed Grade |
|---|---|---|---|
| 1 | Task 1 – Load testing | 30 | |
| 2 | Task 1 – Stress testing | 20 | |
| 3 | Task 1 – Spike testing | 20 | |
| 4 | Task 2 – AI analysis + misinterpretation hunt (correct values from raw logs) | 10 | |
| 5 | Task 3 – Continuous Performance Testing proposal (G9.6) | 10 | |
| 6 | Agent Skills | 10 | |
| | **Total** | **100** | |
