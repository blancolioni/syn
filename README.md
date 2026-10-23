# syn

Ada source code generation. A program builds a tree of Ada constructs with a factory, and Syn lays it out in GNAT's style and writes the files.

```ada
with Syn.Factory;
with Syn.Units;

procedure Generate is
   F : Syn.Factory.Factory;
   Unit : constant Syn.Node_Access :=
     F.New_Compilation_Unit
       (Context => [F.New_With ("Rose.Objects")],
        Item    =>
          F.New_Package
            (Name        => "Rose.Interfaces.Timer",
             Public_Part =>
               [F.New_Object
                  (Name          => "Timer_Interface",
                   Object_Type   => F.New_Name ("Rose.Objects.Endpoint_Id"),
                   Initial_Value =>
                     F.New_Integer_Literal
                       (16#3D3E_F48A_496A#, Base => 16, Group => 4),
                   Is_Constant   => True)]));
begin
   Syn.Units.Write (Unit, ".");   --  writes rose-interfaces-timer.ads
end Generate;
```

The factory owns every node it creates, and frees them when it is finalised.

See [doc/design.md](doc/design.md) for the design.

## Building and testing

```sh
make          # build the library (alr build)
make test     # build and run the tests, then style-check their output
```

The tests are golden files: each case writes a unit to `tests/output/` and compares it with `tests/expected/`. `tests/check-style.sh` then compiles every expected file with `-gnatyabcefhiklmnoprst -gnaty3 -gnatwe`, so generated code that would fail a strict build fails the tests.
