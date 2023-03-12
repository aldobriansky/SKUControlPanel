table 50121 "S1P-Document Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Item Ledger Entry Type")
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
        key(Key1; "Document Type", "Record ID")
        {
            Clustered = true;
        }
    }

    procedure GetDocumentNo(): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        case "Document Type" of
            "Document Type"::Purchase:
                begin
                    PurchaseLine.SetLoadFields("Document No.");
                    if PurchaseLine.Get("Record ID") then
                        exit(PurchaseLine."No.");
                end;
            "Document Type"::Sale:
                begin
                    SalesLine.SetLoadFields("Document No.");
                    if SalesLine.Get("Record ID") then
                        exit(SalesLine."Document No.");
                end;
            "Document Type"::Output:
                begin
                    ProdOrderLine.SetLoadFields("Prod. Order No.");
                    if ProdOrderLine.Get("Record ID") then
                        exit(ProdOrderLine."Prod. Order No.");
                end;
            "Document Type"::Consumption:
                begin
                    ProdOrderComponent.SetLoadFields("Prod. Order No.");
                    if ProdOrderComponent.Get("Record ID") then
                        exit(ProdOrderComponent."Prod. Order No.");
                end;
        end;
    end;

    procedure ShowDocument()
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        case "Document Type" of
            "Document Type"::Purchase:
                begin
                    if not PurchaseLine.Get("Record ID") then
                        exit;
                    PurchaseLine.SetRecFilter();
                    Page.Run(0, PurchaseLine);
                end;
            "Document Type"::Sale:
                begin
                    if not SalesLine.Get("Record ID") then
                        exit;
                    SalesLine.SetRecFilter();
                    Page.Run(0, SalesLine);
                end;
            "Document Type"::Output:
                begin
                    if not ProdOrderLine.Get("Record ID") then
                        exit;
                    ProdOrderLine.SetRecFilter();
                    Page.Run(0, ProdOrderLine);
                end;
            "Document Type"::Consumption:
                begin
                    if not ProdOrderComponent.Get("Record ID") then
                        exit;
                    ProdOrderComponent.SetRecFilter();
                    Page.Run(0, ProdOrderComponent);
                end;
        end;
    end;

    procedure GoToNextState()
    var
        Runner: Codeunit "SM9-Runner";
    begin
        Runner.Run(Rec);
    end;

    procedure ShowStateSequence()
    var
        StateSequence: Record "SM9-State Sequence";
    begin
        StateSequence.SetRange("Document Type", "Document Type");
        Page.Run(Page::"SM9-Sequences", StateSequence);
    end;

    local procedure LookupState(xState: Text[50]): Text[50]
    var
        State: Record "S1P-State";
        States: Page "S1P-States";
    begin
        States.SetDocumentType("Document Type");
        States.LookupMode := true;
        if States.RunModal() = Action::LookupOK then begin
            States.GetRecord(State);
            exit(State.Name);
        end;

        exit(xState);
    end;
}