table 50122 "S1P-Whse. Document Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Warehouse Document Type"; Enum "S1P-Whse. Document Type")
        {
            Editable = false;
        }
        field(2; "Record ID"; RecordId)
        {
            Editable = false;
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
        field(100; Quantity; Decimal)
        {
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(110; "Qty. to Handle"; Decimal)
        {
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(210; "Current State"; Text[50])
        {
            trigger OnLookup()
            begin
                "Current State" := LookupState("Current State");
            end;
        }
        field(220; "Next State"; Text[50])
        {
            trigger OnLookup()
            begin
                "Next State" := LookupState("Next State");
            end;
        }
    }

    keys
    {
        key(Key1; "Warehouse Document Type", "Record ID")
        {
            Clustered = true;
        }
    }

    procedure GetWhseDocumentNo(): Code[20]
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        case "Warehouse Document Type" of
            "Warehouse Document Type"::Receipt:
                begin
                    WarehouseReceiptLine.SetLoadFields("No.");
                    if WarehouseReceiptLine.Get("Record ID") then
                        exit(WarehouseReceiptLine."No.");
                end;
            "Warehouse Document Type"::Shipment:
                begin
                    WarehouseShipmentLine.SetLoadFields("No.");
                    if WarehouseShipmentLine.Get("Record ID") then
                        exit(WarehouseShipmentLine."No.");
                end;
            else begin
                WarehouseActivityLine.SetLoadFields("No.");
                if WarehouseActivityLine.Get("Record ID") then
                    exit(WarehouseActivityLine."No.");
            end;
        end;
    end;

    procedure ShowWhseDocument()
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        case "Warehouse Document Type" of
            "Warehouse Document Type"::Receipt:
                begin
                    if not WarehouseReceiptLine.Get("Record ID") then
                        exit;
                    WarehouseReceiptLine.SetRecFilter();
                    Page.Run(0, WarehouseReceiptLine);
                end;
            "Warehouse Document Type"::Shipment:
                begin
                    if not WarehouseShipmentLine.Get("Record ID") then
                        exit;
                    WarehouseShipmentLine.SetRecFilter();
                    Page.Run(0, WarehouseShipmentLine);
                end;
            else begin
                if not WarehouseActivityLine.Get("Record ID") then
                    exit;
                WarehouseActivityLine.SetRecFilter();
                Page.Run(0, WarehouseActivityLine);
            end;
        end;
    end;

    local procedure LookupState(xState: Text[50]): Text[50]
    var
        State: Record "S1P-State";
        States: Page "S1P-States";
    begin
        States.SetWhseDocumentType("Warehouse Document Type");
        States.LookupMode := true;
        if States.RunModal() = Action::LookupOK then begin
            States.GetRecord(State);
            exit(State.Name);
        end;

        exit(xState);
    end;
}