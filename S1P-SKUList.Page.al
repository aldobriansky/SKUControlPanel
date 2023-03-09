page 50125 "S1P-SKU List"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "S1P-SKU";
    Caption = 'My SKU';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(StockkeepingUnits)
            {
                field("Item No."; Rec."Item No.")
                {
                    trigger OnValidate()
                    begin
                        Rec.CalculateValues();
                        CurrPage.Update();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    trigger OnValidate()
                    begin
                        Rec.CalculateValues();
                        CurrPage.Update();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    trigger OnValidate()
                    begin
                        Rec.CalculateValues();
                        CurrPage.Update();
                    end;
                }
                field(Inventory; Rec.Inventory)
                {

                }
                field("Available Inventory"; Rec."Available Inventory")
                {

                }
                field("Sales Qty."; Rec."Sales Qty.")
                {

                }
                field("Purchase Qty."; Rec."Purchase Qty.")
                {

                }
                field("Prod. Output Qty."; Rec."Prod. Output Qty.")
                {

                }
                field("Prod. Consumption Qty."; Rec."Prod. Consumption Qty.")
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(SKU)
            {
                action("View SKU")
                {
                    Scope = Repeater;
                    Image = SKU;

                    trigger OnAction();
                    begin

                    end;
                }
                action("Select SKU")
                {
                    Scope = Page;
                    Image = SKU;

                    trigger OnAction()
                    begin

                    end;
                }
                action("Create SKU")
                {
                    Scope = Page;
                    Ellipsis = true;
                    Image = CreateSKU;

                    trigger OnAction()
                    begin

                    end;
                }
            }
            action(GetDocuments)
            {
                Caption = 'Get Documents';
                Image = GetSourceDoc;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalculateValues();
    end;
}