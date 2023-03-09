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
    // AboutTitle = 'About SKU main page.';
    // AboutText = 'Follow and manage your SKU.';

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
                ShowFilter = false;
                UpdatePropagation = Both;
            }
            group(WhereUsed)
            {
                ShowCaption = false;

                part(Documents; "S1P-Document Lines")
                {
                    ShowFilter = false;
                    UpdatePropagation = Both;
                    Caption = 'Documents';
                }
                part(WhseDocuments; "S1P-Warehouse Lines")
                {
                    ShowFilter = false;
                    UpdatePropagation = Both;
                    Caption = 'Warehouse';
                }
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

    var
        myInt: Integer;

    local procedure UpdateParts()
    var
        myInt: Integer;
    begin
        CurrPage.Documents.Page.GetDocuments();
        // CurrPage.WhseDocuments.Page.GetWhseDocuments();
        CurrPage.Update(false);
    end;
}