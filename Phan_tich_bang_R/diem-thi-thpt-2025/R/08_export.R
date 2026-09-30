# =============================================================================
# 08_export.R - Xuất CSV (UTF-8 có BOM để Excel đọc đúng tiếng Việt) + Excel (writexl)
# =============================================================================

# Đổi tên cột nội bộ -> tiêu đề tiếng Việt
vn_names <- function(dt) {
  out <- data.table::copy(dt)
  nm <- names(out)
  hit <- nm %in% names(VN_HEADERS)
  nm[hit] <- unname(VN_HEADERS[nm[hit]])
  nm <- sub("^so_ts_([0-9.]+)$", "Số TS ≥ \\1", nm)
  nm <- sub("^ty_le_([0-9.]+)$", "Tỷ lệ ≥ \\1 (%)", nm)
  data.table::setnames(out, nm)
  out[]
}

# Bảng ngưỡng dạng rộng: mỗi ngưỡng 1 cột số lượng + 1 cột tỷ lệ
wide_thresholds <- function(long) {
  d <- data.table::copy(long)
  d[, ma := factor(ma, levels = unique(ma))]
  w <- data.table::dcast(d, ma + ten ~ nguong, value.var = c("so_ts", "ty_le"))
  w[, ma := as.character(ma)]
  w[]
}

# Phổ điểm dạng rộng: mỗi khoảng điểm 1 cột
wide_bands <- function(long) {
  d <- data.table::copy(long)
  d[, ma := factor(ma, levels = unique(ma))]
  lab <- unique(d[order(band), list(band, band_label)])
  w <- data.table::dcast(d, ma + ten ~ band, value.var = "n")
  data.table::setnames(w, as.character(lab$band), lab$band_label, skip_absent = TRUE)
  w[, ma := as.character(ma)]
  w[]
}

export_all <- function(subj, combo, report_tbl, cfg = CFG) {
  ensure_dir(cfg$dir_tables)
  csv <- function(dt, name)
    data.table::fwrite(vn_names(dt), file.path(cfg$dir_tables, name), bom = TRUE)

  # --- CSV (dạng dài, dễ dùng lại cho R/Python/Power BI) ---
  csv(subj$overview,   "mon_tong_quan.csv")
  csv(subj$thresholds, "mon_nguong_diem.csv")
  csv(subj$bands,      "mon_pho_diem_theo_khoang.csv")
  csv(subj$exact,      "mon_pho_diem_chi_tiet.csv")
  csv(combo$overview,   "khoi_tong_quan.csv")
  csv(combo$thresholds, "khoi_nguong_diem.csv")
  csv(combo$bands,      "khoi_pho_diem_theo_khoang.csv")
  csv(combo$exact,      "khoi_pho_diem_chi_tiet.csv")
  csv(report_tbl,       "chat_luong_du_lieu.csv")

  # --- Excel (1 file, nhiều sheet, dạng rộng giống bảng báo chí) ---
  sheets <- list(
    Mon_TongQuan     = subj$overview,
    Mon_Nguong       = wide_thresholds(subj$thresholds),
    Mon_PhoDiem      = wide_bands(subj$bands),
    Mon_ChiTiet      = subj$exact,
    Khoi_TongQuan    = combo$overview,
    Khoi_Nguong      = wide_thresholds(combo$thresholds),
    Khoi_PhoDiem     = wide_bands(combo$bands),
    Khoi_ChiTiet     = combo$exact,
    ChatLuongDuLieu  = report_tbl
  )
  sheets <- lapply(sheets, function(d) as.data.frame(vn_names(d)))
  xlsx_path <- file.path(cfg$dir_tables, sprintf("ket_qua_thi_thpt_%d.xlsx", cfg$year))
  writexl::write_xlsx(sheets, xlsx_path, format_headers = TRUE)
  log_info("Đã xuất: ", xlsx_path)
  invisible(xlsx_path)
}
