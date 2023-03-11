page 50148 "SM9-Sequences"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SM9-State Sequence";

    layout
    {
        area(Content)
        {
            repeater(Sequence)
            {
                field("Entry No."; Rec."Entry No.")
                {

                }
                field("Document Type"; Rec."Document Type")
                {

                }
                field("Document No."; Rec."Document No.")
                {
                    Visible = false;
                }
                field("Operation No."; Rec."Operation No.")
                {

                }
                field("Current State"; Rec."Current State")
                {

                }
                field("Next State"; Rec."Next State")
                {

                }
                field("Event Subscriber"; Rec."Event Subscriber")
                {

                }
            }
        }
    }
}