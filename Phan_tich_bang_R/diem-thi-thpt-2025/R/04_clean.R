# =============================================================================
# 04_clean.R - Làm sạch: SBD, trùng lặp, điểm không hợp lệ, tách ngoại ngữ
# =============================================================================

pad_sbd <- function(x, width) {
  paste0(strrep("0", pmax(width - nchar(x), 0L)), x)
}

clean_scores <- function(raw, cfg = CFG) {
  dt <- data.table::copy(raw)
  rp <- list(so_dong_goc = nrow(dt))

  # 1) Chuẩn hoá số báo danh (khôi phục số 0 đầu bị mất)
  rp$sbd_thieu_so_0 <- sum(nchar(dt$sbd) < cfg$sbd_width, na.rm = TRUE)
  dt[, sbd := pad_sbd(sbd, cfg$sbd_width)]

  # 2) Loại trùng SBD (giữ dòng đầu)
  dup <- duplicated(dt$sbd)
  rp$sbd_trung <- sum(dup)
  dt <- dt[!dup]

  # 3) Ép kiểu số + làm tròn 2 chữ số + loại điểm ngoài [0, 10]
  rp$diem_ngoai_khoang <- 0L
  for (col in intersect(RAW_SCORE_COLS, names(dt))) {
    v <- round(as.numeric(dt[[col]]), 2)
    bad <- which(!is.na(v) & (v < 0 | v > cfg$max_score))
    rp$diem_ngoai_khoang <- rp$diem_ngoai_khoang + length(bad)
    if (length(bad)) v[bad] <- NA_real_
    data.table::set(dt, j = col, value = v)
  }

  # 4) Tách cột "nn" thành từng môn ngoại ngữ theo "Ma NN"
  dt[, ma_nn := toupper(trimws(ma_nn))]
  rp$nn_khong_ma <- sum(!is.na(dt$nn) & is.na(dt$ma_nn))
  rp$nn_ma_la    <- sum(!is.na(dt$nn) & !is.na(dt$ma_nn) & !(dt$ma_nn %in% names(LANG_CODES)))
  for (code in names(LANG_CODES)) {
    col <- LANG_CODES[[code]]
    data.table::set(dt, j = col,
                    value = data.table::fifelse(!is.na(dt$ma_nn) & dt$ma_nn == code,
                                                dt$nn, NA_real_))
  }

  rp$so_thi_sinh_sau_lam_sach <- nrow(dt)
  list(data = dt[], report = rp)
}

# Đổi báo cáo (list) -> bảng 2 cột để ghi ra Excel/CSV
report_to_table <- function(rp) {
  labels <- c(
    so_dong_goc = "Số dòng đọc được từ các file gốc",
    sbd_thieu_so_0 = "SBD bị mất số 0 đầu (đã khôi phục)",
    sbd_trung = "SBD trùng (đã loại)",
    diem_ngoai_khoang = "Ô điểm ngoài [0;10] (đã đặt NA)",
    nn_khong_ma = "Có điểm NN nhưng thiếu mã NN",
    nn_ma_la = "Có điểm NN nhưng mã NN không nhận diện",
    so_thi_sinh_sau_lam_sach = "Số thí sinh sau làm sạch"
  )
  data.table::data.table(hang_muc = unname(labels[names(rp)]),
                         gia_tri  = as.integer(unlist(rp)))
}
