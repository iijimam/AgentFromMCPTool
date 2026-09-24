Class BTest.Tools Extends %AI.Tool
{

/// Returns existing global variables and a summary of the data they contain as JSON.
/// No arguments.
ClassMethod GetGlobals() As %DynamicObject
{
    set globs=[]
    set glo={}
    set glo.name="Patient"
    set glo.contents="Contains basic patient information"
    do globs.%Push(glo)

    set glo={}
    set glo.name="Prescription" 
    set glo.contents="Contains prescription data"
    do globs.%Push(glo)

    return globs
}

/// Returns the number of patients by gender as JSON.
/// No arguments.
ClassMethod GetGender() As %DynamicObject
{
    set json={}
    set id="",cn=0

    for {
        set id=$ORDER(^PGender("Male",id))
        if id="" quit
        set cn=cn+1
    }

    set json.Male=cn

    set cn=0,id=""

    for {
        set id=$ORDER(^PGender("Female",id))
        if id="" quit
        set cn=$get(cn)+1
    }

    set json.Female=cn

    return json
}

/// Initialization process.
ClassMethod SetGlo() As %DynamicObject
{
    kill ^Patient

    set ^Patient=3
    set ^Patient(1)="Taro Yamada^Male^1980-01-02"
    set ^Patient(2)="Hanako Suzuki^Female^1950-11-21"
    set ^Patient(3)="Takeko Machida^Female^2001-08-11"

    set ^PGender("Male",1)=""
    set ^PGender("Female",2)=""
    set ^PGender("Female",3)=""

    set json={"Message":"Initialization completed"}

    return json
}

}