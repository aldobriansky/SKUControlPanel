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
        SalesCurrentState: Enum "S1P-Sales States";
        ProdOrderState: Enum "S1P-Prod. Order States";
        ProdOrderCompState: Enum "S1P-Prod. Order Comp. States";
    begin
        DocumentLine."Current State" := '';
        case DocumentLine."Document Type" of
            DocumentLine."Document Type"::Purchase:
                begin
                    GetCurrentStateForPurchaseLine(DocumentLine, PurchaseCurrentState);
                    DocumentLine."Current State" := StrSubstNo('%1', PurchaseCurrentState);
                end;
            DocumentLine."Document Type"::Sale:
                begin
                    GetCurrentStateForSalesLine(DocumentLine, SalesCurrentState);
                    DocumentLine."Current State" := StrSubstNo('%1', SalesCurrentState);
                end;
            DocumentLine."Document Type"::Output:
                begin
                    GetCurrentStateForProdOrderLine(DocumentLine, ProdOrderState);
                    DocumentLine."Current State" := StrSubstNo('%1', ProdOrderState);
                end;
            DocumentLine."Document Type"::Consumption:
                begin
                    GetCurrentStateForProdOrderCompLine(DocumentLine, ProdOrderCompState);
                    DocumentLine."Current State" := StrSubstNo('%1', ProdOrderCompState);
                end;
        end;
    end;

    local procedure GetCurrentStateForPurchaseLine(DocumentLine: Record "S1P-Document Line"; var CurrentState: Enum "S1P-Purchase States")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        WarehouseRequest: Record "Warehouse Request";
        WhseRequestExists: Boolean;
    begin
        PurchaseLine.Get(DocumentLine."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        if PurchaseLine."Quantity Invoiced" = PurchaseLine.Quantity then begin
            CurrentState := CurrentState::Invoiced;
            exit;
        end;

        if PurchaseLine."Quantity Received" = PurchaseLine.Quantity then begin
            CurrentState := CurrentState::"Can be invoiced";
            exit;
        end;

        WarehouseRequest.SetSourceFilter(Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.");
        WarehouseRequest.SetRange("Location Code", PurchaseLine."Location Code");
        WhseRequestExists := not WarehouseRequest.IsEmpty();

        if (PurchaseHeader.Status = PurchaseHeader.Status::Released) and
           not WhseRequestExists and (PurchaseLine."Qty. to Receive" <> 0)
        then begin
            CurrentState := CurrentState::"Can be received";
            exit;
        end;

        if (PurchaseHeader.Status = PurchaseHeader.Status::Released) and WhseRequestExists then begin
            CurrentState := CurrentState::"Requires warehouse handling";
            exit;
        end;

        CurrentState := CurrentState::"Waiting for release";
    end;

    local procedure GetCurrentStateForSalesLine(DocumentLine: Record "S1P-Document Line"; var CurrentState: Enum "S1P-Sales States")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        WhseRequestExists: Boolean;
    begin
        SalesLine.Get(DocumentLine."Record ID");
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        if SalesLine."Quantity Invoiced" = SalesLine.Quantity then begin
            CurrentState := CurrentState::Invoiced;
            exit;
        end;

        if SalesLine."Quantity Shipped" = SalesLine.Quantity then begin
            CurrentState := CurrentState::"Can be invoiced";
            exit;
        end;

        WarehouseRequest.SetSourceFilter(Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.");
        WarehouseRequest.SetRange("Location Code", SalesLine."Location Code");
        WhseRequestExists := not WarehouseRequest.IsEmpty();

        if (SalesHeader.Status = SalesHeader.Status::Released) and
           not WhseRequestExists and (SalesLine."Qty. to Ship" <> 0)
        then begin
            CurrentState := CurrentState::"Can be shipped";
            exit;
        end;

        if (SalesHeader.Status = SalesHeader.Status::Released) and WhseRequestExists then begin
            CurrentState := CurrentState::"Requires warehouse handling";
            exit;
        end;

        CurrentState := CurrentState::"Waiting for release";
    end;

    local procedure GetCurrentStateForProdOrderLine(DocumentLine: Record "S1P-Document Line"; var CurrentState: Enum "S1P-Prod. Order States")
    var
        ProdOrderLine: Record "Prod. Order Line";
        WarehouseRequest: Record "Warehouse Request";
        WhseRequestExists: Boolean;
    begin
        ProdOrderLine.Get(DocumentLine."Record ID");

        if ProdOrderLine.Status = ProdOrderLine.Status::Finished then begin
            CurrentState := CurrentState::Finished;
            exit;
        end;

        if ProdOrderLine.Status <> ProdOrderLine.Status::Released then begin
            CurrentState := CurrentState::Planned;
            exit;
        end;

        if ProdOrderLine."Remaining Qty. (Base)" = 0 then begin
            CurrentState := CurrentState::"Can be finished";
            exit;
        end;

        CurrentState := CurrentState::"Can be produced";
    end;

    local procedure GetCurrentStateForProdOrderCompLine(DocumentLine: Record "S1P-Document Line"; var CurrentState: Enum "S1P-Prod. Order Comp. States")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        WarehouseRequest: Record "Warehouse Request";
        WhseRequestExists: Boolean;
    begin
        ProdOrderComponent.Get(DocumentLine."Record ID");

        if ProdOrderComponent.Status = ProdOrderComponent.Status::Finished then begin
            CurrentState := CurrentState::Consumed;
            exit;
        end;

        if ProdOrderComponent.Status <> ProdOrderComponent.Status::Released then begin
            CurrentState := CurrentState::Planned;
            exit;
        end;

        if ProdOrderComponent."Remaining Qty. (Base)" = 0 then begin
            CurrentState := CurrentState::Consumed;
            exit;
        end;

        CurrentState := CurrentState::"Can be consumed";
    end;
}