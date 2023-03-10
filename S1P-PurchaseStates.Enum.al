enum 50131 "S1P-Purchase States"
{
    Extensible = true;

    value(0; "Waiting for release") { }
    value(1; "Requires warehouse handling") { }
    value(2; "Can be received") { }
    value(3; "Can be invoiced") { }
}