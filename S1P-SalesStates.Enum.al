enum 50132 "S1P-Sales States"
{
    Extensible = true;

    value(0; "Waiting for release") { }
    value(1; "Requires warehouse handling") { }
    value(2; "Can be shipped") { }
    value(3; "Can be invoiced") { }
    value(4; "Invoiced") { }
}