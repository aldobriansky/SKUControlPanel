page 50128 "S1P-States"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "S1P-State";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'States';

    layout
    {
        area(Content)
        {
            repeater(States)
            {
                field(Name; Rec.Name)
                {

                }
            }
        }
    }

    var
        DocumentType: Enum "Item Ledger Entry Type";
        WhseDocumentType: Enum "S1P-Whse. Document Type";
        What: Option "Not Selected",Document,Warehouse;

    procedure SetDocumentType(DocType: Enum "Item Ledger Entry Type")
    begin
        What := What::Document;
        DocumentType := DocType;
    end;

    procedure SetWhseDocumentType(WhseDocType: Enum "S1P-Whse. Document Type")
    begin
        What := What::Warehouse;
        WhseDocumentType := WhseDocType;
    end;

    trigger OnOpenPage()
    var
        PurchaseStates: Enum "S1P-Purchase States";
        SalesStates: Enum "S1P-Sales States";
        ProdOrderStates: Enum "S1P-Prod. Order States";
        ProdOrderComponentStates: Enum "S1P-Prod. Order Comp. States";
        States: List of [Text];
        State: Text[50];
        i: Integer;
    begin
        if What = What::"Not Selected" then
            exit;

        if What = What::Document then begin
            case DocumentType of
                DocumentType::Purchase:
                    States := PurchaseStates.Names;
                DocumentType::Sale:
                    States := SalesStates.Names;
                DocumentType::Output:
                    States := ProdOrderStates.Names;
                DocumentType::Consumption:
                    States := ProdOrderComponentStates.Names;
            end;

            foreach State in States do begin
                Rec.Ordinal := i;
                Rec.Name := State;
                Rec.Insert();
                i += 1;
            end;
        end;
    end;
}