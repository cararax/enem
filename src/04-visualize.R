library(dplyr)
library(tidyr)
library(ggplot2)

cat("=== 04-visualize.R ===\n")

enem <- readRDS("data/processed/enem_wrangled.rds")
tabs <- readRDS("data/processed/tabelas_resumo.rds")

tema <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Paletas
cor_escola <- c("Pública" = "#E67E22", "Privada" = "#2C3E50")
cor_sexo <- c("F" = "#27AE60", "M" = "#8E44AD")
cor_raca <- c("Branca" = "#2C3E50", "Parda" = "#E67E22", "Preta" = "#C0392B", "Outros" = "#95A5A6")
cor_regiao <- c(
  "Norte" = "#E74C3C", "Nordeste" = "#E67E22",
  "Centro-Oeste" = "#F1C40F", "Sudeste" = "#2ECC71",
  "Sul" = "#3498DB"
)

# ---- G1: Evolução temporal (P1) ----
cat("G1 - Evolucao temporal...\n")
g1_data <- tabs$p1 |>
  select(NU_ANO, exatas = media_exatas, humanas = media_humanas, redacao = media_redacao) |>
  pivot_longer(-NU_ANO, names_to = "disciplina", values_to = "media")

g1 <- ggplot(g1_data, aes(x = NU_ANO, y = media, color = disciplina)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(2015, 2023, 2)) +
  scale_color_manual(
    values = c("exatas" = "#E74C3C", "humanas" = "#3498DB", "redacao" = "#2ECC71"),
    labels = c("Exatas", "Humanas", "Redação")
  ) +
  labs(
    title = "Evolução do Desempenho no ENEM (2015-2023)",
    x = "Ano", y = "Nota Média",
    color = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/01-evolucao_temporal.png", g1, width = 8, height = 5)

# ---- G2: Desempenho por região (P2) ----
cat("G2 - Desempenho por regiao...\n")
g2_data <- tabs$p2 |>
  pivot_longer(c(exatas, humanas, redacao), names_to = "disciplina", values_to = "media") |>
  mutate(disciplina = recode(disciplina, exatas = "Exatas", humanas = "Humanas", redacao = "Redação"))

g2 <- ggplot(g2_data, aes(x = reorder(regiao, -media), y = media, fill = disciplina)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Exatas" = "#E74C3C", "Humanas" = "#3498DB", "Redação" = "#2ECC71")) +
  labs(
    title = "Desempenho Médio por Região",
    x = NULL, y = "Nota Média",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/02-desempenho_regiao.png", g2, width = 8, height = 5)

# ---- G3: Escola pública vs privada por região (P3) ----
cat("G3 - Escola publica vs privada...\n")
g3 <- ggplot(tabs$p3b, aes(x = regiao, y = exatas, fill = escola)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = cor_escola) +
  labs(
    title = "Exatas: Escola Pública vs Privada por Região",
    x = NULL, y = "Nota Média (Exatas)",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/03-escola_publica_privada.png", g3, width = 8, height = 5)

# ---- G4: Gap escola por região (P3c) ----
cat("G4 - Gap escola por regiao...\n")
g4 <- ggplot(tabs$p3c, aes(x = reorder(regiao, -gap), y = gap)) +
  geom_col(fill = "#2C3E50", width = 0.6) +
  geom_text(aes(label = round(gap, 1)), vjust = -0.5, size = 3.5) +
  labs(
    title = "Diferença Privada - Pública em Exatas por Região",
    x = NULL, y = "Gap (pontos)",
    caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/04-gap_escola_regiao.png", g4, width = 7, height = 5)

# ---- G5: Raça por região (P4) ----
cat("G5 - Desempenho por raca e regiao...\n")
g5 <- ggplot(tabs$p4b, aes(x = regiao, y = exatas, fill = raca_grupo)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = cor_raca) +
  labs(
    title = "Desempenho em Exatas por Raça e Região",
    x = NULL, y = "Nota Média (Exatas)",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/05-desempenho_raca_regiao.png", g5, width = 9, height = 5)

# ---- G6: Sexo por disciplina (P5) ----
cat("G6 - Desempenho por sexo...\n")
g6_data <- tabs$p5b |>
  pivot_longer(-TP_SEXO, names_to = "prova", values_to = "media") |>
  mutate(prova = recode(prova,
    media_CN = "Ciências\nNatureza", media_CH = "Ciências\nHumanas",
    media_LC = "Linguagens", media_MT = "Matemática", media_RED = "Redação"
  ))

g6 <- ggplot(g6_data, aes(x = prova, y = media, fill = TP_SEXO)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_fill_manual(values = cor_sexo, labels = c("Feminino", "Masculino")) +
  labs(
    title = "Desempenho por Sexo e Tipo de Prova",
    x = NULL, y = "Nota Média",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/06-desempenho_sexo.png", g6, width = 8, height = 5)

# ---- G7: Faixa etária (P6) ----
cat("G7 - Faixa etaria...\n")
g7_data <- tabs$p6 |>
  mutate(faixa_grupo = factor(faixa_grupo, levels = c(
    "Até 19 anos", "20-24 anos", "25-30 anos", "31-40 anos",
    "41-50 anos", "51-60 anos", "60+ anos"
  ))) |>
  pivot_longer(c(exatas, humanas, redacao), names_to = "disciplina", values_to = "media") |>
  mutate(disciplina = recode(disciplina, exatas = "Exatas", humanas = "Humanas", redacao = "Redação"))

g7 <- ggplot(g7_data, aes(x = faixa_grupo, y = media, fill = disciplina)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Exatas" = "#E74C3C", "Humanas" = "#3498DB", "Redação" = "#2ECC71")) +
  labs(
    title = "Desempenho por Faixa Etária",
    x = NULL, y = "Nota Média",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("output/07-faixa_etaria.png", g7, width = 9, height = 5)

# ---- G8: Síntese de desigualdades (P7) ----
cat("G8 - Sintese de desigualdades...\n")
g8_data <- tabs$gaps |>
  select(regiao, `Escola\n(Pub-Priv)` = gap_escola,
         `Raça\n(Branco-Preto)` = gap_raca,
         `Sexo\n(Masc-Fem)` = gap_sexo) |>
  pivot_longer(-regiao, names_to = "tipo", values_to = "gap") |>
  mutate(tipo = factor(tipo, levels = c("Escola\n(Pub-Priv)", "Raça\n(Branco-Preto)", "Sexo\n(Masc-Fem)")))

g8 <- ggplot(g8_data, aes(x = regiao, y = gap, fill = tipo)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(
    values = c("Escola\n(Pub-Priv)" = "#2C3E50", "Raça\n(Branco-Preto)" = "#C0392B", "Sexo\n(Masc-Fem)" = "#8E44AD"),
    labels = c("Escola (Púb-Priv)", "Raça (Branco-Preto)", "Sexo (Masc-Fem)")
  ) +
  labs(
    title = "Síntese de Desigualdades por Região (Exatas)",
    x = NULL, y = "Gap (pontos)",
    fill = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/08-sintese_desigualdades.png", g8, width = 9, height = 5)

# ---- G9: Evolução por região (P2b) ----
cat("G9 - Evolucao por regiao...\n")
g9 <- ggplot(tabs$p2b, aes(x = NU_ANO, y = exatas, color = regiao)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  scale_x_continuous(breaks = seq(2015, 2023, 2)) +
  scale_color_manual(values = cor_regiao) +
  labs(
    title = "Evolução do Desempenho em Exatas por Região",
    x = "Ano", y = "Nota Média (Exatas)",
    color = NULL, caption = "Fonte: INEP/Microdados ENEM"
  ) +
  tema
ggsave("output/09-evolucao_regiao.png", g9, width = 8, height = 5)

cat("\nTodos os gráficos salvos em output/\n")
cat(list.files("output", pattern = "\\.png$"), sep = "\n")
