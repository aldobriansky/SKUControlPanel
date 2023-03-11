table 50125 "S1P-State"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Ordinal; Integer)
        {

        }
        field(2; Name; Text[50])
        {

        }
    }

    keys
    {
        key(Key1; Ordinal)
        {
            Clustered = true;
        }
    }
}