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

   function Layout_Tests return not null Node_Access;
   function Timer return not null Node_Access;
   function Timer_Client return not null Node_Access;

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
                      Mode => In_Out_Mode)])]));
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

   if Failures > 0 then
      Ada.Text_IO.Put_Line
        (Natural'Image (Failures) & " failed; compare output/ with expected/");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Syn_Tests;
