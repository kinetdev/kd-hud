# KD HUD

Một HUD đơn giản và có thể tùy chỉnh cho ESX Framework, hiển thị thông tin người chơi ở góc trên bên phải màn hình. Được phát triển bởi KinetDev.

## Giới thiệu

KinetDev là một dịch vụ phát triển cao cấp chuyên cung cấp các giải pháp chất lượng cho FiveM, Bot Discord, Thiết Kế UI/UX và Thiết Kế Website. Chúng tôi giúp bạn xây dựng, tối ưu hóa và tự động hóa dự án một cách hiệu quả.

## Tính năng

- Hiển thị tên người chơi, thời gian và ngày tháng ở dòng đầu tiên
- Hiển thị công việc chính và phụ
- Hiển thị tiền mặt, tiền ngân hàng và tiền bẩn với màu sắc khác nhau
- Hiệu ứng động khi giá trị tiền thay đổi
- Bật/tắt HUD bằng phím F10 hoặc lệnh
- Giao diện có thể tùy chỉnh thông qua cấu hình
- Hiển thị logo server
- Hiển thị ID người chơi
- Hiển thị số lượng đạn với cảnh báo khi thấp

## Cài đặt

1. Tải xuống hoặc sao chép repository
2. Đặt thư mục `kd_hud` vào thư mục `resources` của bạn
3. Thêm `ensure kd_hud` vào file `server.cfg`
4. Thêm logo server vào `html/img/logo.png` (kích thước khuyến nghị: 40x40px)
5. Cấu hình các thiết lập trong `config.lua` phù hợp với nhu cầu của server
6. Khởi động lại server

## Cấu hình

Bạn có thể cấu hình HUD trong file `config.lua`:

```lua
Config = {}

-- Thiết lập hiển thị HUD
Config.RefreshTime = 1000 -- Cập nhật HUD mỗi 1 giây
Config.UseRealTime = false -- Sử dụng thời gian thực hoặc thời gian trong game

```

## Lệnh

- `/togglehud` - Bật/tắt hiển thị HUD
- `/checkplayerhud [playerID]` - Lệnh admin để kiểm tra thông tin HUD của người chơi

## Yêu cầu

- ESX Framework
- es_extended

## Tích hợp với Script khác

Bạn có thể tích hợp HUD này với các script khác bằng cách kích hoạt cập nhật client:

```lua
-- Từ phía client
TriggerEvent('kd_hud:updateHUD')

-- Từ phía server đến client
TriggerClientEvent('kd_hud:updateHUD', source)
```

## Tùy chỉnh

### Giao diện

Để tùy chỉnh giao diện của HUD, chỉnh sửa file CSS tại `html/css/style.css`

### Bố cục

Nếu bạn muốn thay đổi bố cục, chỉnh sửa cấu trúc HTML trong `html/index.html`

## Liên hệ & Hỗ trợ

- Discord: [KinetDev Discord](https://discord.com/invite/UgGdpFz2hF)
- Website: [KinetDev](https://kinetdev.com/)
- Tài liệu: [KinetDev Docs](https://kinetdev.gitbook.io/shop)

## Giấy phép

Tài nguyên này được phát hành theo Giấy phép MIT.

## Về KinetDev

KinetDev cung cấp các dịch vụ phát triển chất lượng cao:
- FiveM Scripts: Các script tùy chỉnh cho ESX & QBCore
- Bot Discord: Bot tự động hóa quản lý cộng đồng
- Thiết Kế UI/UX: Giao diện người dùng đẹp mắt
- Thiết Kế Website: Website tùy chỉnh hiện đại

Với cam kết về chất lượng code, tùy chỉnh linh hoạt, hỗ trợ nhanh chóng và giải pháp mở rộng, KinetDev là đối tác đáng tin cậy cho các dự án của bạn. 
