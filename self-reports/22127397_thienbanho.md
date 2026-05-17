# Báo cáo cá nhân — Phase 1 & Phase 2
---

## 1. Thông tin cá nhân

| Field       | Giá trị                              |
| ----------- | ------------------------------------ |
| Họ tên      | Nguyễn Trần Đức Thiện                |
| MSSV        | 22127397                             |
| GitHub ID   | thienbanho                           |
| Email       | thienbanho@gmail.com                 |
| Đề tài      | ERP                                  |
| Nhóm        | Nhóm 5                               |
| Repo đề tài | https://github.com/phhaifit/mobile_ai_erp (FE) + https://github.com/myjarvis/ai-erp-be (BE) |

---

## 2. Phase 1 — UI + Mock data

### 2.1 Ticket tôi là người implement

| #   | Issue | Tiêu đề                                   | Estimate | Co-assignee | % chia của tôi | Điểm tôi nhận | PR (link)                                                       | Demo / Video |
| --- | ----- | ----------------------------------------- | -------- | ----------- | -------------- | ------------- | --------------------------------------------------------------- | ------------ |
| 1   | #10   | Web Builder module (UI + mock data)       | 20       | solo        | 100%           | 20            | [#29](https://github.com/phhaifit/mobile_ai_erp/pull/29)        |              |

**Phạm vi đã làm (PR #29):**
- Scaffold web builder module + routes
- Dashboard 3 section cards
- Store Settings screen (form UI + mock data)
- Theme List + Theme Detail screens (live preview, color customization)
- CMS Page List (mock data + status filter) + CMS Page Editor (block-based content builder)
- Refactor sang clean architecture: domain entities, repository interfaces + mock impls, use cases, MobX stores (CmsPageStore, WebThemeStore, StoreSettingsStore), DI registration
- Polish responsive layout, empty states, consistent theming

### 2.2 PR tôi đã review trong Phase 1

| #   | PR    | Author | Issue được close | Trạng thái review của tôi |
| --- | ----- | ------ | ---------------- | ------------------------- |
| —   | —     | —      | —                | Không review PR nào       |

> Không có review nào trong Phase 1.

### 2.3 Tổng kết Phase 1 (tự chấm)

| Mục                 | Điểm        |
| ------------------- | ----------- |
| Implementer         | 20          |
| Reviewer bonus      | 0           |
| **Tổng (uncapped)** | **20**      |
| **Capped @10**      | **10**      |

---

## 3. Phase 2 — Full-flow integration với API

### 3.1 Ticket tôi là người implement

| #   | Issue | Tiêu đề                                         | Estimate | Co-assignee | % chia của tôi | Điểm tôi nhận | PR (link)                                                          | Demo / Video |
| --- | ----- | ----------------------------------------------- | -------- | ----------- | -------------- | ------------- | ------------------------------------------------------------------ | ------------ |
| 1   | #10   | Web Builder — wire FE lên BE API (full flow)    | 20       | solo        | 100%           | 20            | [#100](https://github.com/phhaifit/mobile_ai_erp/pull/100)         |              |

**Phạm vi đã làm (PR #100):**
- `ERP DioClient` + `TenantInterceptor` + `WebBuilderApi` client
- Wire Store Settings + Themes vào BE (real API thay mock)
- Wire CMS Pages API (CRUD) + publish workflow
- Expose `publishPage` action trên `CmsPageStore`
- Field mapping camelCase ↔ entity (storeName ↔ name, slug ↔ urlSlug, pageType ↔ type, theme hex ↔ ARGB int...)

### 3.2 API tôi đã thêm hoặc chỉnh sửa (Phase 2 BE bonus)

> Issue tracking trên FE repo `phhaifit/mobile_ai_erp` (Feature 10 parent), implement trên BE repo `myjarvis/ai-erp-be` (branch `feat/ticket-57/web-builders`). 11 sub-issues `#83`–`#93` link vào parent FE Feature 10. PR gộp tất cả: [#82](https://github.com/myjarvis/ai-erp-be/pull/82) trên BE (merged 2026-05-03).

| #   | Loại     | Mô tả endpoint                                              | Ticket BE (sub-issue) | PR BE                                                          | Đã merge? | Điểm |
| --- | -------- | ----------------------------------------------------------- | --------------------- | -------------------------------------------------------------- | --------- | ---- |
| 1   | Thêm mới | `GET /store-settings` — lấy store settings của tenant       | [#83](https://github.com/phhaifit/mobile_ai_erp/issues/83) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 2   | Thêm mới | `PATCH /store-settings` — update store settings             | [#84](https://github.com/phhaifit/mobile_ai_erp/issues/84) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 3   | Thêm mới | `GET /cms-pages` — list CMS pages (paginate + filter)       | [#85](https://github.com/phhaifit/mobile_ai_erp/issues/85) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 4   | Thêm mới | `GET /cms-pages/:id` — detail page                          | [#86](https://github.com/phhaifit/mobile_ai_erp/issues/86) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 5   | Thêm mới | `POST /cms-pages` — create page                             | [#87](https://github.com/phhaifit/mobile_ai_erp/issues/87) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 6   | Thêm mới | `PATCH /cms-pages/:id` — update page                        | [#88](https://github.com/phhaifit/mobile_ai_erp/issues/88) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 7   | Thêm mới | `DELETE /cms-pages/:id` — soft delete                       | [#89](https://github.com/phhaifit/mobile_ai_erp/issues/89) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 8   | Thêm mới | `POST /cms-pages/:id/publish` — toggle publish state        | [#90](https://github.com/phhaifit/mobile_ai_erp/issues/90) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 9   | Thêm mới | `GET /themes` — list preset + custom themes                 | [#91](https://github.com/phhaifit/mobile_ai_erp/issues/91) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 10  | Thêm mới | `GET /themes/active` — lấy active theme của tenant          | [#92](https://github.com/phhaifit/mobile_ai_erp/issues/92) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |
| 11  | Thêm mới | `PATCH /themes/active` — set active theme + customization   | [#93](https://github.com/phhaifit/mobile_ai_erp/issues/93) | [#82](https://github.com/myjarvis/ai-erp-be/pull/82) | ✅ | 2 |

**Prisma models bổ sung dưới schema `erp`:** `store_settings`, `cms_pages`, `themes`, `tenant_active_themes` + reverse relations trên `tenants`.

**Tổng API bonus BE:** 11 × 2 = **22 điểm**.

### 3.3 PR tôi đã review trong Phase 2

| #   | PR    | Author          | Issue được close | Trạng thái       |
| --- | ----- | --------------- | ---------------- | ---------------- |
| 1   | [#112](https://github.com/phhaifit/mobile_ai_erp/pull/112) | (feature-20 author) | feature-20 (Role/User mgmt) | REQUESTED_CHANGES |

> Review chi tiết: file `pr-review-feature-20.md` ở root repo workspace. Xác định 5 bug chặn merge (DioClient sai, dead-code wrapped response, password required khiến GET fail, tenant_id trong body, Grant Role dialog reference user sai) + 6 vấn đề cần sửa + nits.

### 3.4 Tổng kết Phase 2 (tự chấm)

| Mục                     | Điểm   |
| ----------------------- | ------ |
| Implementer (FE ticket) | 20     |
| API bonus (BE work)     | 22     |
| Reviewer bonus          | 2      |
| **Tổng (uncapped)**     | **44** |
| **Capped @15**          | **39** |

---

## 4. Kê khai bổ sung (nếu có)

| #   | Mô tả | Bằng chứng (PR/commit/Slack link) |
| --- | ----- | --------------------------------- |
| —   | —     | —                                 |

---

## 5. Đề xuất điều chỉnh điểm (nếu có)

| Ticket / PR | Vấn đề | Đề xuất sửa |
| ----------- | ------ | ----------- |
| —           | —      | —           |

---

## 6. Tự đánh giá & rút kinh nghiệm (tùy chọn)

### Điều bạn làm tốt:

> Áp dụng clean architecture cho `web_builder` module ngay từ Phase 1 (domain/data/presentation tách rõ + MobX stores đăng ký qua GetIt), nên qua Phase 2 chỉ cần thay mock impl bằng real API mà không phải refactor UI.
>
> Tự đảm nhận cả BE (11 endpoints) và FE integration cho cùng một module — chủ động thiết kế Prisma schema, DTO, và mapping camelCase ↔ entity ở repo layer để khớp hai đầu.

### Khó khăn bạn gặp phải:

> Module web-builder bị block bởi các flow chưa hoàn thiện của nhóm (login/auth flow chưa stable, tenant context chưa có nguồn từ user session) — phải bypass bằng `--dart-define=TENANT_ID` và tự xử lý header `X-Tenant-Id` qua interceptor riêng cho ERP client.
>
> Mismatch giữa BE response shape và FE entity (vd theme không có `description` / `backgroundColor`) — phải derive ở client và xử lý mapping camelCase ↔ entity ở repo layer.

### Bạn sẽ làm khác đi điều gì nếu được làm lại:

> Thống nhất schema BE/FE (description, backgroundColor, các field overlap) ngay từ bước thiết kế DTO, thay vì code BE xong mới phát hiện FE thiếu trường và phải workaround.
>
> Tách rõ phần phụ thuộc cross-feature (auth/tenant) từ đầu để không phải bypass tạm thời ở module của mình.

---

## 7. Cam kết

- [x] Các thông tin trên là chính xác. Tôi sẽ chịu trách nhiệm nếu phát hiện kê khai sai sự thật (sao chép code, lấy điểm thay người khác, v.v.).
- [x] Tôi đồng ý cho thầy dùng dữ liệu này để chấm điểm môn LTDDNC 2026.

| Ký tên (gõ tên)         | Ngày       |
| ----------------------- | ---------- |
| Nguyễn Trần Đức Thiện   | 2026-05-14 |
