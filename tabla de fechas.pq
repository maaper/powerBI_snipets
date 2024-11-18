let
    StartDate = #date(2016, 1, 1),
    CurrentDate = DateTime.LocalNow(),
    EndDate = Date.AddMonths(Date.From(CurrentDate), 18),
    DateList = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    DateTableWithColumns = Table.TransformColumns(
        DateTable,
        {
            {"Date", each DateTime.Date(_), type date}
        }
    ),
    DateTableExpanded = Table.AddColumn(DateTableWithColumns, "Year", each Date.Year([Date]), Int64.Type),
    DateTableExpanded2 = Table.AddColumn(DateTableExpanded, "Month", each Date.Month([Date]), Int64.Type),
    DateTableExpanded3 = Table.AddColumn(DateTableExpanded2, "Day", each Date.Day([Date]), Int64.Type),
    DateTableExpanded4 = Table.AddColumn(DateTableExpanded3, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    DateTableExpanded5 = Table.AddColumn(DateTableExpanded4, "Month Name", each Date.ToText([Date], "MMMM"), type text),
    DateTableExpanded6 = Table.AddColumn(DateTableExpanded5, "Day of Week", each Date.DayOfWeek([Date]), Int64.Type),
    DateTableExpanded7 = Table.AddColumn(DateTableExpanded6, "Day Name", each Date.ToText([Date], "dddd"), type text)
in
    DateTableExpanded7
