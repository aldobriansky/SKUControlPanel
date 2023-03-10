codeunit 50121 "S1P-Synchronizer"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure GetCurrentStateForDocumentLine(var DocumentLine: Record "S1P-Document Line")
    var
        PurchaseCurrentState: Enum "S1P-Purchase States";
    begin
        DocumentLine."Current State" := '';
        case DocumentLine."Document Type" of
            DocumentLine."Document Type"::Purchase:
                begin
                    GetCurrentStateForPurchaseLine(DocumentLine, PurchaseCurrentState);
                    DocumentLine."Current State" := StrSubstNo('%1', PurchaseCurrentState);
                end;
        end;
    end;

    local procedure GetCurrentStateForPurchaseLine(DocumentLine: Record "S1P-Document Line"; var CurrentState: Enum "S1P-Purchase States")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        WarehouseRequest: Record "Warehouse Request";
    begin
        PurchaseLine.Get(DocumentLine."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if PurchaseLine."Quantity Received" = PurchaseLine.Quantity then begin
            CurrentState := CurrentState::"Can be invoiced";
            exit;
        end;

        if (PurchaseHeader.Status = PurchaseHeader.Status::Released) and (PurchaseLine."Qty. to Receive" <> 0) then begin
            CurrentState := CurrentState::"Can be received";
            exit;
        end;

        if (PurchaseHeader.Status = PurchaseHeader.Status::Released) and (PurchaseLine."Qty. to Receive" = 0) then begin
            WarehouseRequest.SetSourceFilter(Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.");
            WarehouseRequest.SetRange("Location Code", PurchaseLine."Location Code");
            if not WarehouseRequest.IsEmpty() then begin
                CurrentState := CurrentState::"Requires warehouse handling";
                exit;
            end;
        end;

        CurrentState := CurrentState::"Waiting for release";
    end;
}