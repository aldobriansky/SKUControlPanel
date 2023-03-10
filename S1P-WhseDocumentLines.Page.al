page 50127 "S1P-Whse. Document Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "S1P-Whse. Document Line";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(DocumentLines)
            {
                field(Document; DocumentText)
                {
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowWhseDocument();
                    end;
                }
                field(SKU; SKUText)
                {
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {

                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {

                }
                field("Current State"; Rec."Current State")
                {

                }
                field("Next State"; Rec."Next State")
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Go to next state")
            {
                Scope = Page;
                Image = GoTo;
                Enabled = false;

                trigger OnAction();
                begin

                end;
            }
        }
    }

    var
        WhseDocument: Record "S1P-Whse. Document" temporary;
        WhseDocumentLine: Record "S1P-Whse. Document Line" temporary;
        DocumentText: Text[100];
        SKUText: Text[100];

    trigger OnAfterGetRecord()
    var
        DocumentNo: Code[20];
        SKUDescBuilder: TextBuilder;
    begin
        Clear(DocumentText);
        Clear(SKUText);
        if Rec.IsEmpty() then
            exit;

        DocumentText := StrSubstNo('%1 %2', Rec."Warehouse Document Type", Rec.GetWhseDocumentNo());
        SKUDescBuilder.Append('Item ');
        SKUDescBuilder.Append(Rec."Item No.");
        if Rec."Variant Code" <> '' then begin
            SKUDescBuilder.Append(', Variant ');
            SKUDescBuilder.Append(Rec."Variant Code");
        end;
        if Rec."Location Code" <> '' then begin
            SKUDescBuilder.Append(' at location ');
            SKUDescBuilder.Append(Rec."Location Code");
        end;
        SKUText := SKUDescBuilder.ToText();
    end;

    procedure GetWarehouseDocuments()
    var
        MySKU: Record "S1P-SKU";
    begin
        WhseDocument.DeleteAll();
        WhseDocumentLine.DeleteAll();

        if MySKU.FindSet() then
            repeat
                MySKU.GetWarehouseDocuments(WhseDocument, WhseDocumentLine);
            until MySKU.Next() = 0;
        Rec.Copy(WhseDocumentLine, true);
    end;
}