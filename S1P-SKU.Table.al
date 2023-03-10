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
            Editable = false;
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
            Editable = false;
        }
        field(510; "New Prod. Consumption Qty."; Decimal)
        {
            Caption = 'New Prod. Consumption Quantity';
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(900; "Planning Suggestions"; Decimal)
        {
            Caption = 'Planning Suggestions';
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

    procedure CalculateValues(var CurrentSKU: Record "S1P-SKU")
    var
        MySKU: Record "S1P-SKU";
    begin
        MySKU.Copy(CurrentSKU);
        if MySKU.FindSet() then
            repeat
                MySKU.CalculateValues();
                MySKU.Modify();
            until MySKU.Next() = 0;
        if CurrentSKU.Find() then;
    end;

    procedure CalculatePlanningSuggestions()
    var
        Planning: Codeunit "S1P-Planning";
    begin
        Planning.GivePlanningAdvice(Rec);
    end;

    procedure OpenPlanningWorksheet()
    var
        Planning: Codeunit "S1P-Planning";
    begin
        Planning.OpenPlanningWorksheet();
    end;

    procedure GetDocuments(var Document: Record "S1P-Document" temporary; var DocumentLine: Record "S1P-Document Line" temporary)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        Synchronizer: Codeunit "S1P-Synchronizer";
    begin
        Item.Get(Rec."Item No.");
        Item.SetRange("Variant Filter", Rec."Variant Code");
        Item.SetRange("Location Filter", Rec."Location Code");

        if SalesLine.FindLinesWithItemToPlan(Item, SalesLine."Document Type"::Order) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Sale, SalesLine.RecordId, Rec);
                DocumentLine.Quantity := SalesLine."Quantity (Base)";
                DocumentLine."Qty. to Handle" := SalesLine."Qty. to Ship (Base)";
                Synchronizer.GetCurrentStateForDocumentLine(DocumentLine);
                DocumentLine.Insert();
                Document.Insert();
            until SalesLine.Next() = 0;

        if PurchaseLine.FindLinesWithItemToPlan(Item, PurchaseLine."Document Type"::Order) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Purchase, PurchaseLine.RecordId, Rec);
                DocumentLine.Quantity := PurchaseLine."Quantity (Base)";
                DocumentLine."Qty. to Handle" := PurchaseLine."Qty. to Receive (Base)";
                Synchronizer.GetCurrentStateForDocumentLine(DocumentLine);
                DocumentLine.Insert();
                Document.Insert();
            until SalesLine.Next() = 0;

        if ProdOrderLine.FindLinesWithItemToPlan(Item, true) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Output, ProdOrderLine.RecordId, Rec);
                DocumentLine.Quantity := ProdOrderLine."Quantity (Base)";
                DocumentLine."Qty. to Handle" := ProdOrderLine."Remaining Qty. (Base)";
                Synchronizer.GetCurrentStateForDocumentLine(DocumentLine);
                DocumentLine.Insert();
                Document.Insert();
            until ProdOrderLine.Next() = 0;

        if ProdOrderComponent.FindLinesWithItemToPlan(Item, true) then
            repeat
                InitDocument(Document, DocumentLine, Document."Document Type"::Consumption, ProdOrderComponent.RecordId, Rec);
                DocumentLine.Quantity := ProdOrderComponent."Quantity (Base)";
                DocumentLine."Qty. to Handle" := ProdOrderComponent."Remaining Qty. (Base)";
                Synchronizer.GetCurrentStateForDocumentLine(DocumentLine);
                DocumentLine.Insert();
                Document.Insert();
            until ProdOrderLine.Next() = 0;
    end;

    procedure GetWarehouseDocuments(var WhseDocument: Record "S1P-Whse. Document" temporary; var WhseDocumentLine: Record "S1P-Whse. Document Line" temporary)
    var
        Item: Record Item;
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseDocumentType: Enum "S1P-Whse. Document Type";
    begin
        Item.Get(Rec."Item No.");
        Item.SetRange("Variant Filter", Rec."Variant Code");
        Item.SetRange("Location Filter", Rec."Location Code");

        WhseReceiptLine.SetRange("Item No.", Rec."Item No.");
        WhseReceiptLine.SetRange("Variant Code", Rec."Variant Code");
        WhseReceiptLine.SetRange("Location Code", Rec."Location Code");
        WhseReceiptLine.SetFilter("Qty. Outstanding (Base)", '<>0');
        if WhseReceiptLine.FindSet() then
            repeat
                InitWarehouseDocument(WhseDocument, WhseDocumentLine, "S1P-Whse. Document Type"::Receipt, WhseReceiptLine.RecordId, Rec);
                WhseDocumentLine.Quantity := WhseReceiptLine."Qty. (Base)";
                WhseDocumentLine."Qty. to Handle" := WhseReceiptLine."Qty. to Receive (Base)";
                WhseDocumentLine.Insert();
                WhseDocument.Insert();
            until WhseReceiptLine.Next() = 0;

        WhseShipmentLine.SetRange("Item No.", Rec."Item No.");
        WhseShipmentLine.SetRange("Variant Code", Rec."Variant Code");
        WhseShipmentLine.SetRange("Location Code", Rec."Location Code");
        WhseShipmentLine.SetFilter("Qty. Outstanding (Base)", '<>0');
        if WhseShipmentLine.FindSet() then
            repeat
                InitWarehouseDocument(WhseDocument, WhseDocumentLine, "S1P-Whse. Document Type"::Shipment, WhseShipmentLine.RecordId, Rec);
                WhseDocumentLine.Quantity := WhseShipmentLine."Qty. (Base)";
                WhseDocumentLine."Qty. to Handle" := WhseShipmentLine."Qty. to Ship (Base)";
                WhseDocumentLine.Insert();
                WhseDocument.Insert();
            until WhseShipmentLine.Next() = 0;

        WhseActivityLine.SetRange("Item No.", Rec."Item No.");
        WhseActivityLine.SetRange("Variant Code", Rec."Variant Code");
        WhseActivityLine.SetRange("Location Code", Rec."Location Code");
        WhseActivityLine.SetFilter("Qty. Outstanding (Base)", '<>0');
        if WhseActivityLine.FindSet() then
            repeat
                case WhseActivityLine."Activity Type" of
                    "Warehouse Activity Type"::"Invt. Put-away":
                        WhseDocumentType := WhseDocumentType::"Inventory Put-away";
                    "Warehouse Activity Type"::"Invt. Pick":
                        WhseDocumentType := WhseDocumentType::"Inventory Pick";
                    "Warehouse Activity Type"::"Put-away":
                        WhseDocumentType := WhseDocumentType::"Warehouse Put-away";
                    "Warehouse Activity Type"::Pick:
                        WhseDocumentType := WhseDocumentType::"Warehouse Pick";
                end;
                InitWarehouseDocument(WhseDocument, WhseDocumentLine, WhseDocumentType, WhseActivityLine.RecordId, Rec);
                WhseDocumentLine.Quantity := WhseActivityLine."Qty. (Base)";
                WhseDocumentLine."Qty. to Handle" := WhseActivityLine."Qty. to Handle (Base)";
                WhseDocumentLine.Insert();
                WhseDocument.Insert();
            until WhseActivityLine.Next() = 0;
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

    local procedure InitWarehouseDocument(var WhseDocument: Record "S1P-Whse. Document"; var WhseDocumentLine: Record "S1P-Whse. Document Line";
                                          WhseDocumentType: Enum "S1P-Whse. Document Type"; RecId: RecordId; MySKU: Record "S1P-SKU")
    begin
        WhseDocument."Warehouse Document Type" := WhseDocumentType;
        WhseDocument."Record ID" := RecId;

        WhseDocumentLine."Warehouse Document Type" := WhseDocument."Warehouse Document Type";
        WhseDocumentLine."Record ID" := WhseDocument."Record ID";
        WhseDocumentLine."Item No." := MySKU."Item No.";
        WhseDocumentLine."Variant Code" := MySKU."Variant Code";
        WhseDocumentLine."Location Code" := MySKU."Location Code";
    end;
}