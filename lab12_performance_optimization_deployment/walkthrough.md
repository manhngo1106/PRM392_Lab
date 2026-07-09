# Hướng dẫn kiểm thử và kết quả tối ưu hóa (Lab 12)

Tài liệu này hướng dẫn chi tiết các bước kiểm thử các bài tập từ 12.1 đến 12.4 trực tiếp trên trình duyệt Chrome Web (do môi trường hiện tại được cấu hình tối ưu nhất cho Web).

---

## 🔶 Bài tập 12.1 — Tối ưu hóa Rebuild Danh sách (Optimize List Rebuilds)

### Thay đổi đã thực hiện:
- Tách `ListTile` cũ thành Widget riêng `TaskTile` trong file [task_tile.dart](file:///d:/FPT/PRM392/Lab/lab12_performance_optimization_deployment/lib/widgets/task_tile.dart) có constructor `const`.
- Sử dụng `Selector<TaskProvider, List<Task>>` ở [task_list_screen.dart](file:///d:/FPT/PRM392/Lab/lab12_performance_optimization_deployment/lib/screens/task_list_screen.dart) để bao bọc phần danh sách nhiệm vụ. Nhờ đó, việc nhập text hay click nút Add sẽ không rebuild lại toàn bộ danh sách, và việc toggle trạng thái chỉ rebuild các Widget phụ thuộc chứ không rebuild toàn bộ màn hình.
- Khai báo các widget tĩnh bằng từ khóa `const`.
- Gán `ValueKey(task.id)` cho mỗi `TaskTile`.

### Các bước kiểm thử cho bạn:
1. Mở trình duyệt Chrome tại địa chỉ: `http://localhost:8080/` (đã được host sẵn bởi server chạy ngầm).
2. Kiểm tra giao diện trống ban đầu với thông báo: "No tasks yet. Add one!".
3. Nhập một nhiệm vụ mới (ví dụ: `Học tối ưu hóa Flutter`) vào khung nhập văn bản ở dưới cùng.
4. Bấm **Add**. Hãy quan sát thấy nhiệm vụ lập tức được thêm vào danh sách và số lượng đếm ở góc trên bên phải thay đổi thành `0/1 Done`.
5. Bấm vào hình tròn checkmark của nhiệm vụ để toggle hoàn thành. Nhiệm vụ sẽ chuyển sang trạng thái gạch ngang chữ và số lượng đếm đổi thành `1/1 Done`.
6. Bấm nút Thùng rác (Delete) để xóa nhiệm vụ, danh sách sẽ trở về trạng thái trống ban đầu một cách mượt mà.

---

## 🔶 Bài tập 12.2 — Tối ưu hóa Hình ảnh & Tài nguyên (Image & Asset Optimization)

### Thay đổi đã thực hiện:
- Tạo một logo chất lượng cao `assets/app_logo.png` bằng AI.
- Sử dụng công cụ nén ảnh và thay đổi kích thước xuống đúng độ phân giải di động chuẩn **128×128** (kích thước file giảm từ ~1.5MB xuống chỉ còn **12.13 KB**).
- Tích hợp hàm `precacheImage()` vào hàm `didChangeDependencies` của `TaskListScreen` giúp hình ảnh được tải trước vào bộ nhớ đệm (RAM) ngay khi khởi chạy ứng dụng, tránh hiện tượng nhấp nháy hoặc trễ hình.
- Đưa hình ảnh logo vào thanh tiêu đề (Header) của ứng dụng bên cạnh chữ "Taskly".

### Các bước kiểm thử cho bạn:
1. Khi truy cập trang web `http://localhost:8080/`, bạn sẽ thấy logo Taskly dạng checkmark màu Gradient Indigo-Violet xuất hiện lập tức trên Header mà không bị trễ hình.
2. Kiểm tra file `pubspec.yaml` để xác nhận đường dẫn asset `assets/app_logo.png` đã được khai báo chính xác.

---

## 🔶 Bài tập 12.3 — Phân tích kích thước ứng dụng (App Size Analysis)

### Kết quả phân tích (cho Web Build):
Kích thước thư mục build được phân tích chi tiết bằng script PowerShell, với top các file chiếm dung lượng nhiều nhất gồm:

| Thứ tự | Tên File | Đường dẫn | Dung lượng (Bytes) | Dung lượng (KB) | Vai trò |
|---|---|---|---|---|---|
| 1 | `canvaskit.wasm` | `canvaskit/canvaskit.wasm` | 7,229,467 | 7,060.03 KB | Trình dựng đồ họa chính cho Web |
| 2 | `canvaskit.wasm` | `canvaskit/chromium/canvaskit.wasm` | 5,760,502 | 5,625.49 KB | File tối ưu riêng cho trình duyệt Chromium |
| 3 | `skwasm_heavy.wasm` | `canvaskit/skwasm_heavy.wasm` | 5,172,643 | 5,051.41 KB | Đồ họa tối ưu nâng cao |
| 4 | `main.dart.js` | `main.dart.js` | 2,453,055 | 2,395.56 KB | Mã nguồn logic ứng dụng đã biên dịch |
| 5 | `NOTICES` | `assets/NOTICES` | 1,320,485 | 1,289.54 KB | Thông tin bản quyền phần mềm nguồn mở |
| 6 | `app_logo.png` | `assets/app_logo.png` | 12,133 | **12.13 KB** | Ảnh logo đã tối ưu |

### Đề xuất tối ưu hóa thêm:
- **Gỡ bỏ giấy phép không cần thiết**: Nén hoặc loại bỏ file `assets/NOTICES` (tiết kiệm ~1.3 MB).
- **Sử dụng HTML Renderer**: Chạy lệnh build với flag `--web-renderer html` để không tải CanvasKit WASM nếu muốn ưu tiên tốc độ tải trang đầu tiên hơn là độ mượt vẽ đồ họa pixel.

---

## 🔶 Bài tập 12.4 — Tối ưu hóa cuối cùng & Triển khai (Final Optimization & Deployment)

### Các công việc đã thực hiện:
- Loại bỏ hoàn toàn các log debug dư thừa.
- Thực hiện Tree-shaking cho font biểu tượng (giúp `CupertinoIcons` giảm 99.4% dung lượng và `MaterialIcons` giảm 99.5% dung lượng).
- Biên dịch ứng dụng sang cấu hình Release Web tối ưu hóa cao thông qua lệnh:
  `flutter build web --release`
- Khởi tạo Web Server nội bộ bằng Python để phục vụ mã nguồn tối ưu tại cổng `8080`.

### Các bước kiểm thử cho bạn:
1. Mở ứng dụng tại `http://localhost:8080/`.
2. Kiểm tra hiệu năng phản hồi khi thêm/xóa tác vụ nhanh liên tục: ứng dụng chạy mượt mà, phản hồi lập tức và ổn định ở mức 60 FPS.
