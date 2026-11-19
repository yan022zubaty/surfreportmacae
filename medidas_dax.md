# Medidas DAX — SurfReport

Expressões das medidas de apresentação fornecidas pelo autor. A coluna calculada `referencia_ondulacao` está documentada separadamente.

## SITUAÇÃO MARÉ

```dax
SITUAÇÃO MARÉ = 
VAR PicoSelecionado = HASONEVALUE('forecast_base'[Pico])
VAR DiaSelecionado = HASONEVALUE('forecast_base'[data])
VAR HoraSelecionada = HASONEVALUE('forecast_base'[hora])
VAR Situacao = SELECTEDVALUE('forecast_base'[condicao_mare])
RETURN
    IF(
        NOT PicoSelecionado || NOT DiaSelecionado || NOT HoraSelecionada,
        "-",
        SWITCH(
            Situacao,
            "Enchente", "Enchente ↑",
            "Vazante", "Vazante ↓",
            "Maré alta", "Maré alta ●",
            "Maré baixa", "Maré baixa ○",
            "-"
        )
    )
```

## REFERENCIA ONDULACAO CARD

```dax
REFERENCIA ONDULACAO CARD = 
VAR TabelaCategorias =
    FILTER(
        ADDCOLUMNS(
            VALUES('forecast_base'[referencia_ondulacao]),
            "Qtd", CALCULATE(COUNTROWS('forecast_base'))
        ),
        NOT ISBLANK('forecast_base'[referencia_ondulacao])
    )
VAR Resultado =
    MAXX(
        TOPN(
            1, TabelaCategorias,
            [Qtd], DESC,
            'forecast_base'[referencia_ondulacao], DESC
        ),
        'forecast_base'[referencia_ondulacao]
    )
RETURN
    IF(
        HASONEVALUE('forecast_base'[Pico]) && HASONEVALUE('forecast_base'[data]),
        Resultado,
        "-"
    )
```

## QUALIDADE VENTO

```dax
QUALIDADE VENTO = 
VAR PicoSelecionado = HASONEVALUE('forecast_base'[Pico])
VAR DiaSelecionado = HASONEVALUE('forecast_base'[data])
VAR ScoreMedio = AVERAGE('forecast_base'[score_vento])
VAR QualidadePeriodo =
    SWITCH(
        TRUE(),
        ISBLANK(ScoreMedio), "-",
        ScoreMedio >= 4.00, "Muito bom",
        ScoreMedio >= 3.25, "Bom",
        ScoreMedio >= 2.50, "Regular para bom",
        ScoreMedio >= 1.75, "Regular",
        "Ruim"
    )
RETURN
    IF(NOT PicoSelecionado || NOT DiaSelecionado, "-", QualidadePeriodo)
```

## QUALIDADE ONDAS

```dax
QUALIDADE ONDAS = 
VAR PicoSelecionado = HASONEVALUE('forecast_base'[Pico])
VAR DiaSelecionado = HASONEVALUE('forecast_base'[data])
VAR TabelaQualidades =
    FILTER(
        ADDCOLUMNS(
            VALUES('forecast_base'[qualidade_onda]),
            "Qtd", CALCULATE(COUNTROWS('forecast_base')),
            "Score", CALCULATE(MAX('forecast_base'[score_onda]))
        ),
        NOT ISBLANK('forecast_base'[qualidade_onda])
    )
VAR QualidadeVencedora =
    TOPN(1, TabelaQualidades, [Qtd], DESC, [Score], DESC, 'forecast_base'[qualidade_onda], ASC)
VAR Resultado = MAXX(QualidadeVencedora, 'forecast_base'[qualidade_onda])
RETURN
    IF(NOT PicoSelecionado || NOT DiaSelecionado, "-", COALESCE(Resultado, "-"))
```

## QUALIDADE SURF

```dax
QUALIDADE SURF =
VAR PicoSelecionado = HASONEVALUE('forecast_base'[Pico])
VAR DiaSelecionado = HASONEVALUE('forecast_base'[data])
VAR PeriodoSelecionado = HASONEVALUE('forecast_base'[periodo_dia])
VAR HoraFiltrada =
    ISFILTERED('forecast_base'[hora])
        || ISFILTERED('forecast_base'[Hora real])
        || ISFILTERED('forecast_base'[time_local])

// Classe mais frequente; empate resolvido pelo maior score
VAR TabelaAtual =
    FILTER(
        ADDCOLUMNS(
            VALUES('forecast_base'[qualidade_surf]),
            "Qtd", CALCULATE(COUNTROWS('forecast_base')),
            "Score", CALCULATE(MAX('forecast_base'[score_surf]))
        ),
        NOT ISBLANK('forecast_base'[qualidade_surf]) && [Qtd] > 0
    )
VAR QualidadeAtual =
    MAXX(
        TOPN(1, TabelaAtual, [Qtd], DESC, [Score], DESC, 'forecast_base'[qualidade_surf], ASC),
        'forecast_base'[qualidade_surf]
    )

// Manhã
VAR TabelaManha =
    CALCULATETABLE(
        ADDCOLUMNS(
            VALUES('forecast_base'[qualidade_surf]),
            "QtdManha", CALCULATE(COUNTROWS('forecast_base')),
            "ScoreManha", CALCULATE(MAX('forecast_base'[score_surf]))
        ),
        REMOVEFILTERS('forecast_base'[periodo_dia]),
        'forecast_base'[periodo_dia] = "Manhã"
    )
VAR VencedoraManha =
    TOPN(
        1,
        FILTER(TabelaManha, NOT ISBLANK('forecast_base'[qualidade_surf]) && [QtdManha] > 0),
        [QtdManha], DESC,
        [ScoreManha], DESC,
        'forecast_base'[qualidade_surf], ASC
    )
VAR QualidadeManha = MAXX(VencedoraManha, 'forecast_base'[qualidade_surf])
VAR NivelManha = MAXX(VencedoraManha, [ScoreManha])

// Tarde
VAR TabelaTarde =
    CALCULATETABLE(
        ADDCOLUMNS(
            VALUES('forecast_base'[qualidade_surf]),
            "QtdTarde", CALCULATE(COUNTROWS('forecast_base')),
            "ScoreTarde", CALCULATE(MAX('forecast_base'[score_surf]))
        ),
        REMOVEFILTERS('forecast_base'[periodo_dia]),
        'forecast_base'[periodo_dia] = "Tarde"
    )
VAR VencedoraTarde =
    TOPN(
        1,
        FILTER(TabelaTarde, NOT ISBLANK('forecast_base'[qualidade_surf]) && [QtdTarde] > 0),
        [QtdTarde], DESC,
        [ScoreTarde], DESC,
        'forecast_base'[qualidade_surf], ASC
    )
VAR QualidadeTarde = MAXX(VencedoraTarde, 'forecast_base'[qualidade_surf])
VAR NivelTarde = MAXX(VencedoraTarde, [ScoreTarde])
VAR Melhor = MAX(NivelManha, NivelTarde)
VAR Pior = MIN(NivelManha, NivelTarde)

// Matriz diária: 1=Ruim; 2=Regular; 3=Regular para bom; 4=Bom
VAR ResultadoDiario =
    SWITCH(
        TRUE(),
        ISBLANK(NivelManha) && ISBLANK(NivelTarde), BLANK(),
        ISBLANK(NivelManha), QualidadeTarde,
        ISBLANK(NivelTarde), QualidadeManha,
        Melhor = Pior, QualidadeManha,
        Pior = 1 && Melhor = 2, "Regular",
        Pior = 1 && Melhor = 3, "Regular",
        Pior = 1 && Melhor = 4, "Regular para bom",
        Pior = 2 && Melhor = 3, "Regular para bom",
        Pior = 2 && Melhor = 4, "Regular para bom",
        Pior = 3 && Melhor = 4, "Bom",
        BLANK()
    )
VAR Resultado =
    IF(PeriodoSelecionado || HoraFiltrada, QualidadeAtual, ResultadoDiario)
RETURN
    IF(NOT PicoSelecionado || NOT DiaSelecionado, "-", COALESCE(Resultado, "-"))
```
