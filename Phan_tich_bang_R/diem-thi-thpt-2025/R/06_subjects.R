# =============================================================================
# 06_subjects.R - Thống kê từng MÔN
# =============================================================================

analyse_subjects <- function(dt, cfg = CFG, subjects = SUBJECTS) {
  res <- lapply(seq_len(nrow(subjects)), function(i) {
    id <- subjects$id[i]
    if (!id %in% names(dt)) return(NULL)
    analyse_scores(dt[[id]], id, subjects$label[i],
                   max_score  = cfg$max_score,
                   thresholds = cfg$thr_subject,
                   fail_cut   = cfg$fail_cut)
  })
  bind_results(res)
}
