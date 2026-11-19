# SurfReport — classificação das condições de surfe em Macaé (RJ)

Repositório de apoio ao Trabalho de Conclusão de Curso **Modelagem e calibração de dados oceanográficos para classificação e avaliação das condições de surfe**. O sistema avalia previsões ambientais para a **Praia do Pecado** e a **Laje do Pecado**, com processamento em Python, regras no Power Query (linguagem M), medidas DAX e visualização no Microsoft Power BI.

O painel Power BI apresenta a estrutura operacional do sistema e pode conter previsões referentes a datas não incluídas na avaliação observacional. Os resultados estatísticos apresentados no TCC foram calculados exclusivamente a partir dos 105 registros válidos documentados na base de avaliação.

## Organização

- `dados/observacoes_surfreport_2026.csv`: base final de avaliação observacional (105 registros válidos; 08 a 17/11/2026; separador `;`, codificação UTF-8 com BOM).
- `python/surfreport_noaa.py`: aquisição de previsões da Stormglass, com fonte NOAA para as variáveis ambientais e consulta separada de maré. **A chave de API foi substituída por texto de configuração.**
- `powerbi/Surfreport_Dashboard_v7.pbix`: arquivo do painel como fornecido pelo autor; o arquivo enviado contém as páginas *Tela Principal* e *Tela testes*. O autor informou que renomeou a segunda para *Tela Resultados*, mas a alteração ainda não está presente no PBIX fornecido.
- `powerbi/forecast_base.pq`: consulta Power Query usada para transformar dados e combinar as regras. É a versão original, com caminho local a ser ajustado pelo usuário.
- `powerbi/DIM_Ondas.pq`, `powerbi/DIM_Vento.pq`, `powerbi/DIM_Qualidade.pq`: tabelas de decisão empregadas no modelo.
- `powerbi/referencia_ondulacao.dax`: coluna calculada do modelo de referência M1.
- `powerbi/medidas_dax.md`: cinco medidas DAX de apresentação/consolidação do painel.
- `documentacao/dicionario_dados.md`: descrição dos 16 campos da base observacional.

## Resultado da avaliação observacional

Foram avaliados **105 registros**, sendo 90 da Praia do Pecado e 15 da Laje do Pecado, utilizando previsões obtidas no dia anterior (D−1):

| Modelo | Acertos | Concordância exata |
|---|---:|---:|
| M1 — apenas ondulação | 54/105 | 51,43% |
| M2 — completo | 85/105 | 80,95% |

Resultados restritos às condições observadas. As classificações visuais não equivalem a uma verdade física universal; houve distribuição desigual de registros e poucas condições favoráveis.

## Para executar a aquisição Python

1. Instale Python 3.9+ (preferencialmente 3.10+) e as dependências: `pip install -r requirements.txt`.
2. Abra `python/surfreport_noaa.py` e substitua **`INSIRA SUA CHAVE AQUI`** por sua própria chave de acesso à API Stormglass.
3. Altere `OUTPUT_PATH` para a pasta e o nome do CSV em seu computador.
4. Execute: `python python/surfreport_noaa.py`.
5. O script grava o CSV principal e uma cópia datada no mesmo diretório. A coleta depende de rede, permissões e cotas da API.

**Segurança:** não compartilhe chaves, tokens ou credenciais. Uma chave que tenha sido exposta deve ser revogada e substituída.

## Para consultar/atualizar o painel

1. Abra `powerbi/Surfreport_Dashboard_v7.pbix` no Power BI Desktop.
2. Para atualizar as previsões, configure a origem CSV na consulta `forecast_base`, substituindo o caminho de arquivo do computador original pelo caminho local correspondente.
3. Confira que as tabelas `DIM_Ondas`, `DIM_Vento` e `DIM_Qualidade` estejam carregadas e relacionadas pelas junções definidas na consulta.
4. Execute a atualização dos dados e confira os resultados no painel.

> **Nota de portabilidade:** o arquivo PBIX e a consulta M foram preservados como entregues, sem atualização de caminhos ou conexões. A abertura e a atualização em outro computador não foram testadas neste pacote. Antes da publicação definitiva, substituir o PBIX por uma versão salva após renomear *Tela testes* para *Tela Resultados*.

## Critérios e limites de aplicação

As direções de ondulação explicitamente configuradas em `DIM_Ondas` vão de **E a SW**, correspondentes às faixas consideradas relevantes para os locais estudados na metodologia. Outras direções não foram incluídas nas regras da implementação e não devem ser tratadas como classificadas.

A transformação em Power Query inclui dois ajustes empíricos documentados no código: multiplicação da velocidade do vento por **1,60** após conversão para km/h e soma de **0,60 m** ao nível de maré. Esses coeficientes não devem ser interpretados como correções universalmente validadas.

A base observacional referencia prints e arquivos históricos pelo nome, mas **as imagens e todas as versões históricas das previsões não estão incluídas** neste pacote. Portanto, o CSV oferece rastreabilidade documental parcial, e não reprodução integral de cada observação por terceiros.

## Uso acadêmico

Materiais disponibilizados para transparência metodológica e consulta acadêmica. Dados de terceiros, APIs e imagens de câmera permanecem sujeitos às condições de uso de seus respectivos fornecedores. A licença de redistribuição do conjunto ainda deve ser definida pelo autor.
