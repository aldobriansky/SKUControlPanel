page 50127 "S1P-Warehouse Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "S1P-Warehouse Line";
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(DocumentLines)
            {
                field(Document; Document)
                {

                }
                field(SKU; SKU)
                {

                }
                field(Quantity; Rec.Quantity)
                {

                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {

                }
                field("Current State"; CurrentState)
                {

                }
                field("Next State"; NextState)
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("View Whse. Document")
            {
                Scope = Page;

                trigger OnAction();
                begin

                end;
            }
            action("Change State")
            {
                Scope = Page;

                trigger OnAction();
                begin

                end;
            }
        }
    }

    var
        Document: Text[100];
        SKU: Text[100];
        CurrentState: Text[50];
        NextState: Text[50];

    trigger OnAfterGetRecord()
    var
        DocumentNo: Code[20];
    begin

        Document := StrSubstNo('%1 %2', Rec."Warehouse Document Type", '<Number>');
        SKU := StrSubstNo('%1 (%2) at %3', Rec."Item No.", Rec."Variant Code", Rec."Location Code");
    end;
}