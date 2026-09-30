# =============================================================================
# setup.R - Chạy MỘT LẦN để chuẩn bị môi trường làm việc
# Cách dùng (trong RStudio, đã mở file .Rproj):  source("setup.R")
# =============================================================================

cat("== Kiểm tra phiên bản R ==\n")
if (getRversion() < "4.1.0") {
  stop("Cần R >= 4.1.0. Bản hiện tại: ", getRversion(),
       ". Hãy tải bản mới tại https://cran.r-project.org")
}
cat("R", as.character(getRversion()), "- OK\n\n")

# Các gói dự án sử dụng (giải thích vai trò trong README.md)
pkgs <- c("data.table",  # đọc/xử lý bảng lớn cực nhanh (1,1 triệu dòng)
          "writexl",     # xuất Excel nhiều sheet, không cần Java
          "ggplot2",     # vẽ phổ điểm
          "ragg",        # xuất PNG đẹp, hỗ trợ tiếng Việt có dấu
          "here",        # đường dẫn tương đối theo thư mục dự án
          "testthat")    # kiểm thử tự động

use_renv <- file.exists("renv/activate.R")   # renv đã được khởi tạo chưa?

missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing) > 0) {
  cat("== Cài các gói còn thiếu:", paste(missing, collapse = ", "), "==\n")
  if (use_renv) renv::install(missing) else install.packages(missing)
} else {
  cat("== Tất cả gói đã có sẵn ==\n")
}

if (use_renv) {
  renv::snapshot(prompt = FALSE)   # ghi lại phiên bản vào renv.lock
  cat("renv.lock đã được cập nhật.\n")
} else {
  cat("\n(Gợi ý) Chưa dùng renv. Để khoá phiên bản gói, chạy MỘT LẦN trong Console:\n",
      "  install.packages('renv'); renv::init()\n",
      "  source('setup.R')   # chạy lại để snapshot\n", sep = "")
}

cat("\n== Kiểm tra dữ liệu đầu vào ==\n")
csvs <- list.files("data/raw", pattern = "\\.csv$")
if (length(csvs) == 0) {
  cat("CHƯA có file CSV. Hãy chép 2 file điểm thi vào thư mục data/raw/\n")
} else {
  cat("Tìm thấy:", paste(csvs, collapse = ", "), "\n")
}
cat("\nXong. Bước tiếp theo: source('main.R')\n")
