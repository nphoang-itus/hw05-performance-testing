# HW05 – Performance Testing: Checklist

> Nguồn: `2026.HW05.Performance Testing_En.pdf`. Tick `[x]` khi xong. Nộp trễ không được chấp nhận. Thiếu bất kỳ tài liệu bắt buộc nào thì bị 0 điểm.

## 0. Thông tin cá nhân (lấy từ HW04)

| Mục | Giá trị |
|---|---|
| Họ tên | Nguyễn Phúc Hoàng |
| MSSV | `23120264` |
| Lớp | CQ2023/3 |
| AI tool | Claude Code (claude-sonnet-5-5) |
| GitHub user | `nphoang-itus` |
| Repo HW05 (public) | `TODO` (gợi ý: `https://github.com/nphoang-itus/hw05-performance-testing`) |
| Hostname máy test | `SUPAR-Mega-Ukulele.local` (kiểm tra khớp với các HW trước) |
| Máy | Apple M4, 10 core, 16 GB RAM, macOS 27.2.1 |
| SUT (local) | `../eshop-sut-fithcmus` (backend `:3000`) |
| Công cụ | JMeter (mặc định) hoặc k6 (bonus). **Hiện chưa cài** JMeter/k6, Java 26 đã có |
| Resource monitor | Activity Monitor / htop |

Tên file zip: `23120264_HW05_AI_Performance_<SelfGrade>.zip`, với `SelfGrade` là số 3 chữ số trong [000, 100], ví dụ `23120264_HW05_AI_Performance_090.zip`.

Tên test plan: `{StudentID}_{ScenarioType}_{YYYYMMDD}`
- `23120264_Load_<YYYYMMDD>.jmx`
- `23120264_Stress_<YYYYMMDD>.jmx`
- `23120264_Spike_<YYYYMMDD>.jmx`

## 1. Chuẩn bị

- [ ] Cài JMeter và xác nhận chạy được (CLI `-n -t -l -e -o` để sinh `.jtl` và HTML report).
- [ ] Cài htop (hoặc dùng Activity Monitor) để theo dõi process `node` của backend.
- [ ] Tạo repo GitHub public cho HW05 và `git init` trong thư mục này.
- [ ] Chốt **3 nhóm endpoint** và báo team để không trùng (xem `docs/endpoint-proposal.md`).
- [ ] Chạy backend (`cd backend && node server.js`) và smoke-test các endpoint bằng curl.
- [ ] Lưu ý: backend **reseed DB mỗi lần khởi động**. Nó reset luôn account lockout, nên dùng cách này để reset giữa các lần chạy.

## 2. Task 1 – Thiết kế và chạy test có AI hỗ trợ (Load 30đ · Stress 20đ · Spike 20đ)

### 2.1 Thiết kế
- [ ] Làm việc với AI **từng bước** (phân tích workflow → chọn tham số → sinh plan → review), không dùng một prompt chung chung.
- [ ] 3 test plan (Load, Stress, Spike) cùng **một workflow end-to-end**, phủ đủ 3 nhóm endpoint: **auth-heavy**, **read-heavy**, **transactional**.
- [ ] AI giúp chọn tham số thực tế (think-time, ramp-up, số thread/VU) cho từng kịch bản, và giải thích ngắn gọn workflow phủ từng nhóm endpoint thế nào.
- [ ] **Data-driven bằng CSV** (credentials, product ID, order payload), dùng một hoặc nhiều file.
- [ ] **3 loại listener/report khác nhau**, không lặp giữa 3 plan (ví dụ View Results Tree, Summary Report, Aggregate Report).
- [ ] Đặt tên đúng `{StudentID}_{ScenarioType}_{YYYYMMDD}`.
- [ ] **Human review:** ghi lại AI sai hoặc thiếu gì (ramp-up/think-time phi thực tế, thread count sai, assertion yếu, thiếu xử lý lockout…) và giải thích **vì sao** (chất lượng prompt, giới hạn model hay đặc thù endpoint).

### 2.2 Chạy và thu bằng chứng (mỗi scenario)
- [ ] Load: chạy xong, có `.jtl` thô và thư mục HTML report.
- [ ] Stress: chạy xong, có `.jtl` thô và thư mục HTML report.
- [ ] Spike: chạy xong, có `.jtl` thô và thư mục HTML report.
- [ ] Screenshot JMeter cùng resource monitor của backend cho mỗi lần chạy.
- [ ] Hardware report: screenshot `fastfetch`/`screenfetch` và bảng spec, hostname khớp các HW trước.
- [ ] Khi Stress/Spike chạm lockout (3 lần sai), **reset** giữa các lần chạy và ghi lại các bước reset.
- [ ] **Endurance/soak test** 10–15 phút ở tải ổn định, để tìm ngưỡng của máy, kèm số liệu cụ thể (max stable RPS, memory ceiling…).
- [ ] Lưu `.jtl` **đầy đủ**, không chỉ summary.

### 2.3 Video demo
- [ ] YouTube **unlisted**, tổng ≥ **6 phút** (có thể chia clip theo scenario).
- [ ] JMeter và resource monitor **cùng một khung hình**.
- [ ] Giọng tự thuyết minh bằng **tiếng Việt**.

### 2.4 Bug / performance issue
- [ ] Ghi các lỗi thật (error response, crash, functional regression) lên GitHub Issues của repo kèm screenshot.
- [ ] Performance issue (latency cao, error rate tăng) nên ghi nhưng không bị trừ điểm nếu không có.

## 3. Task 2 – Phân tích bằng AI và tìm chỗ AI hiểu sai (10đ)

- [ ] Đưa `.jtl` cho AI phân tích và đề xuất ngưỡng hiệu năng.
- [ ] **Misinterpretation hunt:** với mỗi chỗ AI đọc sai metric, trích **giá trị đúng từ `.jtl` thô** và giải thích lỗi.
- [ ] Cho AI đề xuất tối ưu (index DB, connection pool, SQLite WAL…) rồi phân loại từng đề xuất là **feasible hay hallucinated**, kèm lý do.

## 4. Task 3 – Continuous Performance Testing (10đ)

- [ ] Mô hình theo dõi commit của SUT, quyết định có chạy perf test hay không, và flag hồi quy **p95**.
- [ ] Có **flow chart** (mermaid hoặc ảnh).
- [ ] Thảo luận **trade-off** (chi phí, false alarm).

## 5. Agent Skill (10đ)

- [ ] Skill đóng gói workflow performance testing và phân tích log, để tái dùng cho endpoint khác. Vị trí gợi ý: `.claude/skills/perf-testing/`.
- [ ] Video demo (YouTube) dùng skill trên **một nhóm endpoint hoàn chỉnh**, quay end-to-end.

## 6. Tài liệu bắt buộc

- [ ] **Main report** (MD + PDF): performance-testing report và AI-analysis critique.
- [ ] **AI Audit Report** (MD + PDF, phụ lục). Mỗi lượt ghi tên tool, ngày giờ, prompt, output (có thể tái dùng `scripts/ailog.py` của HW04).
- [ ] **AI Critique** 200–300 từ (MD + PDF), **do bạn tự viết**: AI sai/thiên lệch/thiếu ở đâu, vì sao không phát hiện, nguyên tắc rút ra.
- [ ] **Git commit log** (file text). Mỗi bước một commit: từng test plan, AI analysis, đề xuất CI.
- [ ] Repo public chứa test plan và data file.
- [ ] Bug report kèm screenshot Issues (nếu có).
- [ ] **README.md** gồm bảng tự chấm điểm và test summary: scenario đã chạy, nhóm endpoint phủ, ngưỡng endurance (kèm số), số bug/perf issue, link video demo.

## 7. Đóng gói và nộp

`.zip` cần có:
- [ ] Main report (MD + PDF)
- [ ] Link GitHub public (test plan + data)
- [ ] 3 test plan đúng quy ước tên
- [ ] 3 `.jtl` thô + 3 thư mục HTML report
- [ ] Screenshot resource monitor và hardware spec
- [ ] Link YouTube unlisted (demo + skill demo)
- [ ] AI Critique + AI Audit Report (MD + PDF)
- [ ] Git commit log (txt)
- [ ] Bug report + screenshot Issues (nếu có)
- [ ] `README.md` (self-assessment + test summary)
- [ ] Tài liệu hỗ trợ khác
- [ ] Đặt tên zip đúng, nộp Moodle trước deadline

## 8. Bảng tự chấm điểm (đưa vào README.md)

| No. | Criteria | Grade | Self-Assessed Grade |
|---|---|---|---|
| 1 | Task 1 – Load testing | 30 | |
| 2 | Task 1 – Stress testing | 20 | |
| 3 | Task 1 – Spike testing | 20 | |
| 4 | Task 2 – AI analysis + misinterpretation hunt (giá trị đúng từ raw logs) | 10 | |
| 5 | Task 3 – Continuous Performance Testing proposal (G9.6) | 10 | |
| 6 | Agent Skills | 10 | |
| | **Total** | **100** | |

## 9. Lưu ý quan trọng

- **Không được AI tạo/làm giả:** tên file plan, `.jtl` đầy đủ, video có giọng thật, hostname trong hardware report.
- Bloom-AI level cần thể hiện: G9.2 Apply, G9.3 Analyse, G9.4 Collaborate, G9.6 Disrupt.
- Copy giữa sinh viên (kể cả prompt) thì cả hai bị 0 điểm.
- 30% sinh viên có thể bị gọi bảo vệ miệng 5–7 phút trong tuần sau deadline.
- Tài liệu hoá bằng Markdown. Không sửa code SUT.
