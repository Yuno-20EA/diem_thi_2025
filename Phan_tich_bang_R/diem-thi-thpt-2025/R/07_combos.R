# =============================================================================
# 07_combos.R - Thống kê theo KHỐI (tổng 3 môn)
# Quy tắc: chỉ tính thí sinh có ĐỦ điểm cả 3 môn của khối.
# Một thí sinh có thể xuất hiện ở nhiều khối (vd. cùng đủ A00 và A01).
# =============================================================================

combo_label <- function(id, cols, subjects = SUBJECTS) {
  short <- c(toan = "Toán", van = "Văn", anh = "Anh", ly = "Lý", hoa = "Hóa",
             sinh = "Sinh", su = "Sử", dia = "Địa")
  nm <- ifelse(cols %in% names(short), short[cols], subjects$label[match(cols, subjects$id)])
  sprintf("%s (%s)", id, paste(nm, collapse = ", "))
}

analyse_combos <- function(dt, cfg = CFG, combos = COMBOS) {
  res <- lapply(names(combos), function(id) {
    cols <- combos[[id]]
    m <- dt[, cols, with = FALSE]
    ok <- stats::complete.cases(m)
    sub <- m[ok]
    total <- row_total(sub, cols)
    r <- analyse_scores(total, id, combo_label(id, cols),
                        max_score  = length(cols) * cfg$max_score,
                        thresholds = cfg$thr_combo,
                        fail_cut   = NULL)
    # Bổ sung: số TS có ít nhất 1 môn điểm liệt trong khối
    min_sub <- do.call(pmin, as.list(sub))
    n_liet  <- sum(min_sub <= cfg$fail_cut)
    r$overview[, `:=`(so_ts_co_mon_liet = n_liet)]
    r
  })
  bind_results(res)
}

# Điểm tổng từng thí sinh của một khối (dùng khi cần xuất danh sách/vẽ đồ thị)
combo_scores <- function(dt, cols) {
  m <- dt[, cols, with = FALSE]
  ok <- stats::complete.cases(m)
  data.table::data.table(sbd = dt$sbd[ok], tong = row_total(m[ok], cols))
}
