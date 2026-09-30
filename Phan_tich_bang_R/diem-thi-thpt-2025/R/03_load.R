# =============================================================================
# 03_load.R - Đọc các file CSV thô và chuẩn hoá tên cột
# =============================================================================

# "TinHoc" / "Tinhoc" / "CN CongNghiep" -> "tinhoc" / "cncongnghiep"
normalise_names <- function(x) tolower(gsub("[^A-Za-z]", "", x))

read_raw_file <- function(path) {
  # SOBAODANH và Ma NN PHẢI đọc dạng chữ, nếu không "01000001" thành 1000001
  dt <- data.table::fread(
    path,
    colClasses  = list(character = c("SOBAODANH", "Ma NN")),
    na.strings  = c("", "NA"),
    strip.white = TRUE,
    encoding    = "UTF-8"
  )
  key <- normalise_names(names(dt))
  new <- unname(RAW_COL_MAP[key])
  if (anyNA(new)) {
    stop("Cột lạ trong ", basename(path), ": ",
         paste(names(dt)[is.na(new)], collapse = ", "),
         "\n -> hãy bổ sung vào RAW_COL_MAP (R/01_config.R)")
  }
  data.table::setnames(dt, new)
  dt[, source_file := basename(path)]
  dt[]
}

load_raw <- function(dir = CFG$dir_raw) {
  files <- list.files(dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(files) == 0) stop("Không có file .csv nào trong ", dir)
  log_info("Đọc ", length(files), " file: ", paste(basename(files), collapse = ", "))
  raw <- data.table::rbindlist(lapply(files, read_raw_file), use.names = TRUE, fill = TRUE)
  raw[, stt := NULL]   # STT chỉ là số thứ tự dòng, bỏ đi
  raw[]
}
