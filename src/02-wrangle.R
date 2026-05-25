library(dplyr)

cat("=== 02-wrangle.R ===\n")

time <- system.time({
  enem <- readRDS("data/processed/enem_filtrado.rds")

  enem <- enem |>
    mutate(
      exatas = (NU_NOTA_CN + NU_NOTA_MT) / 2,
      humanas = (NU_NOTA_CH + NU_NOTA_LC) / 2,
      faixa_grupo = case_when(
        TP_FAIXA_ETARIA <= 4  ~ "Até 19 anos",
        TP_FAIXA_ETARIA <= 9  ~ "20-24 anos",
        TP_FAIXA_ETARIA <= 11 ~ "25-30 anos",
        TP_FAIXA_ETARIA <= 13 ~ "31-40 anos",
        TP_FAIXA_ETARIA <= 15 ~ "41-50 anos",
        TP_FAIXA_ETARIA <= 17 ~ "51-60 anos",
        TRUE                  ~ "60+ anos"
      ),
      raca_grupo = case_when(
        TP_COR_RACA == 1 ~ "Branca",
        TP_COR_RACA == 2 ~ "Preta",
        TP_COR_RACA == 3 ~ "Parda",
        TRUE              ~ "Outros"
      ),
      regiao = case_when(
        SG_UF_ESC %in% c("AC","AM","AP","PA","RO","RR","TO") ~ "Norte",
        SG_UF_ESC %in% c("AL","BA","CE","MA","PB","PE","PI","RN","SE") ~ "Nordeste",
        SG_UF_ESC %in% c("DF","GO","MT","MS") ~ "Centro-Oeste",
        SG_UF_ESC %in% c("ES","MG","RJ","SP") ~ "Sudeste",
        SG_UF_ESC %in% c("PR","RS","SC") ~ "Sul",
        TRUE ~ "Outro"
      ),
      escola = case_when(
        TP_ESCOLA == 2 ~ "Pública",
        TP_ESCOLA == 3 ~ "Privada",
        TRUE ~ "Outro"
      )
    ) |>
    filter(escola != "Outro", regiao != "Outro") |>
    select(-c(TP_FAIXA_ETARIA, TP_COR_RACA, TP_ESCOLA, SG_UF_ESC))
})

cat(sprintf("Tempo: %.1f s\n", time["elapsed"]))
cat(sprintf("Linhas: %d\n", nrow(enem)))
cat(sprintf("Colunas: %d\n", ncol(enem)))

cat("\nfaixa_grupo:\n")
print(table(enem$faixa_grupo))

cat("\nraca_grupo:\n")
print(table(enem$raca_grupo))

cat("\nescola:\n")
print(table(enem$escola))

cat("\nregiao:\n")
print(table(enem$regiao))

cat("\nSexo:\n")
print(table(enem$TP_SEXO))

cat("\nAnos:\n")
print(table(enem$NU_ANO))

cat("\nResumo Exatas:\n")
print(summary(enem$exatas))

cat("\nResumo Humanas:\n")
print(summary(enem$humanas))

cat("\nSalvando...\n")
saveRDS(enem, "data/processed/enem_wrangled.rds")
cat("OK!\n")
