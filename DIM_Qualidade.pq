let
    Fonte = #table(
        type table[
            qualidade_onda = text,
            regra_vento = nullable text,
            score_vento = Int64.Type,
            qualidade_surf = text,
            score_surf = Int64.Type
        ],
        {
            // ONDA INSUFICIENTE
            {"Insuficiente", null, 1, "Ruim", 1},
            {"Insuficiente", null, 2, "Ruim", 1},
            {"Insuficiente", null, 3, "Ruim", 1},
            {"Insuficiente", null, 4, "Ruim", 1},
            {"Insuficiente", null, 5, "Ruim", 1},
            // ONDA DESFAVORÁVEL
            {"Desfavorável", null, 1, "Ruim", 1},
            {"Desfavorável", null, 2, "Ruim", 1},
            {"Desfavorável", null, 3, "Ruim", 1},
            {"Desfavorável", null, 4, "Ruim", 1},
            {"Desfavorável", null, 5, "Regular", 2},
            // ONDA RAZOÁVEL
            {"Razoável", null, 1, "Ruim", 1},
            {"Razoável", null, 2, "Regular", 2},
            {"Razoável", null, 3, "Regular", 2},
            {"Razoável", null, 4, "Regular para bom", 3},
            {"Razoável", null, 5, "Regular para bom", 3},
            // ONDA FAVORÁVEL SEM REGRA ESPECIAL
            {"Favorável", null, 1, "Ruim", 1},
            {"Favorável", null, 2, "Regular", 2},
            {"Favorável", null, 3, "Regular para bom", 3},
            {"Favorável", null, 4, "Bom", 4},
            {"Favorável", null, 5, "Bom", 4},
            // ONDA MUITO FAVORÁVEL
            {"Muito favorável", null, 1, "Regular", 2},
            {"Muito favorável", null, 2, "Regular", 2},
            {"Muito favorável", null, 3, "Regular para bom", 3},
            {"Muito favorável", null, 4, "Bom", 4},
            {"Muito favorável", null, 5, "Bom", 4},
            // VENTO POTENCIALIZADOR
            {"Favorável", "Potencializador", 1, "Ruim", 1},
            {"Favorável", "Potencializador", 2, "Regular", 2},
            {"Favorável", "Potencializador", 3, "Regular para bom", 3},
            {"Favorável", "Potencializador", 4, "Bom", 4},
            {"Favorável", "Potencializador", 5, "Bom", 4},
            // VENTO CONDICIONANTE
            {"Favorável", "Condicionante", 1, "Ruim", 1},
            {"Favorável", "Condicionante", 2, "Ruim", 1},
            {"Favorável", "Condicionante", 3, "Regular", 2},
            {"Favorável", "Condicionante", 4, "Regular para bom", 3},
            {"Favorável", "Condicionante", 5, "Bom", 4}
        }
    ),
    RegraNormalizada = Table.AddColumn(Fonte, "regra_vento_chave", each if [regra_vento] = null then "Neutro" else [regra_vento], type text),
    Chave = Table.AddColumn(RegraNormalizada, "chave_qualidade_surf", each [qualidade_onda] & "|" & [regra_vento_chave] & "|" & Text.From([score_vento]), type text)
in
    Chave
