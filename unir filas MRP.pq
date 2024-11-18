let
    // Cargar los datos desde la fuente original
    Origen = Excel.Workbook(Web.Contents("https://indoramaventures.sharepoint.com/sites/IVQ-IVS-Spain/SupplyChain/Documentos%20compartidos/ENVASADO%20Y%20EXPEDICI%C3%93N/COM%C3%9AN%20JEFE%20UNIDAD%20Y%20AYUDANTE/Ayudante%20Jefe%20U.E.E/MRP_ENVASES/MRP_Envases%20_2024.xlsm"), null, true),
    PALÉ_Sheet = Origen{[Item="PALÉ",Kind="Sheet"]}[Data],

    // Este paso editar manualmente y eliminar las columnas que correspondan en cada consulta
    #"Columnas quitadas" = Table.RemoveColumns(PALÉ_Sheet,{"Column60", "Column61", "Column62", "Column63", "Column64", "Column65", "Column66", "Column67", "Column68", "Column69", "Column70", "Column71", "Column72", "Column73", "Column74", "Column75", "Column76", "Column77", "Column3", "Column59"}),
    #"Filas superiores quitadas" = Table.Skip(#"Columnas quitadas", 2),

    // Tomar la primera fila como una lista
    PrimeraFila = Table.FirstN(#"Filas superiores quitadas", 1),
    ListaFila1 = Record.ToList(PrimeraFila{0}),

    // Función para propagar valores en una lista
    PropagarValores = (lista as list) as list =>
        List.Accumulate(
            lista,
            {},
            (estado, actual) =>
                if actual <> null then estado & {actual} else
                if List.Count(estado) > 0 then estado & {List.Last(estado)} else estado & {""} // Valor predeterminado si es nulo
        ),

    // Llenar los valores en la lista
    ListaRellenada = PropagarValores(ListaFila1),

    // Crear una tabla con la lista actualizada (primera fila propagada)
    FilaModificada = Table.FromRows({ListaRellenada}, Table.ColumnNames(#"Filas superiores quitadas")),

    // Obtener la fila 2 como lista
    Fila2 = Record.ToList(Table.FirstN(Table.Skip(#"Filas superiores quitadas", 1), 1){0}),

    // Combinar el contenido de la fila 1 propagada y la fila 2 solo si hay valor en la fila 1
    CombinarFilas = List.Transform(
        List.Zip({ListaRellenada, Fila2}),
        each if _{0} <> null and _{0} <> "" then Text.From(_{0}) & "_" & Text.From(_{1}) else Text.From(_{1})
    ),

    // Crear una tabla con la fila combinada
    FilaCombinada = Table.FromRows({CombinarFilas}, Table.ColumnNames(#"Filas superiores quitadas")),

    // Obtener el resto de la tabla sin las dos primeras filas
    RestoTabla = Table.Skip(#"Filas superiores quitadas", 2),

    // Eliminar las columnas donde la fila combinada tenga valores null o vacíos
    ColumnasValidas = Table.SelectColumns(
        FilaCombinada,
        List.Select(
            Table.ColumnNames(FilaCombinada),
            each 
                Record.Field(Record.FromList(CombinarFilas, Table.ColumnNames(FilaCombinada)), _) <> null 
                and Record.Field(Record.FromList(CombinarFilas, Table.ColumnNames(FilaCombinada)), _) <> ""
        )
    ),

    // Combinar la fila combinada con el resto de la tabla
    TablaFinal = Table.Combine({ColumnasValidas, RestoTabla})
in
    TablaFinal
