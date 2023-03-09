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
                field("SKU Exists"; Rec."SKU Exists")
                {
                    Editable = false;
                }
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
                action("Get existing SKUs")
                {
                    Scope = Page;
                    Image = SKU;

                    trigger OnAction()
                    var
                        SKU: Record "Stockkeeping Unit";
                    begin
                        if Rec."Item No." <> '' then
                            SKU.SetRange("Item No.", Rec."Item No.");
                        if Rec."Variant Code" <> '' then
                            SKU.SetRange("Variant Code", Rec."Variant Code");
                        if Rec."Location Code" <> '' then
                            SKU.SetRange("Location Code", Rec."Location Code");
                        if Page.RunModal(0, SKU) = Action::LookupOK then begin // rework to get selected SKUs, not all of them
                            Rec.AddSKUs(SKU);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action("Create SKU")
                {
                    Scope = Page;
                    Ellipsis = true;
                    Image = CreateSKU;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        SKU: Record "Stockkeeping Unit";
                        SKUCount: Integer;
                    begin
                        SKUCount := SKU.Count();

                        if Rec."Item No." <> '' then
                            Item.SetRange("No.", Rec."Item No.");
                        if Rec."Variant Code" <> '' then
                            Item.SetRange("Variant Filter", Rec."Variant Code");
                        if Rec."Location Code" <> '' then
                            Item.SetRange("Location Filter", Rec."Location Code");
                        Report.RunModal(Report::"Create Stockkeeping Unit", true, false, Item);

                        if SKU.Count() <= SKUCount then
                            exit;

                        if Rec."Item No." <> '' then
                            SKU.SetRange("Item No.", Rec."Item No.");
                        if Rec."Variant Code" <> '' then
                            SKU.SetRange("Variant Code", Rec."Variant Code");
                        if Rec."Location Code" <> '' then
                            SKU.SetRange("Location Code", Rec."Location Code");
                        if SKU.GetFilters() <> '' then begin
                            Rec.AddSKUs(SKU);
                            CurrPage.Update();
                        end;
                    end;
                }
            }
        }
    }

    procedure RefreshValues()
    var
        myInt: Integer;
    begin
        Rec.CalculateValues(Rec);
    end;
}