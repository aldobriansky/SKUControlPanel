table 50120 "S1P-SKU"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Line No."; Integer)
        {

        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item where(Type = const(Inventory));
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(13; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(100; Inventory; Decimal)
        {
            Caption = 'Inventory';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(110; "Available Inventory"; Decimal)
        {
            Caption = 'Available Inventory';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(200; "Sales Qty."; Decimal)
        {
            Caption = 'Sales Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(210; "New Sales Qty."; Decimal)
        {
            Caption = 'New Sales Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(300; "Purchase Qty."; Decimal)
        {
            Caption = 'Purchase Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(310; "New Purchase Qty."; Decimal)
        {
            Caption = 'New Purchase Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(400; "Prod. Output Qty."; Decimal)
        {
            Caption = 'Prod. Output Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(410; "New Prod. Output Qty."; Decimal)
        {
            Caption = 'New Prod. Output Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(500; "Prod. Consumption Qty."; Decimal)
        {
            Caption = 'Prod. Consumption Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(510; "New Prod. Consumption Qty."; Decimal)
        {
            Caption = 'New Prod. Consumption Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Variant Code", "Location Code")
        {
            Unique = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    procedure CalculateValues()
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        ClearValues();
        if StockkeepingUnit.Get("Location Code", "Item No.", "Variant Code") then begin
            StockkeepingUnit.CalcFields(
              Inventory, "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Prod. Order", "Qty. on Component Lines");
            Inventory := StockkeepingUnit.Inventory;
            "Sales Qty." := StockkeepingUnit."Qty. on Sales Order";
            "Purchase Qty." := StockkeepingUnit."Qty. on Purch. Order";
            "Prod. Output Qty." := StockkeepingUnit."Qty. on Prod. Order";
            "Prod. Consumption Qty." := StockkeepingUnit."Qty. on Component Lines";
        end;
    end;

    local procedure ClearValues()
    var
        MySKU: Record "S1P-SKU";
    begin
        MySKU := Rec;
        MySKU.Init();
        MySKU."Item No." := Rec."Item No.";
        MySKU."Variant Code" := Rec."Variant Code";
        MySKU."Location Code" := Rec."Location Code";
        MySKU := Rec;
    end;
}