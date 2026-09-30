# Phân tích điểm thi tốt nghiệp THPT 2025 bằng R

Xử lý 2 file điểm thi (~1,13 triệu thí sinh) giống bảng phổ điểm của báo chí:
thống kê **từng môn** rồi **tổng hợp theo khối** A00, A01, B00, C00, D01.
Chạy đầy đủ chỉ mất ~25 giây.

## 1. Cấu trúc thư mục

```
diem-thi-thpt-2025/
├── diem-thi-thpt-2025.Rproj   <- MỞ file này bằng RStudio (đặt thư mục làm việc tự động)
├── setup.R                    <- chạy 1 lần: kiểm tra R, cài gói, khoá phiên bản
├── main.R                     <- điểm vào duy nhất: chạy toàn bộ pipeline
├── R/
│   ├── 00_bootstrap.R         nạp module an toàn với mọi locale/UTF-8
│   ├── 01_config.R            CẤU HÌNH: môn, khối, mốc điểm, tên cột (sửa ở đây)
│   ├── 02_utils.R             hàm tiện ích (log, to_cents, row_total)
│   ├── 03_load.R              đọc CSV, chuẩn hoá tên cột
│   ├── 04_clean.R             làm sạch (SBD, trùng, điểm sai, tách ngoại ngữ)
│   ├── 05_stats.R             LÕI thống kê (hàm thuần, có test)
│   ├── 06_subjects.R          thống kê theo môn
│   ├── 07_combos.R            thống kê theo khối (tổng 3 môn)
│   ├── 08_export.R            xuất CSV + Excel
│   ├── 09_plots.R             vẽ phổ điểm
│   └── 10_validate.R          tự kiểm tra chéo kết quả
├── tests/                     kiểm thử tự động (testthat)
├── data/raw/                  <- CHÉP 2 FILE CSV VÀO ĐÂY
├── data/processed/            dữ liệu đã làm sạch (.rds, tự sinh)
└── output/
    ├── tables/                CSV + ket_qua_thi_thpt_2025.xlsx
    └── plots/                 PNG phổ điểm từng môn/khối
```

## 2. Cài đặt môi trường (làm từ đầu)

**Bước 1 – Cài R (>= 4.1, khuyên dùng bản mới nhất)**
- Windows: https://cran.r-project.org/bin/windows/base/
- macOS: https://cran.r-project.org/bin/macosx/
- Ubuntu: `sudo apt install r-base` (hoặc thêm kho CRAN để có bản mới)

**Bước 2 – Cài RStudio Desktop** (miễn phí): https://posit.co/download/rstudio-desktop/

**Bước 3 – Cấu hình mã hoá UTF-8 (quan trọng với tiếng Việt)**
RStudio → Tools → Global Options → Code → Saving → *Default text encoding* = **UTF-8**.
Cũng ở Global Options → General: bỏ chọn *Restore .RData into workspace at startup*
và đặt *Save workspace to .RData on exit* = **Never** (giữ môi trường sạch, kết quả tái lập được).

**Bước 4 – Mở dự án**: nhấp đúp `diem-thi-thpt-2025.Rproj`.
Console sẽ ở đúng thư mục dự án. Từ đây mọi đường dẫn đều tính từ gốc dự án (nhờ gói `here`).

**Bước 5 – Chép dữ liệu**: đặt `2025-ketquathi-ct2018a-1.csv` và `...-2.csv` vào `data/raw/`.
(Chương trình tự đọc *mọi* file `.csv` trong thư mục này.)

**Bước 6 – Cài gói và khoá phiên bản bằng `renv`** (làm 1 lần, trong Console):
```r
install.packages("renv")
renv::init()          # tạo thư viện gói riêng cho dự án; R sẽ tự khởi động lại
source("setup.R")     # cài gói còn thiếu + ghi renv.lock
```
`renv` giống `venv` + `requirements.txt` của Python: mỗi dự án có bộ gói riêng, `renv.lock`
ghi chính xác phiên bản. Người khác chỉ cần `renv::restore()` là có môi trường y hệt.
Nếu chưa muốn dùng renv, chỉ cần `source("setup.R")` (cài gói vào thư viện chung).

**Bước 7 – Chạy**
```r
source("main.R")                       # trong RStudio
```
hoặc từ terminal (đứng ở thư mục dự án): `Rscript main.R` (thêm `--skip-plots` để bỏ vẽ hình).

**Bước 8 – (tuỳ chọn) Chạy kiểm thử**: `source("tests/run_tests.R")`

### Các gói sử dụng
| Gói | Vai trò |
|---|---|
| `data.table` | Đọc/xử lý bảng lớn rất nhanh, ít RAM |
| `writexl` | Ghi Excel nhiều sheet, không cần Java |
| `ggplot2` + `ragg` | Vẽ phổ điểm; `ragg` hiển thị tiếng Việt chuẩn |
| `here` | Đường dẫn theo gốc dự án, chạy được trên mọi máy |
| `testthat` | Kiểm thử tự động |
| `renv` | Khoá phiên bản gói (tái lập kết quả) |

## 3. Kết quả tạo ra

**Theo từng môn (18 môn, gồm 7 ngoại ngữ) và từng khối**, mỗi đối tượng đều có:

| File CSV (dạng dài) | Nội dung |
|---|---|
| `*_tong_quan.csv` | Số thí sinh, điểm TB, trung vị, độ lệch chuẩn, thấp/cao nhất, Q1, Q3, điểm phổ biến nhất, số TS đạt điểm cao nhất, số điểm liệt (≤ 1) |
| `*_nguong_diem.csv` | Số TS và tỷ lệ % từ mốc X trở lên (môn: ≥5,6,7,8,9,9.5,10; khối: ≥15,18,20…30) |
| `*_pho_diem_theo_khoang.csv` | Số TS theo khoảng 1 điểm: [0,1), [1,2)… và mốc tối đa |
| `*_pho_diem_chi_tiet.csv` | Số TS đạt **chính xác** từng mức điểm (bước 0,05) |

Cùng nội dung được gộp vào `ket_qua_thi_thpt_2025.xlsx` (9 sheet, dạng bảng rộng như báo chí):
`Mon_TongQuan, Mon_Nguong, Mon_PhoDiem, Mon_ChiTiet, Khoi_TongQuan, Khoi_Nguong, Khoi_PhoDiem, Khoi_ChiTiet, ChatLuongDuLieu`.

CSV có BOM UTF-8 nên mở thẳng bằng Excel vẫn đúng tiếng Việt.

## 4. Quy ước tính toán (đọc kỹ trước khi trích số liệu)

1. **Khối = tổng 3 môn**, chỉ tính thí sinh **có đủ điểm cả 3 môn**. Một thí sinh có thể nằm ở nhiều khối.
2. **Tiếng Anh** = cột `NN` với `Ma NN = N1`. D01 và A01 chỉ tính thí sinh thi tiếng Anh.
   Các mã khác: N2 Nga, N3 Pháp, N4 Trung, N5 Đức, N6 Nhật, N7 Hàn.
3. **Điểm liệt** = điểm ≤ 1,0. Với khối, cột "Số TS có môn điểm liệt" đếm thí sinh có ít nhất 1 môn ≤ 1,0.
4. **Trung vị** tính trên dữ liệu gốc; **điểm TB** làm tròn 2 chữ số.
5. Ở khối, điểm không cộng ưu tiên (dữ liệu gốc không có).

## 5. Những "bẫy dữ liệu" đã xử lý (xem sheet `ChatLuongDuLieu`)

- File 1 mất số 0 đầu của SBD (`1000001` thay vì `01000001`) → đọc dạng chữ và bù lại đủ 8 chữ số.
- Tên cột lệch giữa 2 file (`Tinhoc` vs `TinHoc`) → chuẩn hoá tên trước khi gộp.
- Cột `STT` của file 2 nối tiếp file 1 → bỏ vì chỉ là số thứ tự dòng.
- Số thực dấu phẩy động (`0.1 + 0.2 != 0.3`) → mọi so sánh mốc điểm được làm trên **số nguyên** (`to_cents`).
- Điểm ngoài [0;10], SBD trùng, NN thiếu mã → kiểm tra và báo cáo.

## 6. Tuỳ biến (chỉ sửa `R/01_config.R`)

- Thêm khối: thêm 1 dòng vào `COMBOS`, ví dụ `A02 = c("toan", "ly", "sinh")`.
- Đổi mốc điểm: sửa `CFG$thr_subject` / `CFG$thr_combo`.
- Đổi ngưỡng điểm liệt: `CFG$fail_cut`.

## 7. Xử lý sự cố

| Triệu chứng | Cách xử lý |
|---|---|
| `there is no package called ...` | Chạy lại `source("setup.R")` |
| Tiếng Việt lỗi trong console (Windows) | Kiểm tra Bước 3; cập nhật R ≥ 4.2 (mặc định UTF-8) |
| `Không có file .csv nào trong ...` | Chưa chép CSV vào `data/raw/` |
| `Cột lạ trong ...` | File có cột mới → thêm vào `RAW_COL_MAP` |
| `KIỂM TRA THẤT BẠI` | Kết quả không khớp cách tính độc lập → đọc thông báo, chưa dùng số liệu |
| Không tìm thấy đường dẫn khi chạy `Rscript` | Hãy `cd` vào thư mục dự án trước khi chạy |
