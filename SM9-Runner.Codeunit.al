codeunit 50111 "SM9-Runner"
{

    TableNo = "S1P-Document Line";

    trigger OnRun()
    var
        Document: Record "S1P-Document Line";
        Publisher: Codeunit "SM9-Document Publisher";
        Subscriber: Codeunit "SM9-Subscriber";
    begin
        BindSubscription(Subscriber);

        Document.Copy(Rec);
        if Publisher.Run(Document) then;
        Document.Modify();
        Commit();
        Rec.Copy(Document);

        UnbindSubscription(Subscriber);
    end;

    procedure CreateStateSequenceForPurchase()
    var
        StateSequence: Record "SM9-State Sequence";
    begin
        StateSequence.SetRange("Document Type", "Item Ledger Entry Type"::Purchase.AsInteger());
        StateSequence.DeleteAll();

        StateSequence."Entry No." := 1;
        StateSequence."Document Type" := "Item Ledger Entry Type"::Purchase.AsInteger();
        StateSequence."Document No." := '';
        StateSequence."Operation No." := 10;
        StateSequence."Current State" := 'Waiting for release';
        StateSequence."Next State" := 'Requires warehouse handling';
        StateSequence."Event Subscriber" := 'ReleasePurchaseOrder';
        StateSequence.Insert();

        StateSequence."Entry No." := 2;
        StateSequence."Document Type" := "Item Ledger Entry Type"::Purchase.AsInteger();
        StateSequence."Document No." := '';
        StateSequence."Operation No." := 20;
        StateSequence."Current State" := 'Requires warehouse handling';
        StateSequence."Next State" := 'Can be received';
        StateSequence."Event Subscriber" := 'CheckWarehouseForPurchaseOrder';
        StateSequence.Insert();

        StateSequence."Entry No." := 3;
        StateSequence."Document Type" := "Item Ledger Entry Type"::Purchase.AsInteger();
        StateSequence."Document No." := '';
        StateSequence."Operation No." := 30;
        StateSequence."Current State" := 'Can be received';
        StateSequence."Next State" := 'Can be invoiced';
        StateSequence."Event Subscriber" := 'ReceivePurchaseOrder';
        StateSequence.Insert();

        StateSequence."Entry No." := 4;
        StateSequence."Document Type" := "Item Ledger Entry Type"::Purchase.AsInteger();
        StateSequence."Document No." := '';
        StateSequence."Operation No." := 40;
        StateSequence."Current State" := 'Can be invoiced';
        StateSequence."Next State" := 'Invoiced';
        StateSequence."Event Subscriber" := 'InvoicePurchaseOrder';
        StateSequence.Insert();
    end;
}