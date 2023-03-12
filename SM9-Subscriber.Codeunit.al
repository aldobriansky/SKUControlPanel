codeunit 50100 "SM9-Subscriber"
{

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction01', '', false, false)]
    local procedure ReleasePurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        if (StateSequence."Event Subscriber" <> 'ReleasePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        PurchaseLine.Get(Document."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then
            exit;

        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction02', '', false, false)]
    local procedure CheckWarehouseForPurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        WarehouseRequest: Record "Warehouse Request";
        WhseRequestExists: Boolean;
    begin
        if (StateSequence."Event Subscriber" <> 'CheckWarehouseForPurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        PurchaseLine.Get(Document."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        WarehouseRequest.SetSourceFilter(Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.");
        WarehouseRequest.SetRange("Location Code", PurchaseLine."Location Code");
        WhseRequestExists := not WarehouseRequest.IsEmpty();

        if (PurchaseHeader.Status = PurchaseHeader.Status::Released) and WhseRequestExists then
            exit;

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction03', '', false, false)]
    local procedure ReceivePurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        if (StateSequence."Event Subscriber" <> 'ReceivePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        PurchaseLine.Get(Document."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        if PurchaseLine."Quantity Received" = PurchaseLine.Quantity then
            exit;

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction04', '', false, false)]
    local procedure InvoicePurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        if (StateSequence."Event Subscriber" <> 'InvoicePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        PurchaseLine.Get(Document."Record ID");
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        if PurchaseLine."Quantity Invoiced" = PurchaseLine.Quantity then
            exit;

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;
}