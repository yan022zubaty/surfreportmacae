let
    Fonte = #table(
        type table[
            Pico = text,
            classe_vento = text,
            intensidade_vento = text,
            qualidade_vento = text,
            score_vento = Int64.Type
        ],
        {
            // PRAIA DO PECADO - TERRAL
            {"Praia do Pecado","Terral","Muito fraco","Excelente",5},
            {"Praia do Pecado","Terral","Fraco","Excelente",5},
            {"Praia do Pecado","Terral","Moderado","Excelente",5},
            {"Praia do Pecado","Terral","Forte","Muito bom",4},
            {"Praia do Pecado","Terral","Muito forte","Bom",3},
            // PRAIA DO PECADO - CRUZADO
            {"Praia do Pecado","Cruzado","Muito fraco","Excelente",5},
            {"Praia do Pecado","Cruzado","Fraco","Muito bom",4},
            {"Praia do Pecado","Cruzado","Moderado","Bom",3},
            {"Praia do Pecado","Cruzado","Forte","Mediano",2},
            {"Praia do Pecado","Cruzado","Muito forte","Ruim",1},
            // PRAIA DO PECADO - MARAL
            {"Praia do Pecado","Maral","Muito fraco","Excelente",5},
            {"Praia do Pecado","Maral","Fraco","Bom",3},
            {"Praia do Pecado","Maral","Moderado","Mediano",2},
            {"Praia do Pecado","Maral","Forte","Ruim",1},
            {"Praia do Pecado","Maral","Muito forte","Ruim",1},
            // PRAIA DO PECADO - MARAL RETO
            {"Praia do Pecado","Maral reto","Muito fraco","Excelente",5},
            {"Praia do Pecado","Maral reto","Fraco","Bom",3},
            {"Praia do Pecado","Maral reto","Moderado","Ruim",1},
            {"Praia do Pecado","Maral reto","Forte","Ruim",1},
            {"Praia do Pecado","Maral reto","Muito forte","Ruim",1},
            // LAJE DO PECADO - TERRAL
            {"Laje do Pecado","Terral","Muito fraco","Excelente",5},
            {"Laje do Pecado","Terral","Fraco","Muito bom",4},
            {"Laje do Pecado","Terral","Moderado","Bom",3},
            {"Laje do Pecado","Terral","Forte","Mediano",2},
            {"Laje do Pecado","Terral","Muito forte","Ruim",1},
            // LAJE DO PECADO - CRUZADO
            {"Laje do Pecado","Cruzado","Muito fraco","Excelente",5},
            {"Laje do Pecado","Cruzado","Fraco","Bom",3},
            {"Laje do Pecado","Cruzado","Moderado","Bom",3},
            {"Laje do Pecado","Cruzado","Forte","Mediano",2},
            {"Laje do Pecado","Cruzado","Muito forte","Ruim",1},
            // LAJE DO PECADO - MARAL
            {"Laje do Pecado","Maral","Muito fraco","Excelente",5},
            {"Laje do Pecado","Maral","Fraco","Bom",3},
            {"Laje do Pecado","Maral","Moderado","Bom",3},
            {"Laje do Pecado","Maral","Forte","Mediano",2},
            {"Laje do Pecado","Maral","Muito forte","Ruim",1},
            // LAJE DO PECADO - MARAL RETO
            {"Laje do Pecado","Maral reto","Muito fraco","Excelente",5},
            {"Laje do Pecado","Maral reto","Fraco","Bom",3},
            {"Laje do Pecado","Maral reto","Moderado","Mediano",2},
            {"Laje do Pecado","Maral reto","Forte","Ruim",1},
            {"Laje do Pecado","Maral reto","Muito forte","Ruim",1}
        }
    ),
    Chave = Table.AddColumn(Fonte, "chave_vento", each [Pico] & "|" & [classe_vento] & "|" & [intensidade_vento], type text)
in
    Chave
