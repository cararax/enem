# Plano do Projeto — Análise ENEM 2015-2023

## Narrativa Central

**Desigualdade Regional no ENEM (2015-2023): como escola, raça e gênero explicam as diferenças de desempenho entre os estados brasileiros.**

A história mostra como as desigualdades educacionais se manifestam de forma diferente em cada região/UF do Brasil, e como fatores como tipo de escola, cor/raça e sexo se combinam para produzir padrões de desempenho.

---

## Perguntas de Investigação

| # | Pergunta | Abordagem | Visualização |
|---|---|---|---|
| P1 | Como o desempenho médio (Exatas, Humanas, Redação) evoluiu no Brasil de 2015 a 2023? | Média nacional por ano, filtrando presentes + não treineiros | Linha com 3 séries (Exatas, Humanas, Redação), eixo X a cada 2 anos |
| P2 | Quais regiões têm maior/menor desempenho? Como isso mudou ao longo dos anos? | Média por região × ano | Linhas múltiplas (uma cor por região) ou barras empilhadas |
| P3 | Escola pública vs privada: a diferença é igual em todas as regiões? | Média por região × tipo de escola | Barras agrupadas (pública/privada lado a lado por região) |
| P4 | Existe desigualdade racial no ENEM? Ela varia por região? | Média por região × raça (Branca, Preta, Parda, Outros) | Heatmap (região × raça) ou barras múltiplas |
| P5 | Homens e mulheres têm perfis de notas diferentes? Isso muda por região? | Média por região × sexo, separado por Exatas/Humanas/Redação | Barras agrupadas ou dotplot |
| P6 | Faixa etária influencia o desempenho? O padrão é consistente entre regiões? | Média por faixa etária (5 em 5 anos) × região | Heatmap ou small multiples |
| P7 | Qual estado/região concentra as maiores desigualdades? | Tabela-síntese combinando gaps (pública-privada, branco-preto, homem-mulher) por UF | Tabela + gráfico final de síntese |

---

## Decisões Tomadas

| Decisão | Escolha |
|---|---|
| Anos | 2015 a 2023 (todos os 9 anos) |
| Filtro presença | Apenas participantes presentes em todas as 4 provas objetivas (TP_PRESENCA_* = 1) |
| Treineiros | Removidos (IN_TREINEIRO = 0) |
| Redação válida | Apenas redações com status "sem problemas" (TP_STATUS_REDACAO = 1) |
| Unidade de análise | Exatas = média(NU_NOTA_CN, NU_NOTA_MT); Humanas = média(NU_NOTA_CH, NU_NOTA_LC); Redação = NU_NOTA_REDACAO |
| Raça/Cor | 4 grupos: Branca (1), Preta (2), Parda (3), Outros (0, 4, 5, 6) |
| Faixa etária | Agrupada de 5 em 5 anos a partir das 20 faixas originais do INEP |
| Tipo de escola | TP_ESCOLA (1 = Não respondeu, 2 = Pública, 3 = Privada) |
| Geografia | Regiões (Norte, Nordeste, Centro-Oeste, Sudeste, Sul) nos gráficos principais; UF para análises complementares |
| Eixos temporais | Rótulos a cada 2 anos (2015, 2017, 2019, 2021, 2023) |
| Redação | Nota total incluída junto com Exatas e Humanas; competências em seção complementar |
| Apresentação | Será feita posteriormente com base no relatório |

---

## Pipeline Técnico

```
src/
├── 01-load.R          # Ler parquet com arrow, filtrar presentes + não treineiros
├── 02-wrangle.R        # Criar colunas derivadas (Exatas, Humanas, faixa etária, raça agrupada, região)
├── 03-explore.R        # Estatísticas descritivas, tabelas-resumo por grupos
├── 04-visualize.R      # Todos os gráficos (salvos em output/)
└── 05-report.qmd       # Relatório final em Quarto (PDF)

data/
├── raw/                # Dados brutos (não versionados)
└── processed/          # Dados processados (cache das etapas)

output/                 # Gráficos em PNG (output da etapa 04)
source/                 # Dados fonte + dicionário
```

### Etapas

1. **01-load.R**: `open_dataset()` + pipeline `dplyr` com filtros; `collect()` para memória
2. **02-wrangle.R**: Derivar `exatas`, `humanas`, `faixa_etaria`, `raca_grupo`, `regiao`
3. **03-explore.R**: Medidas-resumo (média, mediana, desvio, quartis) agrupadas por ano, região, escola, raça, sexo
4. **04-visualize.R**: `ggplot2` com tema consistente, salvar PNGs em `output/`
5. **05-report.qmd**: Relatório em Quarto com seções Resumo → Introdução → AED → Conclusões

---

## Paleta de Cores

| Variável | Cores |
|---|---|
| Escola pública | Laranja |
| Escola privada | Azul escuro |
| Raça/Cor | Paleta sequencial |
| Feminino | Verde |
| Masculino | Roxo |

---

## Estrutura do Relatório

1. **Resumo** — objetivos e principais conclusões
2. **Introdução** — contextualização dos microdados do INEP, período, variáveis, recorte temático
3. **Análise Exploratória dos Dados**
   - 3.1 Panorama temporal (2015-2023)
   - 3.2 Desempenho por região
   - 3.3 Escola pública vs privada
   - 3.4 Desigualdade racial
   - 3.5 Diferenças de gênero
   - 3.6 Faixa etária
4. **Conclusões** — achados mais relevantes, interpretações e reflexões
