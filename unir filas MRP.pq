let
    // Cargar los datos desde la fuente original
    Origen = Excel.Workbook(Web.Contents("https://indoramaventures.sharepoint.com/sites/IVQ-IVS-Spain/SupplyChain/Documentos%20compartidos/ENVASADO%20Y%20EXPEDICI%C3%93N/COM%C3%9AN%20JEFE%20UNIDAD%20Y%20AYUDANTE/Ayudante%20Jefe%20U.E.E/MRP_ENVASES/MRP_Envases%20_2024.xlsm"), null, true),
    PALÉ_Sheet = Origen{[Item="PALÉ",Kind="Sheet"]}[Data],
    #"Filas superiores quitadas" = Table.Skip(PALÉ_Sheet, 2),

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

    // Combinar el contenido de la fila 1 propagada y la fila 2 con "_", convirtiendo a texto si es necesario
    CombinarFilas = List.Transform(
        List.Zip({ListaRellenada, Fila2}),
        each Text.From(_{0}) & "_" & Text.From(_{1})
    ),

    // Crear una tabla con la fila combinada
    FilaCombinada = Table.FromRows({CombinarFilas}, Table.ColumnNames(#"Filas superiores quitadas")),

    // Obtener el resto de la tabla sin las dos primeras filas
    RestoTabla = Table.Skip(#"Filas superiores quitadas", 2),

    // Combinar la fila combinada con el resto de la tabla
    TablaFinal = Table.Combine({FilaCombinada, RestoTabla})
in
    TablaFinal
