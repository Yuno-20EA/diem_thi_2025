# =============================================================================
# 02_utils.R - Hàm tiện ích dùng chung
# =============================================================================

log_info <- function(...) {
  cat(format(Sys.time(), "[%H:%M:%S] "), ..., "\n", sep = "")
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

# Đổi điểm sang SỐ NGUYÊN "phần trăm điểm" (6.35 -> 635).
# Lý do: so sánh số thực (0.1 + 0.2 == 0.3 là FALSE!) dễ sai ở các mốc điểm.
# Số nguyên thì so sánh tuyệt đối chính xác.
to_cents <- function(x) as.integer(round(x * 100))

# Tính tổng nhiều cột điểm và làm tròn 2 chữ số để triệt tiêu sai số dấu phẩy động
row_total <- function(dt, cols) {
  round(Reduce(`+`, lapply(cols, function(cn) dt[[cn]])), 2)
}

timed_step <- function(name, expr) {
  log_info(">> ", name)
  t0 <- Sys.time()
  res <- force(expr)
  log_info("   xong (", round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1), "s)")
  invisible(res)
}
