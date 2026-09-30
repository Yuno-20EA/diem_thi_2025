# =============================================================================
# 10_validate.R - Tự kiểm tra: kết quả phải khớp với cách tính độc lập
# Nếu có sai lệch, pipeline DỪNG với thông báo rõ ràng (fail fast).
# =============================================================================

check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("KIỂM TRA THẤT BẠI: ", msg, call. = FALSE)
  invisible(TRUE)
}

run_validation <- function(dt, subj, combo, cfg = CFG, combos = COMBOS) {
  n_ck <- 0L
  ok <- function(cond, msg) { check(cond, msg); n_ck <<- n_ck + 1L }

  # --- Từng môn ---
  for (id in unique(subj$overview$ma)) {
    ov <- subj$overview[ma == id]
    x  <- dt[[id]]; x <- x[!is.na(x)]
    ok(ov$so_thi_sinh == length(x),               paste(id, ": số TS khớp dữ liệu"))
    ok(subj$bands[ma == id, sum(n)] == length(x), paste(id, ": tổng các khoảng điểm = số TS"))
    ok(subj$exact[ma == id, sum(n)] == length(x), paste(id, ": tổng phổ điểm chi tiết = số TS"))
    ok(abs(ov$diem_tb - round(mean(x), 2)) < 1e-9, paste(id, ": điểm TB khớp"))
    ok(abs(ov$trung_vi - median(x)) < 1e-9,        paste(id, ": trung vị khớp"))
    thr <- subj$thresholds[ma == id]
    ok(!is.unsorted(rev(thr$so_ts)),               paste(id, ": ngưỡng cao hơn thì số TS không tăng"))
    ok(thr[nguong == 5, so_ts] == sum(x >= 5 - 1e-9), paste(id, ": số TS >= 5 khớp"))
  }

  # --- Từng khối ---
  for (id in names(combos)) {
    cols <- combos[[id]]
    ov <- combo$overview[ma == id]
    ok(ov$so_thi_sinh <= min(vapply(cols, function(cn) sum(!is.na(dt[[cn]])), numeric(1))),
       paste(id, ": số TS khối <= số TS môn ít nhất"))
    tot <- combo_scores(dt, cols)$tong
    ok(ov$so_thi_sinh == length(tot),                paste(id, ": số TS khối khớp"))
    ok(abs(ov$diem_tb - round(mean(tot), 2)) < 1e-9, paste(id, ": điểm TB khối khớp"))
    ok(abs(ov$trung_vi - median(tot)) < 1e-9,        paste(id, ": trung vị khối khớp"))
    ok(ov$diem_cao_nhat <= length(cols) * cfg$max_score, paste(id, ": điểm tối đa hợp lệ"))
    ok(combo$bands[ma == id, sum(n)] == length(tot), paste(id, ": tổng phổ điểm khối = số TS"))
  }
  log_info("   ", n_ck, " phép kiểm tra đều đạt")
  invisible(TRUE)
}
