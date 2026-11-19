# SurfReport — classificação das condições de surfe em Macaé (RJ)

Repositório de apoio ao Trabalho de Conclusão de Curso **Modelagem e calibração de dados oceanográficos para classificação e avaliação das condições de surfe**. O sistema avalia previsões ambientais para a **Praia do Pecado** e a **Laje do Pecado**, com processamento em Python, regras no Power Query (linguagem M), medidas DAX e visualização no Microsoft Power BI.

O painel Power BI apresenta a estrutura operacional do sistema e pode conter previsões referentes a datas não incluídas na avaliação observacional. Os resultados estatísticos apresentados no TCC foram calculados exclusivamente a partir dos 105 registros válidos documentados na base de avaliação.

## Organização

Os arquivos do projeto estão disponibilizados diretamente na pasta principal do repositório.

- `observacoes_surfreport_2026.csv`: base final de avaliação observacional, contendo 105 registros válidos coletados entre 08 e 17/11/2026 (separador `;`, codificação UTF-8 com BOM).
- `surfreport_noaa.py`: script Python responsável pela aquisição de previsões da API Stormglass, utilizando a fonte NOAA para as variáveis meteorológicas e oceanográficas e consulta separada para os dados de maré. A chave de API foi substituída por um texto de configuração.
- `Surfreport_Dashboard_v7.pbix`: arquivo do painel interativo desenvolvido no Power BI, com duas páginas destinadas à visualização das previsões e à apresentação dos resultados da avaliação dos modelos.
- `forecast_base.pq`: consulta Power Query responsável pelo tratamento e pela padronização dos dados, além da integração das regras de classificação. O caminho local do CSV deve ser ajustado conforme o ambiente de execução.
- `DIM_Ondas.pq`, `DIM_Vento.pq` e `DIM_Qualidade.pq`: tabelas de regras utilizadas para avaliação da ondulação, do vento e da qualidade final das condições de surfe.
- `referencia_ondulacao.dax`: coluna calculada utilizada na classificação do modelo de referência (M1), baseado exclusivamente nas condições de ondulação.
- `medidas_dax.md`: documentação das cinco medidas DAX utilizadas na consolidação e apresentação dos indicadores no painel.
- `dicionario_dados.md`: descrição dos 16 campos da base de registros observacionais.

Os arquivos permitem consultar a estrutura computacional do sistema e os dados utilizados na avaliação apresentada no Trabalho de Conclusão de Curso. Para executar o processamento e atualizar as previsões, é necessário configurar uma chave válida da API Stormglass e ajustar os caminhos locais dos arquivos.

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
