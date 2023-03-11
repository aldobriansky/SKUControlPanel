table 50100 "SM9-State Sequence"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(10; "Document Type"; Integer)
        {

        }
        field(20; "Document No."; Code[20])
        {

        }
        field(30; "Operation No."; Integer)
        {

        }
        field(40; "Current State"; Text[50])
        {

        }
        field(50; "Next State"; Text[50])
        {

        }
        field(60; "Event Subscriber"; Text[250])
        {
            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Subscriber Codeunit ID", Codeunit::"SM9-Subscriber");
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) = Action::LookupOK then
                    "Event Subscriber" := EventSubscription."Subscriber Function";
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.", "Operation No.")
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

    trigger OnRename()
    begin

    end;

}