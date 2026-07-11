args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop("Usage: Rscript render_report.R <area>")
}

area <- args[1]

allowed_areas <- c("alfred", "alfred_lo", "quinces")

if (!area %in% allowed_areas) {
  stop(
    paste0(
      "Invalid area: ", area,
      ". Allowed areas are: ",
      paste(allowed_areas, collapse = ", ")
    )
  )
}

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

out_path <- file.path(getwd(), "results/reports", area)
if (!dir.exists(out_path)) {
  dir.create(out_path)
}

quarto::quarto_render(
  input = file.path(root, "R", "report.qmd"),
  output_file = paste0("report_", area, ".pdf"),
  quarto_args = c(
    "--output-dir", out_path
  ),
  execute_params = list(
    area = area,
    outdir = out_path
  )
)
