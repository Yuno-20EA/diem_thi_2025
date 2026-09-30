# =============================================================================
# 01_config.R - MỌI thứ có thể chỉnh sửa nằm ở đây (đường dẫn, môn, khối, mốc điểm)
# =============================================================================

CFG <- list(
  year          = 2025,
  dir_raw       = here::here("data", "raw"),
  dir_processed = here::here("data", "processed"),
  dir_tables    = here::here("output", "tables"),
  dir_plots     = here::here("output", "plots"),

  sbd_width = 8L,   # số báo danh chuẩn 8 chữ số (file 1 bị mất số 0 đầu)
  max_score = 10,   # thang điểm mỗi môn
  fail_cut  = 1,    # điểm liệt: <= 1.0

  # Các mốc "từ ... trở lên" (>=) hiển thị trong bảng ngưỡng
  thr_subject = c(5, 6, 7, 8, 9, 9.5, 10),
  thr_combo   = c(15, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30)
)

# --- Danh sách môn (id nội bộ -> tên hiển thị) -------------------------------
SUBJECTS <- data.table::data.table(
  id    = c("toan", "van", "anh", "ly", "hoa", "sinh", "su", "dia", "gdktpl",
            "tin", "cn_cn", "cn_nn", "nga", "phap", "trung", "duc", "nhat", "han"),
  label = c("Toán", "Ngữ văn", "Tiếng Anh", "Vật lí", "Hóa học", "Sinh học",
            "Lịch sử", "Địa lí", "GD Kinh tế & Pháp luật", "Tin học",
            "Công nghệ công nghiệp", "Công nghệ nông nghiệp",
            "Tiếng Nga", "Tiếng Pháp", "Tiếng Trung", "Tiếng Đức",
            "Tiếng Nhật", "Tiếng Hàn")
)

# --- Mã ngoại ngữ trong cột "Ma NN" -> id môn ---------------------------------
LANG_CODES <- c(N1 = "anh", N2 = "nga", N3 = "phap", N4 = "trung",
                N5 = "duc", N6 = "nhat", N7 = "han")

# --- Các khối cần thống kê (thêm khối mới chỉ cần thêm 1 dòng) ---------------
COMBOS <- list(
  A00 = c("toan", "ly", "hoa"),
  A01 = c("toan", "ly", "anh"),
  B00 = c("toan", "hoa", "sinh"),
  C00 = c("van", "su", "dia"),
  D01 = c("toan", "van", "anh")
  # D02 = c("toan", "van", "nga"),   # ví dụ mở rộng
  # A02 = c("toan", "ly", "sinh"),
)

# --- Ánh xạ tên cột file gốc (đã chuẩn hoá: chữ thường, bỏ khoảng trắng) ----
RAW_COL_MAP <- c(
  stt = "stt", sobaodanh = "sbd", toan = "toan", van = "van", ly = "ly",
  hoa = "hoa", sinh = "sinh", tinhoc = "tin",
  cncongnghiep = "cn_cn", cnnongnghiep = "cn_nn",
  su = "su", dia = "dia", gdktpl = "gdktpl", nn = "nn", mann = "ma_nn"
)
RAW_SCORE_COLS <- c("toan", "van", "ly", "hoa", "sinh", "tin", "cn_cn", "cn_nn",
                    "su", "dia", "gdktpl", "nn")

# --- Tiêu đề cột tiếng Việt khi xuất file --------------------------------------
VN_HEADERS <- c(
  ma = "Mã", ten = "Môn / Khối", so_thi_sinh = "Số thí sinh",
  diem_tb = "Điểm trung bình", trung_vi = "Trung vị",
  do_lech_chuan = "Độ lệch chuẩn", diem_thap_nhat = "Điểm thấp nhất",
  q1 = "Tứ phân vị Q1", q3 = "Tứ phân vị Q3", diem_cao_nhat = "Điểm cao nhất",
  diem_pho_bien = "Điểm phổ biến nhất", so_ts_diem_cao_nhat = "Số TS đạt điểm cao nhất",
  so_diem_liet = "Số bài điểm liệt (<= 1)", ty_le_diem_liet = "Tỷ lệ điểm liệt (%)",
  so_ts_co_mon_liet = "Số TS có môn điểm liệt",
  band_label = "Khoảng điểm", score = "Điểm", n = "Số thí sinh", pct = "Tỷ lệ (%)",
  hang_muc = "Hạng mục", gia_tri = "Giá trị",
  nguong = "Ngưỡng (từ ... trở lên)", so_ts = "Số thí sinh", ty_le = "Tỷ lệ (%)",
  band = "Khoảng (điểm nguyên)"
)
