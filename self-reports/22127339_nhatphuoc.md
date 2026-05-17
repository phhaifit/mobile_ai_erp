# Báo cáo cá nhân — Phase 1 & Phase 2

> **Hướng dẫn:** copy file này, đổi tên thành `<MSSV>_<GitHub>.md` (vd `22127380_nguyenhuytan2004.md`), đặt vào folder `self-reports/` ở root của repo đề tài (đường dẫn cuối: `self-reports/<MSSV>_<GitHub>.md`). Nếu folder chưa tồn tại, tự tạo. Commit vào branch riêng `self-report/<MSSV>`, tạo PR rồi **tự merge PR của chính mình** (không cần review).
>
> Mục tiêu: bạn tự xác nhận phần đóng góp của mình ở Phase 1 và Phase 2. Đặc biệt quan trọng cho các ticket co-assigned (chia điểm), API thêm/sửa, và những công việc không nằm trong ticket chính thức.

---

## 1. Thông tin cá nhân

| Field | Giá trị |
|---|---|
| Họ tên | Võ Nhật Phước |
| MSSV | 22127339 |
| GitHub ID | nhatphuoc |
| Email | vonhatphuoc32@gmail.com |
| Đề tài | ERP |
| Nhóm | Nhóm 5 |
| Repo đề tài | https://github.com/phhaifit/mobile_ai_erp |

---

## 2. Phase 1 — UI + Mock data

### 2.1 Ticket tôi là người implement

> Liệt kê tất cả ticket Phase 1 mà bạn được assign (hoặc đồng-assign). Với mỗi ticket, kê khai phần điểm bạn nhận. Nếu co-assigned, ghi rõ cách chia với bạn cùng đề tài (vd `15/5`).

| # | Issue | Tiêu đề | Estimate | Co-assignee (nếu có) | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #23 | [Phase 1] [Feature 21] Reports & Analytics | 20 | solo | 100% | 20 | [#34](https://github.com/phhaifit/mobile_ai_erp/pull/34)<br>[#36](https://github.com/phhaifit/mobile_ai_erp/pull/36) | https://www.youtube.com/watch?v=quoQVJe53N8 |

**Ghi chú thêm về co-assignee split** (nếu có chia không 50/50):
> PR `#36` là follow-up fix lỗi import/DI cho cùng feature `#23` sau PR chính `#34`, không phải ticket riêng.

**Phạm vi đã làm (issue #23):**
- Xây màn `Reports & Analytics`
- Thêm mock repository và models cho reports
- Thêm MobX store cho reports
- Wire route/DI để tích hợp màn vào app
- Thêm test cho reports store
- Fix follow-up ở PR `#36` để sửa lỗi import/DI sau khi merge PR chính

### 2.2 PR tôi đã review trong Phase 1

> Liệt kê các PR mà bạn đã review approve cho ticket Phase 1 của bạn khác. Theo rule: reviewer được +10% estimate ticket được review (chỉ tính PR đã merge).

| # | PR | Author | Issue được close | Trạng thái review của tôi |
|---|---|---|---|---|
| — | — | — | — | Không kê khai review |

### 2.3 Tổng kết Phase 1 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer | 20 |
| Reviewer bonus | 0 |
| **Tổng (uncapped)** | 20 |
| **Capped @10** | 10 |

---

## 3. Phase 2 — Full-flow integration với API

### 3.1 Ticket tôi là người implement

> Bao gồm cả sub-issue nếu bạn nhận sub-issue thay vì parent. Nếu nhận parent ticket co-assigned, ghi cả parent và sub-issue tương ứng.

| # | Issue | Tiêu đề | Estimate | Co-assignee | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #60 | [Phase 2][Feature 11][Full-integration] Storefront — Product Discovery | 20 | solo | 100% | 20 | [#99](https://github.com/phhaifit/mobile_ai_erp/pull/99) | https://youtu.be/6AuVdjQl8RI |

**Ghi chú co-assignee split / sub-issue split:**
> Không có.

**Phạm vi đã làm (issue #60):**
- Wire luồng `Storefront Product Discovery` với API
- Thêm `StorefrontApi` và endpoint/constants liên quan
- Thêm repository layer và models cho storefront
- Cập nhật product listing, filter, storefront home và product detail
- Polish lại UI/UX cho luồng discovery sau khi full integration

### 3.2 API tôi đã thêm hoặc chỉnh sửa (Phase 2 BE bonus)

> Theo rule Phase 2: +2đ cho mỗi API thêm mới, +1đ cho mỗi API chỉnh sửa. **Bắt buộc** phải có ticket BE riêng + PR có ≥2 approval.

Không có

### 3.3 PR tôi đã review trong Phase 2

| # | PR | Author | Issue được close | Trạng thái |
|---|---|---|---|---|
| — | — | — | — | Không kê khai review |

### 3.4 Tổng kết Phase 2 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer (FE ticket) | 20 |
| API bonus (BE work) | 0 |
| Reviewer bonus | 0 |
| **Tổng (uncapped)** | 20 |
| **Capped @15** | 15 |

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
| #__ |  |  |

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
| Võ Nhật Phước | 2026-05-17 |
