# =============================================================================
# main.R - Điểm vào duy nhất của dự án
# Cách chạy:
#   * Trong RStudio (mở file .Rproj):   source("main.R")
#   * Từ terminal, đứng tại thư mục dự án:   Rscript main.R
#     (thêm --skip-plots nếu không muốn vẽ biểu đồ)
# =============================================================================

suppressPackageStartupMessages(library(data.table))

# Nạp toàn bộ module trong R/ theo thứ tự tên file (01_, 02_, ...)
source(here::here("R", "00_bootstrap.R"))
load_modules()

skip_plots <- "--skip-plots" %in% commandArgs(trailingOnly = TRUE)
options(width = 180)

# 1) Đọc + làm sạch ------------------------------------------------------------
raw <- timed_step("Đọc dữ liệu thô", load_raw())
cl  <- timed_step("Làm sạch dữ liệu", clean_scores(raw))
dt  <- cl$data
rm(raw); invisible(gc())
ensure_dir(CFG$dir_processed)
saveRDS(dt, file.path(CFG$dir_processed, "diem_thi_sach.rds"))

# 2) Thống kê --------------------------------------------------------------------
subj  <- timed_step("Thống kê theo môn",  analyse_subjects(dt))
combo <- timed_step("Thống kê theo khối", analyse_combos(dt))

# 3) Tự kiểm tra ------------------------------------------------------------------
timed_step("Kiểm tra chéo kết quả", run_validation(dt, subj, combo))

# 4) Xuất kết quả -----------------------------------------------------------------
timed_step("Xuất CSV + Excel", export_all(subj, combo, report_to_table(cl$report)))
if (!skip_plots) timed_step("Vẽ biểu đồ", make_all_plots(subj, combo))

# 5) Tóm tắt ra màn hình -----------------------------------------------------------
cat("\n=========== THEO MÔN ===========\n")
print(subj$overview[, list(ten, so_thi_sinh, diem_tb, trung_vi, diem_cao_nhat, so_diem_liet)])
cat("\n=========== THEO KHỐI ===========\n")
print(combo$overview[, list(ten, so_thi_sinh, diem_tb, trung_vi, diem_cao_nhat, so_ts_co_mon_liet)])
cat("\nKết quả nằm trong thư mục output/\n")
