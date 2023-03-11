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
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        if (StateSequence."Event Subscriber" <> 'ReleasePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        // PurchaseHeader.Get(Document."Record ID");
        // LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction02', '', false, false)]
    local procedure PrepareForReceivePurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseHeader: Record "Purchase Header";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        if (StateSequence."Event Subscriber" <> 'PrepareForReceivePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        // PurchaseHeader.Get(Document."Record ID");
        // LibraryWarehouse.CreateWhseReceiptFromPO(PurchaseHeader);
        // WarehouseReceiptHeader.Get(
        //   LibraryWarehouse.FindWhseReceiptNoBySourceDoc(
        //       DATABASE::"Purchase Line", PurchaseHeader."Document Type".AsInteger(), PurchaseHeader."No."));
        // LibraryWarehouse.PostWhseReceipt(WarehouseReceiptHeader);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SM9-Document Publisher", 'OnAction04', '', false, false)]
    local procedure InvoicePurchaseOrder(var RecordVariant: Variant; StateSequence: Record "SM9-State Sequence"; var IsHandled: Boolean)
    var
        Document: Record "S1P-Document Line";
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        if (StateSequence."Event Subscriber" <> 'InvoicePurchaseOrder') or IsHandled then
            exit;

        Document := RecordVariant;

        // PurchaseHeader.Get(Document."Record ID");
        // LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        Document."Current State" := StateSequence."Next State";
        RecordVariant := Document;
        IsHandled := true;
    end;
}