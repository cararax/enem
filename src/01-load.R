library(arrow)
library(dplyr)

cat("=== 01-load.R ===\n")
cat("Lendo enem.parquet e aplicando filtros...\n\n")

time <- system.time({
  df <- open_dataset("source/dados-enem/enem.parquet")

  enem <- df |>
    filter(
      TP_PRESENCA_CN == 1,
      TP_PRESENCA_CH == 1,
      TP_PRESENCA_LC == 1,
      TP_PRESENCA_MT == 1,
      IN_TREINEIRO == 0,
      TP_STATUS_REDACAO == 1
    ) |>
    select(
      NU_ANO, TP_FAIXA_ETARIA, TP_SEXO, TP_COR_RACA,
      TP_ESCOLA, SG_UF_ESC,
      NU_NOTA_CN, NU_NOTA_CH, NU_NOTA_LC, NU_NOTA_MT,
      NU_NOTA_REDACAO,
      NU_NOTA_COMP1, NU_NOTA_COMP2, NU_NOTA_COMP3,
      NU_NOTA_COMP4, NU_NOTA_COMP5
    ) |>
    collect()
})

cat("Tempo de execução:\n")
cat(sprintf("  Elapsed: %.1f s\n", time["elapsed"]))

cat(sprintf("\nLinhas: %d\n", nrow(enem)))
cat(sprintf("Colunas: %d\n", ncol(enem)))

cat("\nLinhas por ano:\n")
print(table(enem$NU_ANO))

cat("\nVerificação IN_TREINEIRO (deve ser vazio):\n")
print(table(enem$IN_TREINEIRO, useNA = "ifany"))

cat("\nVerificação TP_STATUS_REDACAO (deve ser só 1):\n")
print(table(enem$TP_STATUS_REDACAO, useNA = "ifany"))

cat("\nSalvando em data/processed/enem_filtrado.rds ...\n")
saveRDS(enem, "data/processed/enem_filtrado.rds")

cat("OK!\n")
