page 50120 "S1P-Control Panel"
{
    PageType = Card;
    DataCaptionExpression = 'My stockkeeping units';
    SourceTable = User;
    UsageCategory = ReportsAndAnalysis;
    // SourceTableTemporary = true;
    // PromotedActionCategories = 'Navigation';
    Caption = 'My SKU';
    DeleteAllowed = true;
    ModifyAllowed = true;
    InsertAllowed = true;
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

                }
            }
            part(SKUList; "S1P-SKU List")
            {
                ShowFilter = false;
            }
            group(WhereUsed)
            {
                ShowCaption = false;

                part(Documents; "S1P-Document Lines")
                {
                    ShowFilter = false;
                    Caption = 'Documents';
                }
                part(WhseDocuments; "S1P-Warehouse Lines")
                {
                    ShowFilter = false;
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

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}