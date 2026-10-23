with Ada.Characters.Latin_1;
with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Names;
with Syn.Unit_Nodes;

package body Syn.Units is

   procedure Check_Unit (Unit : not null Node_Access);
   --  Raise Constraint_Error if Unit is not a compilation unit.

   ----------------
   -- Check_Unit --
   ----------------

   procedure Check_Unit (Unit : not null Node_Access) is
   begin
      if Unit.all not in Syn.Unit_Nodes.Unit_Node'Class then
         raise Constraint_Error with "not a compilation unit";
      end if;
   end Check_Unit;

   ---------------
   -- File_Name --
   ---------------

   function File_Name (Unit : not null Node_Access) return String is
   begin
      Check_Unit (Unit);
      declare
         Item : Syn.Unit_Nodes.Unit_Node'Class renames
                  Syn.Unit_Nodes.Unit_Node'Class (Unit.all);
      begin
         return Syn.Names.File_Name
           (Ada.Strings.Unbounded.To_String (Item.Unit_Name), Item.Is_Spec);
      end;
   end File_Name;

   -------------
   -- To_Text --
   -------------

   function To_Text
     (Unit  : not null Node_Access;
      Style : Syn.Style.Settings := Syn.Style.Default)
      return String
   is
   begin
      Check_Unit (Unit);
      declare
         Item : Syn.Unit_Nodes.Unit_Node'Class renames
                  Syn.Unit_Nodes.Unit_Node'Class (Unit.all);
      begin
         return Syn.Documents.Render (Item.Document (Style, 0), Style.Width)
           & Ada.Characters.Latin_1.LF;
      end;
   end To_Text;

   -----------
   -- Write --
   -----------

   procedure Write
     (Unit      : not null Node_Access;
      Directory : String;
      Style     : Syn.Style.Settings := Syn.Style.Default)
   is
      use Ada.Streams.Stream_IO;
      Path : constant String :=
               Ada.Directories.Compose (Directory, File_Name (Unit));
      Text : constant String := To_Text (Unit, Style);
      File : File_Type;
   begin
      Create (File, Out_File, Path);
      String'Write (Stream (File), Text);
      Close (File);
   end Write;

end Syn.Units;
