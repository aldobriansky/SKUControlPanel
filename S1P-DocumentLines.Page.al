page 50126 "S1P-Document Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "S1P-Document Line";
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
                        Rec.ShowDocument();
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

                trigger OnAction();
                begin
                    Rec.GoToNextState();
                end;
            }
            action("State Sequence")
            {
                Scope = Page;
                Image = SwitchCompanies;

                trigger OnAction()
                begin
                    Rec.ShowStateSequence();
                end;
            }
            action("Create state sequence")
            {
                Visible = false; // change to false after debug

                trigger OnAction()
                var
                    Runner: Codeunit "SM9-Runner";
                begin
                    Runner.CreateStateSequenceForPurchase();
                    Runner.CreateStateSequenceForSales();
                end;
            }
        }
    }

    var
        Document: Record "S1P-Document" temporary;
        DocumentLine: Record "S1P-Document Line" temporary;
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

        DocumentText := StrSubstNo('%1 %2', Rec."Document Type", Rec.GetDocumentNo());
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

    procedure GetDocuments()
    var
        MySKU: Record "S1P-SKU";
    begin
        Document.DeleteAll();
        DocumentLine.DeleteAll();

        if MySKU.FindSet() then
            repeat
                MySKU.GetDocuments(Document, DocumentLine);
            until MySKU.Next() = 0;
        Rec.Copy(DocumentLine, true);
    end;
}