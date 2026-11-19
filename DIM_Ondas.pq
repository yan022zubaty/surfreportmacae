let
    Fonte = #table(
        type table [
            chave_onda = text,
            direcao_onda = text,
            porte_onda = text,
            pico = text,
            qualidade_onda = text,
            score_onda = Int64.Type,
            regra_vento = nullable text
        ],
        {
            // PRAIA DO PECADO
            {"E_Pequena_Praia", "E", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"E_Media_Praia",   "E", "Média",   "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"E_Grande_Praia",  "E", "Grande",  "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"ESE_Pequena_Praia", "ESE", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"ESE_Media_Praia",   "ESE", "Média",   "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"ESE_Grande_Praia",  "ESE", "Grande",  "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SE_Pequena_Praia", "SE", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"SE_Media_Praia",   "SE", "Média",   "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SE_Grande_Praia",  "SE", "Grande",  "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SSE_Pequena_Praia", "SSE", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"SSE_Media_Praia",   "SSE", "Média",   "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SSE_Grande_Praia",  "SSE", "Grande",  "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"S_Pequena_Praia", "S", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"S_Media_Praia",   "S", "Média",   "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"S_Grande_Praia",  "S", "Grande",  "Praia do Pecado", "Favorável", 4, "Condicionante"},
            {"SSW_Pequena_Praia", "SSW", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"SSW_Media_Praia",   "SSW", "Média",   "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SSW_Grande_Praia",  "SSW", "Grande",  "Praia do Pecado", "Favorável", 4, "Condicionante"},
            {"SW_Pequena_Praia", "SW", "Pequena", "Praia do Pecado", "Razoável", 3, "Neutro"},
            {"SW_Media_Praia",   "SW", "Média",   "Praia do Pecado", "Favorável", 4, "Potencializador"},
            {"SW_Grande_Praia",  "SW", "Grande",  "Praia do Pecado", "Favorável", 4, "Condicionante"},
            // LAJE DO PECADO
            {"E_Pequena_Laje", "E", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"E_Media_Laje",   "E", "Média",   "Laje do Pecado", "Desfavorável", 2, null},
            {"E_Grande_Laje",  "E", "Grande",  "Laje do Pecado", "Desfavorável", 2, null},
            {"ESE_Pequena_Laje", "ESE", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"ESE_Media_Laje",   "ESE", "Média",   "Laje do Pecado", "Desfavorável", 2, null},
            {"ESE_Grande_Laje",  "ESE", "Grande",  "Laje do Pecado", "Razoável", 3, null},
            {"SE_Pequena_Laje", "SE", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"SE_Media_Laje",   "SE", "Média",   "Laje do Pecado", "Razoável", 3, null},
            {"SE_Grande_Laje",  "SE", "Grande",  "Laje do Pecado", "Razoável", 3, null},
            {"SSE_Pequena_Laje", "SSE", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"SSE_Media_Laje",   "SSE", "Média",   "Laje do Pecado", "Favorável", 4, null},
            {"SSE_Grande_Laje",  "SSE", "Grande",  "Laje do Pecado", "Muito favorável", 5, null},
            {"S_Pequena_Laje", "S", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"S_Media_Laje",   "S", "Média",   "Laje do Pecado", "Muito favorável", 5, null},
            {"S_Grande_Laje",  "S", "Grande",  "Laje do Pecado", "Muito favorável", 5, null},
            {"SSW_Pequena_Laje", "SSW", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"SSW_Media_Laje",   "SSW", "Média",   "Laje do Pecado", "Favorável", 4, null},
            {"SSW_Grande_Laje",  "SSW", "Grande",  "Laje do Pecado", "Muito favorável", 5, null},
            {"SW_Pequena_Laje", "SW", "Pequena", "Laje do Pecado", "Insuficiente", 1, null},
            {"SW_Media_Laje",   "SW", "Média",   "Laje do Pecado", "Favorável", 4, null},
            {"SW_Grande_Laje",  "SW", "Grande",  "Laje do Pecado", "Muito favorável", 5, null}
        }
    )
in
    Fonte
