# Đề xuất Backend API endpoint cho Performance Testing

Căn cứ: đọc `eshop-sut-fithcmus/backend/server.js` và `database.js`, không chạy thử. Các nhận định về bottleneck là **giả thuyết cần xác nhận bằng số liệu khi chạy**.

## Đặc điểm kiến trúc ảnh hưởng đến perf test

- Node.js + Express 5, **một process**, SQLite (`sqlite3`), không có connection pool, không rate-limit, không pagination.
- **DB bị reseed mỗi lần khởi động backend** (`DROP TABLE` + seed). Restart backend vừa là reset lockout, vừa dọn dữ liệu giữa các lần chạy.
- Seed rất nhỏ: **5 products, 2 users, 3 categories**. Muốn kịch bản thực tế phải tự tạo thêm dữ liệu:
  - `POST /api/register` không validate gì, tạo hàng loạt user cho CSV credentials.
  - `POST /api/products` (không cần auth) hoặc `POST /api/admin/import-products` (chỉ cần token bất kỳ) để nhồi sản phẩm.
- Giỏ hàng lưu **in-memory** (`userCarts`, object toàn cục), không dedupe, không xoá sau checkout. Bộ nhớ tăng theo số lần add-to-cart (hữu ích cho soak test).
- Đối chiếu spec và thực tế, ảnh hưởng đến thiết kế assertion/data:
  - Login sai: `login_attempts + 2` mỗi lần, nên **khoá ngay sau lần sai thứ 2**; khoá **180 giây**, không phải 30 giây như spec.
  - User đang bị khoá vẫn nhận **403 kể cả khi nhập đúng mật khẩu**, nên một account bị đánh sai sẽ làm hỏng cả luồng.
  - `GET /api/products/:id` với id không tồn tại vẫn trả **200 + `{}`**, nên phải assert nội dung, không chỉ status code.
  - `POST /api/checkout` tin `total_amount` từ client và **không dùng cart** của server.

## Các endpoint ứng viên

### Auth-heavy

| Endpoint | Vì sao phù hợp | Lưu ý khi test |
|---|---|---|
| `POST /api/login` ⭐ | Mỗi request: 1 `SELECT` + (đúng) 1 `UPDATE` reset attempts + ký JWT; sai thì `UPDATE` tăng attempts. Có ghi DB trên đường đăng nhập, dễ chạm giới hạn SQLite. Có hành vi lockout nên bài yêu cầu xử lý rõ. | Dùng nhiều user trong CSV. Mỗi user chỉ đăng nhập đúng. Nếu cố ý test lockout thì dùng user riêng, nhớ restart backend để reset. |
| `POST /api/register` | Ghi DB, cần email duy nhất (INSERT lỗi 500 nếu trùng). | Dùng `${__UUID}` hoặc CSV sinh sẵn. Dùng làm bước chuẩn bị data hơn là kịch bản chính. |
| `GET /api/users/me` | `SELECT *` theo `id` trong JWT, dùng để kiểm tra token sau login. | Nhẹ, nên đặt như bước phụ sau login. |

### Read-heavy

| Endpoint | Vì sao phù hợp | Lưu ý khi test |
|---|---|---|
| `GET /api/products` ⭐ | `SELECT *` toàn bảng, không phân trang, nên tải tăng theo số row. | Seed chỉ 5 row, nên import thêm (vài trăm đến vài nghìn) cho thực tế. |
| `GET /api/products?search=<kw>` ⭐ | `LIKE '%kw%'` không dùng index (full scan), keyword tham số hoá bằng CSV. | Chuỗi nối trực tiếp vào SQL. Tránh ký tự đặc biệt (`'`) vì sẽ trả 500 dạng HTML, làm nhiễu error rate. |
| `GET /api/products/:id` ⭐ | Truy vấn theo primary key, thao tác đọc đơn giản nhất. | id chẵn trả `price` kiểu string. Assert theo id/name, id lạ trả 200 `{}`. |
| `GET /api/categories` | Đọc bảng rất nhỏ. | Hữu ích làm baseline, ít giá trị phân tích. |

### Transactional

| Endpoint | Vì sao phù hợp | Lưu ý khi test |
|---|---|---|
| `POST /api/cart` ⭐ | Thao tác state in-memory theo user, mỗi lần `push` thêm một phần tử, **không giới hạn**. | Theo dõi memory của process `node` trong soak test. Cần Bearer token từ login. |
| `GET /api/cart` | Đọc lại giỏ, kiểm chứng item đã vào. | Response lớn dần theo số lần add. |
| `POST /api/checkout` ⭐ | `INSERT INTO orders`, đường ghi chính của hệ thống, cần JWT. | Gửi `total_amount` và `shipping_address` từ CSV. Bảng `orders` tăng liên tục, có 62 order trong DB hiện tại nhưng sẽ reseed khi restart. |
| `GET /api/orders/my-orders` | `SELECT ... WHERE user_id=? ORDER BY id DESC`, không index, thời gian tăng theo số order của user. | Dùng để quan sát degradation khi orders tích luỹ trong soak. |
| `POST /api/apply-coupon` | Có DB lookup, nhưng không cần auth và công thức percent trong code sai so với spec. | Ít liên quan perf, bỏ qua nếu không cần. |

⭐ = khuyến nghị.

## Đề xuất workflow end-to-end (dùng chung cho Load/Stress/Spike)

```
POST /api/login            (auth-heavy, credentials từ CSV)
  → GET /api/products?search=<kw>   (read-heavy, keyword từ CSV)
  → GET /api/products/<id>          (read-heavy, id từ CSV)
  → POST /api/cart                  (transactional, product từ CSV)
  → POST /api/checkout              (transactional, payload từ CSV)
```

Một virtual user đi đủ chuỗi trên là phủ cả 3 nhóm.

## Bạn chọn gì để báo team

Vì bài yêu cầu **không trùng workflow giữa các thành viên**, hãy chia theo biến thể của cùng khung 3 nhóm. Gợi ý ba phương án để bạn chọn và báo team:

1. **Phương án A (login + search + cart/checkout):** như workflow ở trên. Trùng với hướng bạn đã làm ở HW02/HW04 (FR-02 login, FR-08 checkout).
2. **Phương án B (login + product detail + cart/checkout):** thay `search` bằng `GET /api/products/:id`, nhẹ hơn, ít ảnh hưởng từ full scan.
3. **Phương án C (register/login + list products + checkout + my-orders):** thay add-to-cart bằng đọc lại order, thể hiện degradation theo thời gian.

Nếu team chia theo endpoint chính, mỗi người nên có ít nhất một endpoint đặc trưng khác nhau trong từng nhóm (ví dụ nhóm read-heavy: người này `search`, người kia `/:id`, người khác `list`).

## Cần tránh

- Các endpoint admin (`/api/admin/*`): thuộc nhóm khác và cần quyền admin.
- `forgot-password`/`reset-password`: OTP 4 chữ số ngẫu nhiên, không phải nhóm đề yêu cầu.
- Pool D (mobile): ngoài phạm vi backend perf test.
