# =============================================================================
# 09_plots.R - Vẽ phổ điểm (ggplot2 + ragg để hiển thị tiếng Việt chuẩn)
# =============================================================================

fmt_int <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE)

plot_one <- function(exact, ov, year, bar_width = 0.045, fill = "#2E75B6") {
  sub <- sprintf("Số thí sinh: %s  |  Điểm TB: %.2f  |  Trung vị: %s",
                 fmt_int(ov$so_thi_sinh), ov$diem_tb, format(ov$trung_vi))
  ggplot2::ggplot(exact, ggplot2::aes(x = score, y = n)) +
    ggplot2::geom_col(width = bar_width, fill = fill, position = "identity") +
    ggplot2::geom_vline(xintercept = ov$diem_tb, colour = "#C00000", linetype = "dashed") +
    ggplot2::geom_vline(xintercept = ov$trung_vi, colour = "#00A050", linetype = "dotted") +
    ggplot2::scale_y_continuous(labels = fmt_int) +
    ggplot2::labs(title = sprintf("Phổ điểm %s - Kỳ thi tốt nghiệp THPT %d", ov$ten, year),
                  subtitle = paste0(sub, "\n(đỏ nét đứt: trung bình; xanh nét chấm: trung vị)"),
                  x = "Điểm", y = "Số thí sinh") +
    ggplot2::theme_minimal(base_size = 12)
}

save_plot <- function(p, path, w = 9, h = 5) {
  ggplot2::ggsave(path, p, width = w, height = h, dpi = 150, device = ragg::agg_png)
}

make_all_plots <- function(subj, combo, cfg = CFG, min_n = 200) {
  ensure_dir(cfg$dir_plots)
  draw <- function(res, prefix, width, fill) {
    for (id in unique(res$overview$ma)) {
      ov <- res$overview[ma == id]
      if (ov$so_thi_sinh < min_n) next        # bỏ môn quá ít thí sinh
      p <- plot_one(res$exact[ma == id], ov, cfg$year, width, fill)
      save_plot(p, file.path(cfg$dir_plots, sprintf("%s_%s.png", prefix, id)))
    }
  }
  draw(subj,  "mon",  0.045, "#2E75B6")
  draw(combo, "khoi", 0.045, "#ED7D31")

  # Bảng so sánh phổ điểm 5 khối trong 1 hình
  ex <- data.table::copy(combo$exact)
  ex[, ma := factor(ma, levels = unique(ma))]
  p <- ggplot2::ggplot(ex, ggplot2::aes(score, n)) +
    ggplot2::geom_col(width = 0.045, fill = "#ED7D31", position = "identity") +
    ggplot2::facet_wrap(~ ma, scales = "free_y", ncol = 2) +
    ggplot2::scale_y_continuous(labels = fmt_int) +
    ggplot2::labs(title = sprintf("Phổ điểm các khối truyền thống - THPT %d", cfg$year),
                  x = "Tổng điểm 3 môn", y = "Số thí sinh") +
    ggplot2::theme_minimal(base_size = 11)
  save_plot(p, file.path(cfg$dir_plots, "so_sanh_cac_khoi.png"), w = 11, h = 9)
  log_info("Đã lưu biểu đồ vào: ", cfg$dir_plots)
}
