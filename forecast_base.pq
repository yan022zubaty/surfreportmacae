let
    // ============================================================
    // 1) IMPORTAÇÃO DO CSV
    // ============================================================
    Fonte =
        Csv.Document(
            File.Contents(
                "C:\Users\User\Desktop\YAN ZUBATY\TCC\surfreport.csv"
            ),
            [
                Delimiter = ",",
                Encoding = 1252,
                QuoteStyle = QuoteStyle.None
            ]
        ),

    // ============================================================
    // 2) PROMOVER CABEÇALHOS
    // ============================================================
    Cabecalhos =
        Table.PromoteHeaders(
            Fonte,
            [PromoteAllScalars = true]
        ),

    // ============================================================
    // 3) CONVERSÃO INICIAL PARA TEXTO
    // ============================================================
    Texto =
        Table.TransformColumnTypes(
            Cabecalhos,
            List.Transform(
                Table.ColumnNames(Cabecalhos),
                each {_, type text}
            )
        ),

    // ============================================================
    // 4) DEFINIÇÃO DOS TIPOS
    // ============================================================
    Tipos =
        Table.TransformColumnTypes(
            Texto,
            {
                {"Localidade", type text},
                {"Coordenadas", type text},
                {"time_local", type datetimezone},
                {"time_utc", type datetime},
                {"seaLevel", type number},

                {"swellDirection", type number},
                {"swellHeight", type number},
                {"swellPeriod", type number},

                {"secondarySwellDirection", type number},
                {"secondarySwellHeight", type number},
                {"secondarySwellPeriod", type number},

                {"waterTemperature", type number},

                {"waveDirection", type number},
                {"waveHeight", type number},
                {"wavePeriod", type number},

                {"windDirection", type number},
                {"windSpeed", type number},

                {"windWaveDirection", type number},
                {"windWaveHeight", type number},
                {"windWavePeriod", type number},

                {"tide_seaLevel", type number}
            },
            "en-US"
        ),

    // ============================================================
    // 5) FUNÇÃO: GRAUS -> DIREÇÃO CARDINAL (16 PONTOS)
    // ============================================================
    DirCardinal = (deg as nullable number) as nullable text =>
        if deg = null then
            null
        else
            {
                "N", "NNE", "NE", "ENE",
                "E", "ESE", "SE", "SSE",
                "S", "SSW", "SW", "WSW",
                "W", "WNW", "NW", "NNW"
            }
            {
                Number.IntegerDivide(
                    Number.Mod(deg + 11.25, 360),
                    22.5
                )
            },

    // ============================================================
    // 6) CRIAR DIREÇÕES CARDINAIS
    // ============================================================
    Direcoes =
        List.Accumulate(
            {
                {"swellDirection", "swellDirection_cardinal"},
                {"secondarySwellDirection", "secondarySwellDirection_cardinal"},
                {"waveDirection", "waveDirection_cardinal"},
                {"windDirection", "windDirection_cardinal"},
                {"windWaveDirection", "windWaveDirection_cardinal"}
            },
            Tipos,
            (Tabela, Coluna) =>
                Table.AddColumn(
                    Tabela,
                    Coluna{1},
                    each DirCardinal(
                        Record.Field(_, Coluna{0})
                    ),
                    type text
                )
        ),

    // ============================================================
    // 7) REMOVER seaLevel
    // ============================================================
    RemoverSeaLevel =
        Table.RemoveColumns(
            Direcoes,
            {"seaLevel"}
        ),

    // ============================================================
    // 8) RENOMEAR COLUNAS
    // ============================================================
    Renomear =
        Table.RenameColumns(
            RemoverSeaLevel,
            {
                {"swellHeight", "swell_H"},
                {"swellDirection", "swell_D"},
                {"swellPeriod", "swell_P"},

                {"secondarySwellDirection", "swell2_D"},
                {"secondarySwellHeight", "swell2_H"},
                {"secondarySwellPeriod", "swell2_P"},

                {"waveDirection", "wave_D"},
                {"waveHeight", "wave_H"},
                {"wavePeriod", "wave_P"},

                {"windDirection", "wind_D"},

                {"swellDirection_cardinal", "swell°"},
                {"secondarySwellDirection_cardinal", "swell2°"},
                {"waveDirection_cardinal", "wave°"},
                {"windDirection_cardinal", "wind°"},
                {"windWaveDirection_cardinal", "windWave°"}
            }
        ),

    // ============================================================
    // 9) VELOCIDADE DO VENTO EM km/h
    //
    // Conversão e ajuste experimental preservados:
    // windSpeed_kmh = windSpeed × 3,6 × 1,60
    //
    // O coeficiente 1,60 é provisório e depende de validação.
    // ============================================================
    WindKmh =
        Table.AddColumn(
            Renomear,
            "windSpeed_kmh",
            each
                if [windSpeed] = null then
                    null
                else
                    [windSpeed] * 3.6 * 1.60,
            type number
        ),

    // ============================================================
    // 10) VELOCIDADE DO VENTO EM NÓS
    // Mantida a conversão original, sem o ajuste de 1,60.
    // ============================================================
    WindKt =
        Table.AddColumn(
            WindKmh,
            "windSpeed_kt",
            each
                if [windSpeed] = null then
                    null
                else
                    [windSpeed] * 1.94384,
            type number
        ),

    // ============================================================
    // 11) CLASSIFICAÇÃO DA INTENSIDADE DO VENTO
    // ============================================================
    IntensidadeVento =
        Table.AddColumn(
            WindKt,
            "intensidade_vento",
            each
                if [windSpeed_kmh] = null then null
                else if [windSpeed_kmh] < 5 then "Muito fraco"
                else if [windSpeed_kmh] < 10 then "Fraco"
                else if [windSpeed_kmh] < 15 then "Moderado"
                else if [windSpeed_kmh] <= 25 then "Forte"
                else "Muito forte",
            type text
        ),

    // ============================================================
    // 12) CLASSIFICAÇÃO DA DIREÇÃO DO VENTO
    // ============================================================
    ClasseVento =
        Table.AddColumn(
            IntensidadeVento,
            "classe_vento",
            each
                if [#"wind°"] = null then
                    null

                else if List.Contains(
                    {"N", "NNE", "W", "WNW", "NW", "NNW"},
                    [#"wind°"]
                ) then
                    "Terral"

                else if List.Contains(
                    {"ENE", "NE", "WSW", "SW"},
                    [#"wind°"]
                ) then
                    "Cruzado"

                else if List.Contains(
                    {"E", "S", "SSW"},
                    [#"wind°"]
                ) then
                    "Maral"

                else if List.Contains(
                    {"ESE", "SE", "SSE"},
                    [#"wind°"]
                ) then
                    "Maral reto"

                else
                    null,
            type text
        ),

    // ============================================================
    // 13) AJUSTE LOCAL DA MARÉ
    // Correção empírica preservada: +0,60 m.
    // ============================================================
    MareReal =
        Table.AddColumn(
            ClasseVento,
            "mare_real",
            each
                if [tide_seaLevel] = null then
                    null
                else
                    [tide_seaLevel] + 0.6,
            type number
        ),

    // ============================================================
    // 13A) ORDENAR BASE PARA LEITURA DA EVOLUÇÃO DA MARÉ
    // ============================================================
    OrdenarMare =
        Table.Sort(
            MareReal,
            {{"time_local", Order.Ascending}}
        ),

    // ============================================================
    // 13B) CRIAR ÍNDICE AUXILIAR DA MARÉ
    // ============================================================
    IndiceMare =
        Table.AddIndexColumn(
            OrdenarMare,
            "idx_mare",
            0,
            1,
            Int64.Type
        ),

    BufferMare =
        Table.Buffer(IndiceMare),

    // ============================================================
    // 13C) BUSCAR ALTURA DA MARÉ NO REGISTRO ANTERIOR
    // ============================================================
    MareAnterior =
        Table.AddColumn(
            BufferMare,
            "mare_anterior",
            each
                let
                    i = [idx_mare]
                in
                    if i = 0 then
                        null
                    else
                        try BufferMare{i - 1}[mare_real] otherwise null,
            type number
        ),

    // ============================================================
    // 13D) BUSCAR ALTURA DA MARÉ NO REGISTRO SEGUINTE
    // ============================================================
    MareSeguinte =
        Table.AddColumn(
            MareAnterior,
            "mare_seguinte",
            each
                let
                    i = [idx_mare]
                in
                    try BufferMare{i + 1}[mare_real] otherwise null,
            type number
        ),

    // ============================================================
    // 13E) CLASSIFICAR A CONDIÇÃO DA MARÉ
    // ============================================================
    CondicaoMare =
        Table.AddColumn(
            MareSeguinte,
            "condicao_mare",
            each
                let
                    atual = [mare_real],
                    anterior = [mare_anterior],
                    seguinte = [mare_seguinte]
                in
                    if atual = null then
                        null

                    else if anterior <> null and seguinte <> null
                        and atual >= anterior and atual >= seguinte
                        and (atual > anterior or atual > seguinte)
                    then
                        "Maré alta"

                    else if anterior <> null and seguinte <> null
                        and atual <= anterior and atual <= seguinte
                        and (atual < anterior or atual < seguinte)
                    then
                        "Maré baixa"

                    else if seguinte <> null and seguinte > atual then
                        "Enchente"

                    else if seguinte <> null and seguinte < atual then
                        "Vazante"

                    else if anterior <> null and atual > anterior then
                        "Enchente"

                    else if anterior <> null and atual < anterior then
                        "Vazante"

                    else
                        null,
            type text
        ),

    // ============================================================
    // 13F) REMOVER COLUNAS AUXILIARES DA MARÉ
    // ============================================================
    RemoverAuxiliaresMare =
        Table.RemoveColumns(
            CondicaoMare,
            {"idx_mare", "mare_anterior", "mare_seguinte"}
        ),

    // ============================================================
    // 14) PANORAMA GERAL DO PERÍODO
    //
    // A antiga etapa FaixaHorario foi removida.
    // ============================================================
    PeriodoDia =
        Table.AddColumn(
            RemoverAuxiliaresMare,
            "periodo_dia",
            each
                let
                    h =
                        if [time_local] = null then
                            null
                        else
                            Time.From([time_local])
                in
                    if h = null then
                        null
                    else if h >= #time(5, 0, 0)
                        and h < #time(12, 0, 0)
                    then
                        "Manhã"
                    else if h >= #time(12, 0, 0)
                        and h <= #time(18, 0, 0)
                    then
                        "Tarde"
                    else
                        "Fora do período",
            type text
        ),

    // ============================================================
    // 15) EXTRAIR HORA
    // ============================================================
    Hora =
        Table.AddColumn(
            PeriodoDia,
            "hora",
            each
                if [time_local] = null then
                    null
                else
                    Time.Hour(Time.From([time_local])),
            Int64.Type
        ),

    // ============================================================
    // 15A) CRIAR HORA REAL PARA EXIBIÇÃO
    // ============================================================
    HoraReal =
        Table.AddColumn(
            Hora,
            "Hora real",
            each
                if [hora] = null then
                    null
                else
                    Text.From([hora]) & "h",
            type text
        ),

    // ============================================================
    // 16) EXTRAIR DATA LOCAL
    // ============================================================
    Data =
        Table.AddColumn(
            HoraReal,
            "data",
            each
                if [time_local] = null then
                    null
                else
                    Date.From([time_local]),
            type date
        ),

    // ============================================================
    // 17) REMOVER LOCALIDADE
    // ============================================================
    RemoverLocalidade =
        Table.RemoveColumns(
            Data,
            {"Localidade"}
        ),

    // ============================================================
    // 18) ADICIONAR OS PICOS
    // Mantém "Pico" na forecast_base.
    // ============================================================
    AdicionarPico =
        Table.AddColumn(
            RemoverLocalidade,
            "Pico",
            each {"Praia do Pecado", "Laje do Pecado"},
            type list
        ),

    // ============================================================
    // 19) EXPANDIR PICOS
    // ============================================================
    ExpandirPico =
        Table.ExpandListColumn(
            AdicionarPico,
            "Pico"
        ),

    // ============================================================
    // 20) BUSCAR REGRA DE QUALIDADE DO VENTO
    // DIM_Vento permanece com sua estrutura atual.
    // ============================================================
    RegraVento =
        Table.NestedJoin(
            ExpandirPico,
            {"Pico", "classe_vento", "intensidade_vento"},
            DIM_Vento,
            {"Pico", "classe_vento", "intensidade_vento"},
            "RegraVento",
            JoinKind.LeftOuter
        ),

    // ============================================================
    // 21) TRAZER QUALIDADE E SCORE DO VENTO
    // ============================================================
    QualidadeVento =
        Table.ExpandTableColumn(
            RegraVento,
            "RegraVento",
            {"qualidade_vento", "score_vento"},
            {"qualidade_vento", "score_vento"}
        ),

    // ============================================================
    // 22) CLASSIFICAR PORTE DA ONDA
    //
    // PRAIA DO PECADO
    // Pequena: <= 0,90 m
    // Média:   > 0,90 m e < 1,50 m
    // Grande:  >= 1,50 m
    //
    // LAJE DO PECADO
    // Pequena: < 1,40 m
    // Média:   >= 1,40 m e <= 1,80 m
    // Grande:  > 1,80 m
    // ============================================================
    PorteOnda =
        Table.AddColumn(
            QualidadeVento,
            "porte_onda",
            each
                if [wave_H] = null then
                    null

                else if [Pico] = "Laje do Pecado" then
                    if [wave_H] < 1.4 then "Pequena"
                    else if [wave_H] <= 1.8 then "Média"
                    else "Grande"

                else if [Pico] = "Praia do Pecado" then
                    if [wave_H] <= 0.9 then "Pequena"
                    else if [wave_H] < 1.5 then "Média"
                    else "Grande"

                else
                    null,
            type text
        ),

    // ============================================================
    // 23) DEFINIR CLASSE DA ONDA
    // Mantém o nome antigo na forecast_base.
    // ============================================================
    ClasseOnda =
        Table.AddColumn(
            PorteOnda,
            "classe_onda",
            each [#"wave°"],
            type text
        ),

    // ============================================================
    // 24) BUSCAR REGRA NA NOVA DIM_ONDAS
    //
    // forecast_base: Pico + classe_onda + porte_onda
    // DIM_Ondas:     pico + direcao_onda + porte_onda
    // ============================================================
    RegraOnda =
        Table.NestedJoin(
            ClasseOnda,
            {"Pico", "classe_onda", "porte_onda"},
            DIM_Ondas,
            {"pico", "direcao_onda", "porte_onda"},
            "RegraOnda",
            JoinKind.LeftOuter
        ),

    // ============================================================
    // 25) TRAZER QUALIDADE, SCORE DA ONDA E REGRA DO VENTO
    // ============================================================
    QualidadeOnda =
        Table.ExpandTableColumn(
            RegraOnda,
            "RegraOnda",
            {"qualidade_onda", "score_onda", "regra_vento"},
            {"qualidade_onda", "score_onda", "regra_vento"}
        ),

    // ============================================================
    // 26) NORMALIZAR REGRA DO VENTO
    // null ou texto vazio passa a ser "Neutro".
    // ============================================================
    RegraVentoNormalizada =
        Table.AddColumn(
            QualidadeOnda,
            "regra_vento_chave",
            each
                if [regra_vento] = null
                    or Text.Trim(Text.From([regra_vento])) = ""
                then
                    "Neutro"
                else
                    Text.From([regra_vento]),
            type text
        ),

    // ============================================================
    // 27) CRIAR CHAVE DA QUALIDADE DE SURF
    // ============================================================
    ChaveQualidadeSurf =
        Table.AddColumn(
            RegraVentoNormalizada,
            "chave_qualidade_surf",
            each
                if [qualidade_onda] = null
                    or [score_vento] = null
                then
                    null
                else
                    Text.From([qualidade_onda])
                    & "|"
                    & [regra_vento_chave]
                    & "|"
                    & Text.From([score_vento]),
            type text
        ),

    // ============================================================
    // 28) JUNTAR COM DIM_QUALIDADE
    // ============================================================
    JuntarQualidadeSurf =
        Table.NestedJoin(
            ChaveQualidadeSurf,
            {"chave_qualidade_surf"},
            DIM_Qualidade,
            {"chave_qualidade_surf"},
            "DimQualidadeSurf",
            JoinKind.LeftOuter
        ),

    // ============================================================
    // 29) EXPANDIR RESULTADO DA QUALIDADE DE SURF
    // ============================================================
    ExpandirQualidadeSurf =
        Table.ExpandTableColumn(
            JuntarQualidadeSurf,
            "DimQualidadeSurf",
            {"qualidade_surf", "score_surf"},
            {"qualidade_surf", "score_surf"}
        ),

    // ============================================================
    // 30) CALCULAR QUALIDADE DO VENTO DO PERÍODO
    //
    // Agrupamento: DATA + PERÍODO + PICO
    //
    // Score consolidado:
    // (score médio + pior score) / 2
    //
    // Mantida a metodologia existente.
    // ============================================================
    ResumoQualidadeVentoPeriodo =
        Table.Group(
            ExpandirQualidadeSurf,
            {"data", "periodo_dia", "Pico"},
            {
                {
                    "Resumo",
                    each
                        let
                            Validos =
                                Table.SelectRows(
                                    _,
                                    each [score_vento] <> null
                                ),

                            QuantidadeValidos =
                                Table.RowCount(Validos),

                            ScoreMedio =
                                if QuantidadeValidos = 0 then
                                    null
                                else
                                    List.Average(
                                        Validos[score_vento]
                                    ),

                            PiorScore =
                                if QuantidadeValidos = 0 then
                                    null
                                else
                                    List.Min(
                                        Validos[score_vento]
                                    ),

                            ScorePeriodo =
                                if QuantidadeValidos = 0 then
                                    null
                                else
                                    (ScoreMedio + PiorScore) / 2,

                            QualidadePeriodo =
                                if ScorePeriodo = null then
                                    null
                                else if ScorePeriodo >= 4.75 then
                                    "Excelente"
                                else if ScorePeriodo >= 4.25 then
                                    "Muito bom"
                                else if ScorePeriodo >= 3.50 then
                                    "Bom"
                                else if ScorePeriodo >= 2.75 then
                                    "Regular para bom"
                                else if ScorePeriodo >= 2.00 then
                                    "Regular"
                                else
                                    "Ruim",

                            Resultado =
                                [
                                    qualidade_vento_predominante =
                                        QualidadePeriodo,

                                    score_qualidade_vento_predominante =
                                        ScorePeriodo
                                ]
                        in
                            Resultado
                }
            }
        ),

    // ============================================================
    // 31) EXPANDIR RESULTADO CONSOLIDADO DO VENTO
    // ============================================================
    ExpandirResumoQualidadeVento =
        Table.ExpandRecordColumn(
            ResumoQualidadeVentoPeriodo,
            "Resumo",
            {
                "qualidade_vento_predominante",
                "score_qualidade_vento_predominante"
            },
            {
                "qualidade_vento_predominante",
                "score_qualidade_vento_predominante"
            }
        ),

    // ============================================================
    // 32) DEVOLVER QUALIDADE CONSOLIDADA À FORECAST_BASE
    // ============================================================
    JuntarQualidadeVentoPredominante =
        Table.NestedJoin(
            ExpandirQualidadeSurf,
            {"data", "periodo_dia", "Pico"},
            ExpandirResumoQualidadeVento,
            {"data", "periodo_dia", "Pico"},
            "PredominanciaQualidadeVento",
            JoinKind.LeftOuter
        ),

    // ============================================================
    // 33) EXPANDIR QUALIDADE CONSOLIDADA DO VENTO
    // ============================================================
    ExpandirQualidadeVentoPredominante =
        Table.ExpandTableColumn(
            JuntarQualidadeVentoPredominante,
            "PredominanciaQualidadeVento",
            {
                "qualidade_vento_predominante",
                "score_qualidade_vento_predominante"
            },
            {
                "qualidade_vento_predominante",
                "score_qualidade_vento_predominante"
            }
        ),

    // ============================================================
    // 34) RESULTADO FINAL
    // ============================================================
    ResultadoFinal =
        ExpandirQualidadeVentoPredominante

in
    ResultadoFinal