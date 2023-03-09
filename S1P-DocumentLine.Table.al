table 50121 "S1P-Document Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Item Ledger Entry Type")
        {

        }
        field(2; "Record ID"; RecordId)
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
        field(100; Quantity; Decimal)
        {
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
        field(110; "Qty. to Handle"; Decimal)
        {
            BlankNumbers = BlankZero;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Record ID")
        {
            Clustered = true;
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

    trigger OnRename()
    begin

    end;

}