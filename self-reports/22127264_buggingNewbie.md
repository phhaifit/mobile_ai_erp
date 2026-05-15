# Báo cáo cá nhân — Phase 1 & Phase 2

> **Hướng dẫn:** copy file này, đổi tên thành `<MSSV>_<GitHub>.md` (vd `22127380_nguyenhuytan2004.md`), đặt vào folder `self-reports/` ở root của repo đề tài (đường dẫn cuối: `self-reports/<MSSV>_<GitHub>.md`). Nếu folder chưa tồn tại, tự tạo. Commit vào branch riêng `self-report/<MSSV>`, tạo PR rồi **tự merge PR của chính mình** (không cần review).
>
> Mục tiêu: bạn tự xác nhận phần đóng góp của mình ở Phase 1 và Phase 2. Đặc biệt quan trọng cho các ticket co-assigned (chia điểm), API thêm/sửa, và những công việc không nằm trong ticket chính thức.

---

## 1. Thông tin cá nhân

| Field | Giá trị |
|---|---|
| Họ tên | Hoàng Túy Minh |
| MSSV | 22127264 |
| GitHub ID | buggingNewbie |
| Email | tuyminh.hoang@gmail.com |
| Đề tài | ERP |
| Nhóm | Nhóm 4 |
| Repo đề tài | https://github.com/phhaifit/mobile_ai_erp |

---

## 2. Phase 1 — UI + Mock data

### 2.1 Ticket tôi là người implement

> Liệt kê tất cả ticket Phase 1 mà bạn được assign (hoặc đồng-assign). Với mỗi ticket, kê khai phần điểm bạn nhận. Nếu co-assigned, ghi rõ cách chia với bạn cùng đề tài (vd `15/5`).

| # | Issue | Tiêu đề | Estimate | Co-assignee (nếu có) | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #12 | [Phase 1] [Feature 11] Storefront — Product Discovery | 10 | solo | 100% | 10 | #46<br>https://github.com/phhaifit/mobile_ai_erp/pull/46 | https://youtu.be/94xyzVvfkBU<br>https://youtu.be/cSoG5T6IEvU |

**Ghi chú thêm về co-assignee split** (nếu có chia không 50/50):
> _vd: "Ticket #8 chia 15/5 với @gankerV vì bạn ấy chỉ làm phần UI form, mình làm phần data layer + tests. Hai bên đã đồng ý qua DM ngày 22/03."_

### 2.2 PR tôi đã review trong Phase 1

> Liệt kê các PR mà bạn đã review approve cho ticket Phase 1 của bạn khác. Theo rule: reviewer được +10% estimate ticket được review (chỉ tính PR đã merge).

| # | PR | Author | Issue được close | Trạng thái review của tôi |
|---|---|---|---|---|
| 1 | #40 | Huỳnh Nguyễn Minh Khang (dodgero11) | [Phase 1] [Feature 15] Storefront — Customer Account Portal #16 | APPROVED |

### 2.3 Tổng kết Phase 1 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer | 10 |
| Reviewer bonus | 2 |
| **Tổng (uncapped)** | 12 |
| **Capped @10** | 10 |

---

## 3. Phase 2 — Full-flow integration với API

### 3.1 Ticket tôi là người implement

> Bao gồm cả sub-issue nếu bạn nhận sub-issue thay vì parent. Nếu nhận parent ticket co-assigned, ghi cả parent và sub-issue tương ứng.

| # | Issue | Tiêu đề | Estimate | Co-assignee | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #50 | [Phase 2][Feature 1][Full-integration] Product Core Management | 10 | solo | 50% | 5 | #140<br>https://github.com/phhaifit/mobile_ai_erp/pull/140 | https://drive.google.com/file/d/1DK3v5MNKXZBsFOKJkDfRw6bbs34IVNnZ/view?usp=sharing |

**Ghi chú co-assignee split / sub-issue split:**
Issue chưa hoàn thành tất cả task, split 50% cho sub-issue còn lại

### 3.2 API tôi đã thêm hoặc chỉnh sửa (Phase 2 BE bonus)

> Theo rule Phase 2: +2đ cho mỗi API thêm mới, +1đ cho mỗi API chỉnh sửa. **Bắt buộc** phải có ticket BE riêng + PR có ≥2 approval.

Không có

### 3.3 PR tôi đã review trong Phase 2

| # | PR | Author | Issue được close | Trạng thái |
|---|---|---|---|---|
| 1 | #139 | Huỳnh Nguyễn Minh Khang (dodgero11) | #63 [Phase 2][Feature 15][Full-integration] Storefront — Customer Account Portal | APPROVED |

### 3.4 Tổng kết Phase 2 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer (FE ticket) | 5 |
| API bonus (BE work) | 0 |
| Reviewer bonus | 2 |
| **Tổng (uncapped)** | 7 |
| **Capped @10** | 7 |

---

## 4. Kê khai bổ sung (nếu có)

> Phần này dành cho các đóng góp **không nằm trong ticket chính thức** nhưng bạn muốn thầy ghi nhận. Vd: bug fix khẩn cấp, refactor lớn, viết docs/test mà nhóm có dùng, support team khác...

| # | Mô tả | Bằng chứng (PR/commit/Slack link) |
|---|---|---|
| 1 |  |  |

---

## 5. Đề xuất điều chỉnh điểm (nếu có)

> Phần này để bạn báo các trường hợp ticket / PR mà bạn nghĩ phần kê khai ở §2–§4 chưa phản ánh đúng đóng góp (vd: bạn cùng đề tài được ghi nhận điểm mà thực tế không làm, hoặc ngược lại).

**Ticket / PR cần điều chỉnh:**

| Ticket / PR | Vấn đề | Đề xuất sửa |
|---|---|---|
| #__ | | |

---

## 6. Tự đánh giá & rút kinh nghiệm (tùy chọn)

> Phần optional, không tính điểm — nhưng giúp thầy hiểu hơn về quá trình bạn làm việc.

### Điều bạn làm tốt:

>

### Khó khăn bạn gặp phải:

>

### Bạn sẽ làm khác đi điều gì nếu được làm lại:

>

---

## 7. Cam kết

- [x] Các thông tin trên là chính xác. Tôi sẽ chịu trách nhiệm nếu phát hiện kê khai sai sự thật (sao chép code, lấy điểm thay người khác, v.v.).
- [x] Tôi đồng ý cho thầy dùng dữ liệu này để chấm điểm môn LTDDNC 2026.

| Ký tên (gõ tên) | Ngày |
|---|---|
| Hoàng Túy Minh | 16/5/2026 |
