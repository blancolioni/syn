--  Golden-file tests for Syn. Each case builds a compilation unit and
--  writes it to output/; the test passes if the file matches the one in
--  expected/. Run from the tests directory. check-style.sh then compiles
--  every expected file with GNAT's style checks.

with Ada.Command_Line;
with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Syn;
with Syn.Factory;
with Syn.Units;

procedure Syn_Tests is

   use Syn;

   Output_Directory   : constant String := "output";
   Expected_Directory : constant String := "expected";

   F        : Syn.Factory.Factory;
   Failures : Natural := 0;

   procedure Check (Unit : not null Node_Access);
   --  Write Unit to the output directory and compare it with the expected
   --  file.

   function Read_File (Path : String) return String;

   function Name (Text : String) return not null Node_Access
   is (F.New_Name (Text));

   function Hex (Value : Long_Long_Long_Integer) return not null Node_Access
   is (F.New_Integer_Literal (Value, Base => 16, Group => 4));

   function Body_Tests_Body return not null Node_Access;
   function Body_Tests_Spec return not null Node_Access;
   function Command_Main return not null Node_Access;
   function Command_Spec return not null Node_Access;
   function Layout_Tests return not null Node_Access;
   function Tagged_Tests_Body return not null Node_Access;
   function Tagged_Tests_Spec return not null Node_Access;
   function Timer return not null Node_Access;
   function Timer_Client return not null Node_Access;

   function Call
     (Prefix    : String;
      Arguments : Node_Array)
      return not null Node_Access
   is (F.New_Call (Prefix, Arguments));

   function Call_Statement
     (Prefix    : String;
      Arguments : Node_Array)
      return not null Node_Access
   is (F.New_Call_Statement (F.New_Call (Prefix, Arguments)));

   function Invocation_Parameter return not null Node_Access
   is (F.New_Parameter
         ("Parameters", Name ("Rose.Invocation.Invocation_Record"),
          Mode => In_Out_Mode));

   ---------------------
   -- Body_Tests_Body --
   ---------------------

   function Body_Tests_Body return not null Node_Access is
      Handle   : constant not null Node_Access :=
                   F.New_Procedure ("Handle", [Invocation_Parameter]);
      Endpoint : constant not null Node_Access := Name ("Set_Timer_Endpoint");
      Ident    : constant not null Node_Access := Name ("Identifier");
      Instance : constant not null Node_Access := Name ("Server_Instance");
   begin
      return F.New_Compilation_Unit
        (Context => [F.New_With ("Rose.System_Calls")],
         Item    =>
           F.New_Package_Body
             ("Body_Tests",
              [F.New_Object ("Counter", Name ("Natural"),
                             Initial_Value => F.New_Integer_Literal (0)),
               F.New_Object ("Params",
                             Name ("Rose.Invocation.Invocation_Record"),
                             Is_Aliased => True),
               F.New_Object
                 ("Summary", Name ("String"),
                  Initial_Value =>
                    F.New_Concatenation
                      ([F.New_String_Literal
                          ("Writes each argument to standard output, "),
                        F.New_String_Literal ("separated by single spaces."),
                        Name ("ASCII.LF")]),
                  Is_Constant => True),
               Handle,

               F.New_Expression_Function
                 (F.New_Function ("Count", Name ("Natural")),
                  Name ("Counter")),

               F.New_Subprogram_Body
                 (Handle,
                  Declarations =>
                    [F.New_Use ("Rose.Capabilities"),
                     F.New_Object ("Cap", Name ("Capability")),
                     F.New_Object
                       ("Name",
                        Call ("String",
                              [F.New_Binary
                                 (F.New_Integer_Literal (1), "..",
                                  Call
                                    ("Natural",
                                     [Name ("Parameters.Buffer_Length")]))]),
                        Aspects =>
                          [F.New_Aspect ("Import"),
                           F.New_Aspect
                             ("Address", Name ("Parameters.Buffer_Address"))]),
                     F.New_Object
                       ("Identifier",
                        Name ("Rose.Objects.Capability_Identifier"),
                        Initial_Value => Name ("Parameters.Identifier"),
                        Is_Constant   => True)],
                  Statements   =>
                    [Call_Statement
                       ("Rose.System_Calls.Initialize_Reply",
                        [Name ("Parameters"),
                         Name ("Parameters.Reply_Cap")]),
                     F.New_If
                       (F.New_Binary
                          (Name ("Counter"), "=", F.New_Integer_Literal (0)),
                        Then_Part =>
                          [F.New_If
                             (F.New_Unary
                                ("not",
                                 Call ("Rose.Server.Has_Instance",
                                       [Instance, Endpoint, Ident])),
                              Then_Part =>
                                [Call_Statement
                                   ("Rose.Server.Set_Instance_Cap",
                                    [Instance, Endpoint, Ident,
                                     Call ("Rose.Server.Create_Endpoint",
                                           [Endpoint, Ident])])]),
                           F.New_Assignment
                             (Name ("Cap"),
                              Call ("Rose.Server.Get_Instance_Cap",
                                    [Instance, Endpoint, Ident]))],
                        Else_Part =>
                          [F.New_Assignment
                             (Name ("Cap"), Name ("Null_Capability"))]),
                     Call_Statement
                       ("Rose.System_Calls.Send_Cap",
                        [Name ("Parameters"), Name ("Cap")])]),

               F.New_Subprogram_Body
                 (F.New_Function
                    ("Is_Ready", Name ("Boolean"),
                     [F.New_Parameter ("Item", Name ("Natural"))]),
                  Statements =>
                    [F.New_Block
                       (Declarations =>
                          [F.New_Object
                             ("Twice", Name ("Natural"),
                              Initial_Value =>
                                F.New_Binary
                                  (Name ("Item"), "*",
                                   F.New_Integer_Literal (2)),
                              Is_Constant   => True)],
                        Statements   =>
                          [F.New_Return
                             (F.New_Binary
                                (F.New_Binary
                                   (Name ("Twice"), ">",
                                    F.New_Integer_Literal (4)),
                                 "and then",
                                 F.New_Unary
                                   ("not",
                                    F.New_Binary
                                      (Name ("Counter"), "=",
                                       Name ("Item")))))])]),

               F.New_Subprogram_Body
                 (F.New_Procedure
                    ("Register",
                     [F.New_Parameter
                        ("Context", Name ("Rose.Server.Server_Context"),
                         Mode => In_Out_Mode)]),
                  Statements =>
                    [Call_Statement
                       ("Rose.Server.Register_Handler",
                        [Name ("Context"),
                         Name ("Set_Timer_Endpoint"),
                         F.New_Attribute (Name ("Handle"), "Access")]),
                     Call_Statement
                       ("Rose.Core.Echo",
                        [F.New_Named
                           ("New_Line",
                            Call ("Rose.Command_Line.Launch.Boolean_Argument",
                                  [Name ("Call"), F.New_Integer_Literal (0)])),
                         F.New_Named ("Arguments", Name ("Arguments"))]),
                     F.New_For_Of_Loop
                       ("Cap", Name ("Caps"),
                        [Call_Statement
                           ("Rose.System_Calls.Send_Cap",
                            [Name ("Params"), Name ("Cap")])]),
                     F.New_Assignment
                       (Name ("Counter"),
                        F.New_Binary
                          (Name ("Counter"), "+",
                           F.New_Integer_Literal (1)))]),

               F.New_Subprogram_Body (F.New_Procedure ("Reset"))]));
   end Body_Tests_Body;

   ---------------------
   -- Body_Tests_Spec --
   ---------------------

   function Body_Tests_Spec return not null Node_Access is
   begin
      return F.New_Compilation_Unit
        (Context =>
           [F.New_With ("Rose.Capabilities"),
            F.New_With ("Rose.Invocation"),
            F.New_With ("Rose.Objects"),
            F.New_With ("Rose.Server"),
            F.New_With ("Rose.Words")],
         Item    =>
           F.New_Package
             ("Body_Tests",
              [F.New_Range_Type
                 ("Block_Size_Type",
                  F.New_Integer_Literal (0), F.New_Integer_Literal (4096)),
               F.New_Derived_Type
                 ("Block_Address_Type", Name ("Rose.Words.Word_64")),
               F.New_Access_Procedure_Type
                 ("Callback", [F.New_Parameter ("Code", Name ("Natural"))]),
               F.New_Access_Function_Type
                 ("Set_Timer_Handler",
                  Result_Type => Name ("Rose.Capabilities.Capability"),
                  Parameters  =>
                    [F.New_Parameter
                       ("Id", Name ("Rose.Objects.Capability_Identifier")),
                     F.New_Parameter
                       ("Milliseconds", Name ("Rose.Words.Word")),
                     F.New_Parameter
                       ("Cap", Name ("Rose.Capabilities.Capability"))]),
               F.New_Object
                 ("Set_Timer_Endpoint", Name ("Rose.Objects.Endpoint_Id"),
                  Initial_Value => Hex (16#D25E_5101_0B66#),
                  Is_Constant   => True),
               F.New_Object
                 ("Server_Instance", Name ("Rose.Server.Server_Instance")),
               F.New_Function ("Count", Name ("Natural")),
               F.New_Function
                 ("Is_Ready", Name ("Boolean"),
                  [F.New_Parameter ("Item", Name ("Natural"))]),
               F.New_Procedure
                 ("Register",
                  [F.New_Parameter
                     ("Context", Name ("Rose.Server.Server_Context"),
                      Mode => In_Out_Mode)]),
               F.New_Procedure ("Reset")]));
   end Body_Tests_Spec;

   -----------
   -- Check --
   -----------

   procedure Check (Unit : not null Node_Access) is
      File_Name : constant String := Syn.Units.File_Name (Unit);
      Expected  : constant String :=
                    Ada.Directories.Compose (Expected_Directory, File_Name);
   begin
      Syn.Units.Write (Unit, Output_Directory);

      if not Ada.Directories.Exists (Expected) then
         Ada.Text_IO.Put_Line ("NEW  " & File_Name);
         Failures := Failures + 1;
      elsif Read_File (Expected) = Syn.Units.To_Text (Unit) then
         Ada.Text_IO.Put_Line ("PASS " & File_Name);
      else
         Ada.Text_IO.Put_Line ("FAIL " & File_Name);
         Failures := Failures + 1;
      end if;
   end Check;

   ------------------
   -- Command_Main --
   ------------------

   function Command_Main return not null Node_Access is
      Launch_Call : constant not null Node_Access := Name ("Call");
   begin
      return F.New_Compilation_Unit
        (Context =>
           [F.New_With ("Rose.Command_Line.Launch"),
            F.New_With ("Rose.Core.Echo")],
         Item    =>
           F.New_Subprogram_Body
             (Specification => F.New_Procedure ("Rose.Core.Echo_Main"),
              Declarations  =>
                [F.New_Object
                   ("Call", Name ("Rose.Command_Line.Launch.Launch_Call"))],
              Statements    =>
                [Call_Statement
                   ("Rose.Command_Line.Launch.Receive", [Launch_Call]),
                 Call_Statement
                   ("Rose.Core.Echo",
                    [F.New_Named
                       ("New_Line",
                        Call ("Rose.Command_Line.Launch.Boolean_Argument",
                              [Launch_Call, F.New_Integer_Literal (0)]))]),
                 Call_Statement
                   ("Rose.Command_Line.Launch.Complete", [Launch_Call])]));
   end Command_Main;

   ------------------
   -- Command_Spec --
   ------------------

   function Command_Spec return not null Node_Access is
   begin
      return F.New_Compilation_Unit
        (Context => [F.New_With ("Rose.Command_Line")],
         Item    =>
           F.New_Procedure
             ("Rose.Core.Echo",
              [F.New_Parameter
                 ("New_Line", Name ("Boolean"), Default => Name ("True")),
               F.New_Parameter
                 ("Arguments", Name ("Rose.Command_Line.String_List"))]));
   end Command_Spec;

   ------------------
   -- Layout_Tests --
   ------------------

   function Layout_Tests return not null Node_Access is
   begin
      return F.New_Compilation_Unit
        (F.New_Package
           (Name        => "Layout_Tests",
            Public_Part =>
              [F.New_Enumeration_Type
                 ("Short_Kind", [Name ("A"), Name ("B"), Name ("C")]),
               F.New_Enumeration_Type
                 ("Capability_Type",
                  [Name ("Null_Cap"), Name ("Page_Object_Cap"),
                   Name ("Meta_Cap"), Name ("Process_Cap"),
                   Name ("Endpoint_Cap"), Name ("Receive_Cap"),
                   Name ("Interrupt_Cap"), Name ("Kernel_Cap")]),
               F.New_Object
                 (Name          => "Greeting",
                  Object_Type   => Name ("String"),
                  Initial_Value =>
                    F.New_String_Literal ("Say ""hello"""),
                  Is_Constant   => True),
               F.New_Object
                 (Name          => "Mask",
                  Initial_Value =>
                    F.New_Integer_Literal
                      (16#F0F0#, Base => 2, Group => 4),
                  Is_Constant   => True),
               F.New_Object
                 (Name          => "Offset",
                  Object_Type   => Name ("Integer"),
                  Initial_Value => F.New_Integer_Literal (-42),
                  Is_Constant   => True),
               F.New_Object
                 (Name        => "Counter",
                  Object_Type => Name ("Natural")),
               F.New_Raw
                 ("--  Raw text is written as it is,"
                  & ASCII.LF & "--  on as many lines as it has."),
               F.New_Record_Type ("Empty"),
               F.New_Procedure ("Reset"),
               F.New_Function ("Count", Name ("Natural")),
               F.New_Procedure
                 ("Configure",
                  [F.New_Parameter
                     ("Device_Name", Name ("String")),
                   F.New_Parameter
                     ("Block_Size", Name ("Positive"),
                      Default => F.New_Integer_Literal (512)),
                   F.New_Parameter
                     ("Device", Name ("Device_Type"),
                      Mode => In_Out_Mode)]),
               F.New_Function
                 ("Home_Directory",
                  Name ("Rose.Interfaces.Writable_Directory.Client"
                        & ".Writable_Directory_Client")),
               F.New_Object
                 (Name        => "Home",
                  Object_Type =>
                    Name ("Rose.Interfaces.Writable_Directory.Client"
                          & ".Writable_Directory_Client"))]));
   end Layout_Tests;

   ---------------
   -- Read_File --
   ---------------

   function Read_File (Path : String) return String is
      use Ada.Streams.Stream_IO;
      File : File_Type;
   begin
      Open (File, In_File, Path);
      declare
         Result : String (1 .. Natural (Size (File)));
      begin
         String'Read (Stream (File), Result);
         Close (File);
         return Result;
      end;
   end Read_File;

   -----------------------
   -- Tagged_Tests_Body --
   -----------------------

   function Tagged_Tests_Body return not null Node_Access is
      Square_Item : constant not null Node_Access :=
                      F.New_Parameter ("Item", Name ("Square"));
   begin
      return F.New_Compilation_Unit
        (Context => [F.New_With ("Rose.Interfaces.Objects")],
         Item    =>
           F.New_Package_Body
             ("Tagged_Tests",
              [F.New_Subprogram_Body
                 (F.New_Function
                    ("Area", Name ("Natural"), [Square_Item],
                     Indicator => Is_Overriding),
                  Statements =>
                    [F.New_If
                       (F.New_Binary
                          (Name ("Item.Side"), "=",
                           F.New_Integer_Literal (0)),
                        Then_Part =>
                          [F.New_Raise (Name ("Constraint_Error"))]),
                     F.New_Return
                       (F.New_Binary
                          (Name ("Item.Side"), "*", Name ("Item.Side")))]),

               F.New_Subprogram_Body
                 (F.New_Procedure
                    ("Check", [F.New_Parameter ("Value", Name ("Natural"))]),
                  Statements =>
                    [F.New_If
                       (F.New_Binary
                          (Name ("Value"), ">", F.New_Integer_Literal (100)),
                        Then_Part =>
                          [F.New_Raise
                             (Name ("Rose.Interfaces.Objects"
                                    & ".Invocation_Error"),
                              F.New_String_Literal
                                ("Stream_Writer.Write: the server replied "
                                 & "with an error"))])]),

               F.New_Expression_Function
                 (F.New_Function
                    ("Perimeter", Name ("Natural"), [Square_Item],
                     Indicator => Is_Not_Overriding),
                  F.New_Binary
                    (F.New_Integer_Literal (4), "*", Name ("Item.Side")))]));
   end Tagged_Tests_Body;

   -----------------------
   -- Tagged_Tests_Spec --
   -----------------------

   function Tagged_Tests_Spec return not null Node_Access is
      Cap        : constant not null Node_Access :=
                     Name ("Rose.Capabilities.Capability");
      Null_Cap   : constant not null Node_Access :=
                     Name ("Rose.Capabilities.Null_Capability");
      Writer     : constant not null Node_Access :=
                     Name ("Rose.Interfaces.Stream_Writer"
                           & ".Stream_Writer_Object");
      Restorable : constant not null Node_Access :=
                     Name ("Rose.Interfaces.Restorable.Restorable_Object");
      Client     : constant String := "Stream_Writer_Client";
   begin
      return F.New_Compilation_Unit
        (Context =>
           [F.New_With ("Rose.Capabilities"),
            F.New_With ("Rose.Interfaces.Restorable"),
            F.New_With ("Rose.Interfaces.Stream_Writer"),
            F.New_With ("Rose.Objects"),
            F.New_With ("Rose.Interfaces.File", Is_Limited => True)],
         Item    =>
           F.New_Package
             (Name         => "Tagged_Tests",
              Public_Part  =>
                [F.New_Interface_Type ("Shape", Is_Limited => True),
                 F.New_Function
                   ("Area", Name ("Natural"),
                    [F.New_Parameter ("Item", Name ("Shape"))],
                    Is_Abstract => True),
                 F.New_Procedure
                   ("Scale",
                    [F.New_Parameter
                       ("Item", Name ("Shape"), Mode => In_Out_Mode),
                     F.New_Parameter ("Factor", Name ("Positive"))],
                    Is_Abstract => True),
                 F.New_Procedure
                   ("Listen",
                    [F.New_Parameter
                       ("Item", Name ("Shape"), Mode => In_Out_Mode),
                     F.New_Parameter
                       ("Listener",
                        Name ("Rose.Interfaces.Event_Listener"
                              & ".Event_Listener_Object'Class"),
                        Mode => In_Out_Mode)],
                    Is_Abstract => True),
                 F.New_Function
                   ("Window_Cap", Cap,
                    [F.New_Parameter
                       ("Item", Name ("Shape"), Mode => In_Out_Mode),
                     F.New_Parameter
                       ("Window", Name ("Rose.Interfaces.Window.Window_Object"
                                        & "'Class"),
                        Mode => In_Out_Mode)],
                    Is_Abstract => True),
                 F.New_Interface_Type
                   ("Labelled", [Name ("Shape")], Is_Limited => True),
                 F.New_Interface_Type
                   ("Stream_Writer_Interface", [Writer, Restorable],
                    Is_Limited => True),
                 F.New_Private_Extension ("Square", Name ("Shape")),
                 F.New_Private_Extension
                   (Client, Writer, [Restorable], Is_Limited => True),
                 F.New_Function
                   ("Area", Name ("Natural"),
                    [F.New_Parameter ("Item", Name ("Square"))],
                    Indicator => Is_Overriding),
                 F.New_Function
                   ("Perimeter", Name ("Natural"),
                    [F.New_Parameter ("Item", Name ("Square"))],
                    Indicator => Is_Not_Overriding),
                 F.New_Procedure
                   ("Check", [F.New_Parameter ("Value", Name ("Natural"))]),
                 F.New_Access_Type
                   ("Shape_Access", Name ("Shape'Class"), Is_All => True),
                 F.New_Access_Type
                   ("Shape_Reference", Name ("Shape'Class"),
                    Is_Constant => True),
                 F.New_Access_Type ("Square_Pointer", Name ("Square")),
                 F.New_Array_Type
                   ("Shape_Table",
                    F.New_Binary
                      (F.New_Integer_Literal (0), "..",
                       F.New_Integer_Literal (15)),
                    Name ("Shape_Access")),
                 F.New_Array_Type
                   ("Writer_Table",
                    Name ("Rose.Objects.Capability_Identifier"),
                    Name ("Rose.Interfaces.Stream_Writer.Stream_Writer_Object"
                          & "_Access"))],
              Private_Part =>
                [F.New_Record_Extension
                   ("Square", Name ("Shape"),
                    Components =>
                      [F.New_Component
                         ("Side", Name ("Natural"),
                          F.New_Integer_Literal (0))]),
                 F.New_Record_Extension
                   (Client, Writer, [Restorable],
                    Components =>
                      [F.New_Component ("Interface_Cap", Cap, Null_Cap),
                       F.New_Component ("Write", Cap, Null_Cap)],
                    Is_Limited => True),
                 F.New_Record_Extension ("Marker", Name ("Shape"))]));
   end Tagged_Tests_Spec;

   -----------
   -- Timer --
   -----------

   function Timer return not null Node_Access is
   begin
      return F.New_Compilation_Unit
        (Context => [F.New_With ("Rose.Objects")],
         Item    =>
           F.New_Package
             (Name        => "Rose.Interfaces.Timer",
              Public_Part =>
                [F.New_Object
                   (Name          => "Max_Timers",
                    Initial_Value => F.New_Integer_Literal (64),
                    Is_Constant   => True),
                 F.New_Object
                   (Name          => "Timer_Interface",
                    Object_Type   => Name ("Rose.Objects.Endpoint_Id"),
                    Initial_Value => Hex (16#3D3E_F48A_496A#),
                    Is_Constant   => True),
                 F.New_Object
                   (Name          => "Set_Timer_Endpoint",
                    Object_Type   => Name ("Rose.Objects.Endpoint_Id"),
                    Initial_Value => Hex (16#D25E_5101_0B66#),
                    Is_Constant   => True)]));
   end Timer;

   ------------------
   -- Timer_Client --
   ------------------

   function Timer_Client return not null Node_Access is
      Client : constant not null Node_Access := Name ("Timer_Client");
      Cap    : constant not null Node_Access :=
                 Name ("Rose.Capabilities.Capability");
   begin
      return F.New_Compilation_Unit
        (Context =>
           [F.New_With ("Rose.Capabilities"),
            F.New_With ("Rose.Interfaces.Cap.Client"),
            F.New_With ("Rose.Invocation"),
            F.New_With ("Rose.Words")],
         Item    =>
           F.New_Package
             (Name         => "Rose.Interfaces.Timer.Client",
              Public_Part  =>
                [F.New_Private_Type ("Timer_Client"),
                 F.New_Procedure
                   ("Open",
                    [F.New_Parameter ("Client", Client, Mode => Out_Mode),
                     F.New_Parameter ("Interface_Cap", Cap)]),
                 F.New_Procedure
                   ("Close",
                    [F.New_Parameter
                       ("Client", Client, Mode => In_Out_Mode)]),
                 F.New_Function
                   ("Set_Timer",
                    Result_Type =>
                      Name ("Rose.Interfaces.Cap.Client.Cap_Client"),
                    Parameters  =>
                      [F.New_Parameter ("Item", Client),
                       F.New_Parameter
                         ("Milliseconds", Name ("Rose.Words.Word")),
                       F.New_Parameter ("Cap", Cap)]),
                 F.New_Function ("Has_Error", Name ("Boolean")),
                 F.New_Function
                   ("Get_Last_Error",
                    Name ("Rose.Invocation.Invocation_Error"))],
              Private_Part =>
                [F.New_Record_Type
                   ("Timer_Client",
                    [F.New_Component
                       ("Is_Open", Name ("Boolean"),
                        Default => Name ("False")),
                     F.New_Component
                       ("Interface_Cap", Cap,
                        Default => F.New_Integer_Literal (0)),
                     F.New_Component
                       ("Set_Timer", Cap,
                        Default => F.New_Integer_Literal (0))])]));
   end Timer_Client;

begin
   if not Ada.Directories.Exists (Output_Directory) then
      Ada.Directories.Create_Directory (Output_Directory);
   end if;

   Check (Timer);
   Check (Timer_Client);
   Check (Layout_Tests);
   Check (Body_Tests_Spec);
   Check (Body_Tests_Body);
   Check (Command_Spec);
   Check (Command_Main);
   Check (Tagged_Tests_Spec);
   Check (Tagged_Tests_Body);

   if Failures > 0 then
      Ada.Text_IO.Put_Line
        (Natural'Image (Failures) & " failed; compare output/ with expected/");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Syn_Tests;
