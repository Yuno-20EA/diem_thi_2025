# =============================================================================
# 05_stats.R - LÕI thống kê: hàm thuần (pure functions), không phụ thuộc CFG
# Mọi thứ đi từ một vector điểm x -> bảng tần suất theo "cents" (0.01 điểm)
# Yêu cầu: đã nạp 02_utils.R (hàm to_cents)
# =============================================================================

# Tần suất theo cents: freq[i] = số TS có điểm (i-1)/100
score_freq <- function(x, max_score) {
  xc <- to_cents(x[!is.na(x)])
  tabulate(xc + 1L, nbins = to_cents(max_score) + 1L)
}

describe_scores <- function(x, max_score, fail_cut = NULL) {
  x <- x[!is.na(x)]
  freq <- score_freq(x, max_score)
  top <- max(which(freq > 0))                    # vị trí điểm cao nhất trong freq
  out <- data.table::data.table(
    so_thi_sinh         = length(x),
    diem_tb             = round(mean(x), 2),
    trung_vi            = median(x),
    do_lech_chuan       = round(sd(x), 2),
    diem_thap_nhat      = min(x),
    q1                  = quantile(x, 0.25, names = FALSE),
    q3                  = quantile(x, 0.75, names = FALSE),
    diem_cao_nhat       = max(x),
    diem_pho_bien       = (which.max(freq) - 1) / 100,
    so_ts_diem_cao_nhat = freq[top]
  )
  if (!is.null(fail_cut)) {
    n_fail <- sum(freq[seq_len(to_cents(fail_cut) + 1L)])
    out[, `:=`(so_diem_liet = n_fail,
               ty_le_diem_liet = round(100 * n_fail / length(x), 2))]
  }
  out[]
}

# Số TS có điểm >= từng ngưỡng (dạng dài)
threshold_table <- function(freq, thresholds) {
  n <- sum(freq)
  cum_ge <- rev(cumsum(rev(freq)))            # cum_ge[i] = số TS có cents >= i-1
  cnt <- cum_ge[to_cents(thresholds) + 1L]
  data.table::data.table(nguong = thresholds, so_ts = as.integer(cnt),
                         ty_le = round(100 * cnt / n, 2))
}

# Phổ điểm theo khoảng 1 điểm: [0,1), [1,2), ... và mốc tối đa đứng riêng
band_table <- function(freq, max_score) {
  cents <- seq_along(freq) - 1L
  d <- data.table::data.table(band = pmin(cents %/% 100L, as.integer(max_score)), n = freq)
  d <- d[, list(n = sum(n)), by = band][order(band)]
  d[, band_label := data.table::fifelse(band == max_score, sprintf("= %d", band),
                                        sprintf("[%d, %d)", band, band + 1L))]
  d[, pct := round(100 * n / sum(n), 2)]
  d[]
}

# Số TS đạt CHÍNH XÁC từng mức điểm (chỉ giữ mức có TS)
exact_table <- function(freq) {
  keep <- which(freq > 0)
  data.table::data.table(score = (keep - 1) / 100, n = freq[keep],
                         pct = round(100 * freq[keep] / sum(freq), 3))
}

# Gói tất cả: 1 vector điểm -> 4 bảng
analyse_scores <- function(x, id, label, max_score, thresholds, fail_cut = NULL) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(NULL)
  freq <- score_freq(x, max_score)
  meta <- data.table::data.table(ma = id, ten = label)
  list(
    overview   = cbind(meta, describe_scores(x, max_score, fail_cut)),
    thresholds = cbind(meta, threshold_table(freq, thresholds)),
    bands      = cbind(meta, band_table(freq, max_score)),
    exact      = cbind(meta, exact_table(freq))
  )
}

# Gộp danh sách kết quả của nhiều đối tượng
bind_results <- function(res_list) {
  res_list <- Filter(Negate(is.null), res_list)
  parts <- c("overview", "thresholds", "bands", "exact")
  stats::setNames(lapply(parts, function(p)
    data.table::rbindlist(lapply(res_list, `[[`, p))), parts)
}
