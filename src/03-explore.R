library(dplyr)

cat("=== 03-explore.R ===\n")

time <- system.time({
  enem <- readRDS("data/processed/enem_wrangled.rds")

  medidas <- function(x) {
    c(
      media = mean(x, na.rm = TRUE),
      mediana = median(x, na.rm = TRUE),
      desv_pad = sd(x, na.rm = TRUE),
      q1 = quantile(x, 0.25, na.rm = TRUE),
      q3 = quantile(x, 0.75, na.rm = TRUE)
    )
  }
})

cat(sprintf("Tempo leitura: %.1f s\n\n", time["elapsed"]))

# ---- P1: Evolução temporal (2015-2023) ----
cat("========================================\n")
cat("P1 - Desempenho por ano (2015-2023)\n")
cat("========================================\n")
p1 <- enem |>
  group_by(NU_ANO) |>
  summarise(
    n = n(),
    media_exatas = mean(exatas),
    media_humanas = mean(humanas),
    media_redacao = mean(NU_NOTA_REDACAO),
    mediana_exatas = median(exatas),
    mediana_humanas = median(humanas),
    mediana_redacao = median(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p1, n = 20)

# ---- P2: Desempenho por região ----
cat("\n========================================\n")
cat("P2 - Desempenho por regiao\n")
cat("========================================\n")
p2 <- enem |>
  group_by(regiao) |>
  summarise(
    n = n(),
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  ) |>
  arrange(desc(exatas))
print(p2)

# ---- P2b: Regiao x Ano ----
cat("\n--- Regiao x Ano ---\n")
p2b <- enem |>
  group_by(regiao, NU_ANO) |>
  summarise(
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p2b, n = 30)

# ---- P3: Escola pública vs privada ----
cat("\n========================================\n")
cat("P3 - Escola publica vs privada\n")
cat("========================================\n")
p3 <- enem |>
  group_by(escola) |>
  summarise(
    n = n(),
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p3)

# ---- P3b: Escola x Regiao ----
cat("\n--- Escola x Regiao ---\n")
p3b <- enem |>
  group_by(regiao, escola) |>
  summarise(
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p3b, n = 20)

# ---- P3c: Gap pública-privada por região ----
cat("\n--- Gap Publica-Privada por regiao (exatas) ---\n")
p3c <- enem |>
  group_by(regiao, escola) |>
  summarise(media = mean(exatas), .groups = "drop") |>
  tidyr::pivot_wider(names_from = escola, values_from = media) |>
  mutate(gap = Privada - `Pública`) |>
  arrange(desc(gap))
print(p3c)

# ---- P4: Raça ----
cat("\n========================================\n")
cat("P4 - Desempenho por raca\n")
cat("========================================\n")
p4 <- enem |>
  group_by(raca_grupo) |>
  summarise(
    n = n(),
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p4)

# ---- P4b: Raça x Regiao ----
cat("\n--- Raca x Regiao ---\n")
p4b <- enem |>
  group_by(regiao, raca_grupo) |>
  summarise(
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    n = n(),
    .groups = "drop"
  )
print(p4b, n = 25)

# ---- P5: Sexo ----
cat("\n========================================\n")
cat("P5 - Desempenho por sexo\n")
cat("========================================\n")
p5 <- enem |>
  group_by(TP_SEXO) |>
  summarise(
    n = n(),
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p5)

# ---- P5b: Sexo x Disciplina ----
cat("\n--- Sexo por tipo de prova ---\n")
p5b <- enem |>
  group_by(TP_SEXO) |>
  summarise(
    media_CN = mean(NU_NOTA_CN),
    media_CH = mean(NU_NOTA_CH),
    media_LC = mean(NU_NOTA_LC),
    media_MT = mean(NU_NOTA_MT),
    media_RED = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p5b)

# ---- P6: Faixa etária ----
cat("\n========================================\n")
cat("P6 - Desempenho por faixa etaria\n")
cat("========================================\n")
p6 <- enem |>
  group_by(faixa_grupo) |>
  summarise(
    n = n(),
    exatas = mean(exatas),
    humanas = mean(humanas),
    redacao = mean(NU_NOTA_REDACAO),
    .groups = "drop"
  )
print(p6, n = 10)

# ---- P7: Tabela-síntese de desigualdades ----
cat("\n========================================\n")
cat("P7 - Sintese de desigualdades\n")
cat("========================================\n")

gaps <- enem |>
  group_by(regiao) |>
  summarise(
    n = n(),
    gap_escola = mean(exatas[escola == "Privada"]) - mean(exatas[escola == "Pública"]),
    gap_raca = mean(exatas[raca_grupo == "Branca"]) - mean(exatas[raca_grupo == "Preta"]),
    gap_sexo = mean(exatas[TP_SEXO == "M"]) - mean(exatas[TP_SEXO == "F"]),
    .groups = "drop"
  ) |>
  arrange(desc(gap_escola))
print(gaps)

# ---- Salvar tabelas para o relatório ----
saveRDS(list(p1 = p1, p2 = p2, p2b = p2b, p3 = p3, p3b = p3b,
             p3c = p3c, p4 = p4, p4b = p4b, p5 = p5, p5b = p5b,
             p6 = p6, gaps = gaps),
        "data/processed/tabelas_resumo.rds")

cat("\nTabelas salvas em data/processed/tabelas_resumo.rds\n")
cat("OK!\n")
