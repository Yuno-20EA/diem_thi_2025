# Chạy: source("tests/run_tests.R")
source(here::here("R", "00_bootstrap.R"))
source_utf8(here::here("R", "02_utils.R"))
source_utf8(here::here("R", "05_stats.R"))
library(data.table)

test_that("to_cents tránh lỗi dấu phẩy động", {
  expect_false(0.1 + 0.2 == 0.3)                 # cái bẫy kinh điển
  expect_equal(to_cents(0.1 + 0.2), to_cents(0.3))
  expect_equal(to_cents(6.35), 635L)
})

test_that("row_total cộng đúng và không lệch mốc", {
  d <- data.table(a = 6.85, b = 7.15, c = 7)
  expect_identical(row_total(d, c("a", "b", "c")), 21)
})

test_that("describe_scores trên dữ liệu nhỏ", {
  x <- c(5, 5, 6, 7.5, 10, 0.5, NA)
  r <- describe_scores(x, 10, fail_cut = 1)
  expect_equal(r$so_thi_sinh, 6L)
  expect_equal(r$diem_tb, round(mean(c(5, 5, 6, 7.5, 10, 0.5)), 2))
  expect_equal(r$trung_vi, 5.5)
  expect_equal(r$diem_pho_bien, 5)
  expect_equal(r$diem_cao_nhat, 10)
  expect_equal(r$so_ts_diem_cao_nhat, 1L)
  expect_equal(r$so_diem_liet, 1L)
})

test_that("threshold_table đếm đúng (>=) kể cả đúng mốc", {
  x <- c(4.95, 5, 5, 9.5, 10)
  f <- score_freq(x, 10)
  th <- threshold_table(f, c(5, 9.5, 10))
  expect_equal(th$so_ts, c(4L, 2L, 1L))
})

test_that("band_table và exact_table cộng lại bằng tổng", {
  x <- c(0.25, 1, 1.75, 9.99, 10, 10)
  f <- score_freq(x, 10)
  b <- band_table(f, 10)
  expect_equal(sum(b$n), 6L)
  expect_equal(b[band == 10, n], 2L)
  expect_equal(b[band == 9, n], 1L)
  expect_equal(sum(exact_table(f)$n), 6L)
})
