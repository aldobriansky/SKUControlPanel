page 50120 "S1P-Control Panel"
{
    PageType = Card;
    DataCaptionExpression = 'My stockkeeping units';
    SourceTable = User;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'My SKU';
    DeleteAllowed = false;
    ModifyAllowed = true;
    InsertAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Description)
            {
                Caption = 'General';

                field("User Name"; Rec."User Name")
                {
                    Editable = false;
                }
            }
            part(SKUList; "S1P-SKU List")
            {
                UpdatePropagation = Both;
            }
            part(Documents; "S1P-Document Lines")
            {
                UpdatePropagation = Both;
                Caption = 'Documents';
            }
            part(WhseDocuments; "S1P-Whse. Document Lines")
            {
                UpdatePropagation = Both;
                Caption = 'Warehouse';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {

                Image = Refresh;

                trigger OnAction()
                begin
                    UpdateParts();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh) { }
        }
    }

    local procedure UpdateParts()
    begin
        CurrPage.SKUList.Page.RefreshValues();
        CurrPage.Documents.Page.GetDocuments();
        CurrPage.WhseDocuments.Page.GetWarehouseDocuments();
        CurrPage.Update(false);
    end;
}