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
            Editable = false;
        }
        field(110; "Available Inventory"; Decimal)
        {
            Caption = 'Available Inventory';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
            Editable = false;
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
        field(1000; "SKU Exists"; Boolean)
        {
            CalcFormula = exist("Stockkeeping Unit" where("Location Code" = field("Location Code"),
                                                          "Item No." = field("Item No."),
                                                          "Variant Code" = field("Variant Code")));
            FieldClass = FlowField;
            BlankZero = true;
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
        Item: Record Item;
    begin
        ClearValues();
        if StockkeepingUnit.Get("Location Code", "Item No.", "Variant Code") then begin
            StockkeepingUnit.CalcFields(
              Inventory, "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Prod. Order", "Qty. on Component Lines");
            Inventory := StockkeepingUnit.Inventory;
            "Sales Qty." := StockkeepingUnit."Qty. on Sales Order";
            "New Sales Qty." := "Sales Qty.";
            "Purchase Qty." := StockkeepingUnit."Qty. on Purch. Order";
            "New Purchase Qty." := "Purchase Qty.";
            "Prod. Output Qty." := StockkeepingUnit."Qty. on Prod. Order";
            "New Prod. Output Qty." := "Prod. Output Qty.";
            "Prod. Consumption Qty." := StockkeepingUnit."Qty. on Component Lines";
            "New Prod. Consumption Qty." := "Prod. Consumption Qty.";

            Item.Get(StockkeepingUnit."Item No.");
            Item.SetRange("Variant Filter", StockkeepingUnit."Variant Code");
            Item.SetRange("Location Filter", StockkeepingUnit."Location Code");
            Item.CalcFields("Reserved Qty. on Inventory");
            "Available Inventory" := StockkeepingUnit.Inventory - Item."Reserved Qty. on Inventory";
        end;
    end;

    procedure GetDocuments(var Document: Record "S1P-Document" temporary; var DocumentLine: Record "S1P-Document Line" temporary)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        Item.Get(Rec."Item No.");
        Item.SetRange("Variant Filter", Rec."Variant Code");
        Item.SetRange("Location Filter", Rec."Location Code");

        if SalesLine.FindLinesWithItemToPlan(Item, SalesLine."Document Type"::Order) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Sale, SalesLine.RecordId, Rec);
                DocumentLine.Quantity := SalesLine."Quantity (Base)";
                DocumentLine."Qty. to Handle" := SalesLine."Outstanding Qty. (Base)";
                DocumentLine.Insert();
                Document.Insert();
            until SalesLine.Next() = 0;

        if PurchaseLine.FindLinesWithItemToPlan(Item, PurchaseLine."Document Type"::Order) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Purchase, PurchaseLine.RecordId, Rec);
                DocumentLine.Quantity := PurchaseLine."Quantity (Base)";
                DocumentLine."Qty. to Handle" := PurchaseLine."Outstanding Qty. (Base)";
                DocumentLine.Insert();
                Document.Insert();
            until SalesLine.Next() = 0;
    end;

    procedure AddSKUs(var SKU: Record "Stockkeeping Unit")
    var
        MySKU: Record "S1P-SKU";
        LineNo: Integer;
    begin
        Rec.CalcFields("SKU Exists");
        if not Rec."SKU Exists" then
            if Rec.Delete() then;

        if MySKU.FindLast() then
            LineNo := MySKU."Line No." + 10000
        else
            LineNo := 10000;

        if SKU.FindSet() then
            repeat
                MySKU.Init();
                MySKU."Line No." := LineNo;
                MySKU."Item No." := SKU."Item No.";
                MySKU."Variant Code" := SKU."Variant Code";
                MySKU."Location Code" := SKU."Location Code";
                MySKU.CalculateValues();
                if MySKU.Insert() then;

                LineNo += 10000;
            until SKU.Next() = 0;
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

    local procedure InitDocument(var Document: Record "S1P-Document"; var DocumentLine: Record "S1P-Document Line";
                                   DocumentType: Enum "Item Ledger Entry Type"; RecId: RecordId; MySKU: Record "S1P-SKU")
    begin
        Document."Document Type" := DocumentType;
        Document."Record ID" := RecId;

        DocumentLine."Document Type" := Document."Document Type";
        DocumentLine."Record ID" := Document."Record ID";
        DocumentLine."Item No." := MySKU."Item No.";
        DocumentLine."Variant Code" := MySKU."Variant Code";
        DocumentLine."Location Code" := MySKU."Location Code";
    end;
}