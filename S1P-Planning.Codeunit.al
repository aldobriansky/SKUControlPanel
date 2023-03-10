codeunit 50120 "S1P-Planning"
{
    TableNo = "S1P-SKU";

    trigger OnRun()
    begin
    end;

    var
        myInt: Integer;

    procedure GivePlanningAdvice(var CurrentSKU: Record "S1P-SKU")
    var
        MySKU: Record "S1P-SKU";
        Item: Record Item;
        RequisitionWkshName: Record "Requisition Wksh. Name";
        RequisitionLine: Record "Requisition Line";
        LibraryPlanning: Codeunit "Library - Planning";
    begin
        MySKU.Copy(CurrentSKU);

        LibraryPlanning.SelectRequisitionWkshName(RequisitionWkshName, RequisitionWkshName."Template Type"::Planning);
        RequisitionLine.SetRange("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", RequisitionWkshName.Name);
        RequisitionLine.DeleteAll();

        if MySKU.FindSet() then
            repeat
                Item.SetRange("No.", MySKU."Item No.");
                Item.SetRange("Variant Filter", MySKU."Variant Code");
                Item.SetRange("Location Filter", MySKU."Location Code");
                LibraryPlanning.CalcRegenPlanForPlanWksh(Item, WorkDate(), CalcDate('<CY>', WorkDate()));

                RequisitionLine.SetRange("No.", MySKU."Item No.");
                RequisitionLine.SetRange("Variant Code", MySKU."Variant Code");
                RequisitionLine.SetRange("Location Code", MySKU."Location Code");
                RequisitionLine.CalcSums("Original Quantity", Quantity);
                MySKU."Planning Suggestions" := RequisitionLine.Quantity - RequisitionLine."Original Quantity";
                MySKU.Modify();
            until MySKU.Next() = 0;

        if CurrentSKU.Find() then;
    end;

    procedure OpenPlanningWorksheet()
    begin
        Page.Run(Page::"Planning Worksheet");
    end;
}