with Ada.Characters.Handling;
with Ada.Strings.Fixed;

with Syn.Statements;

package body Syn is

   Right_Margin : constant := 78;

   ----------------
   -- Add_Aspect --
   ----------------

   procedure Add_Aspect
     (D     : in out Declaration'Class;
      Name  : in String;
      Value : in Expression'Class)
   is
   begin
      D.Aspects.Append
        ((new String'(Name),
         new Expression'Class'(Value)));
   end Add_Aspect;

   ----------------
   -- Add_Aspect --
   ----------------

   procedure Add_Aspect
     (D     : in out Declaration'Class;
      Name  : in String;
      Value : in String)
   is
   begin
      D.Aspects.Append
        ((new String'(Name),
         new Expression'Class'(Object (Value))));
   end Add_Aspect;

   ----------------
   -- Add_Parent --
   ----------------

   procedure Add_Parent (To_Interface : in out Interface_Type_Definition;
                         Name         : in     String)
   is
   begin
      To_Interface.Parents.Append (Name);
   end Add_Parent;

   ------------
   -- Append --
   ------------

   procedure Append (To : in out Statement_Sequencer'Class;
                     S  : in     String)
   is
   begin
      To.Append
        (Syn.Statements.New_Procedure_Call_Statement (S));
   end Append;

   -------------------
   -- Append_Pragma --
   -------------------

   procedure Append_Pragma
     (To       : in out Statement_Sequencer'Class;
      Name     : String;
      Argument : String)
   is
   begin
      To.Append (Syn.Statements.Pragma_Statement (Name, Argument));
   end Append_Pragma;

   ------------------------
   -- Class_Wide_Subtype --
   ------------------------

   function Class_Wide_Subtype (Name : String)
                                return Subtype_Indication'Class
   is
      Result : Subtype_Indication'Class :=
                 Named_Subtype (Name);
   begin
      Result.Class_Wide := True;
      return Result;
   end Class_Wide_Subtype;

   -----------------------
   -- Constrained_Array --
   -----------------------

   function Constrained_Array
     (Name         : String;
      Low, High    : Expression'Class)
      return Expression'Class
   is
      Result : constant Literal_Expression :=
                 (new String'(Name), False,
                  new Expression'Class'(Low),
                  new Expression'Class'(High));
   begin
      return Result;
   end Constrained_Array;

   -------------------------
   -- Constrained_Subtype --
   -------------------------

   function Constrained_Subtype
     (Name      : String;
      Low, High : Expression'Class)
      return Subtype_Indication'Class
   is
      Result : constant Subtype_Indication :=
                 (new String'(Name), False, True,
                  new Expression'Class'(Low),
                  new Expression'Class'(High));
   begin
      return Result;
   end Constrained_Subtype;

   ------------------
   -- Current_Line --
   ------------------

   function Current_Line return Expression'Class is
   begin
      return Result : Current_Line_Expression do
         null;
      end return;
   end Current_Line;

   --------------
   -- Has_Body --
   --------------

   function Has_Body
     (Item : Declaration)
      return Boolean
   is
      pragma Unreferenced (Item);
   begin
      return False;
   end Has_Body;

   -------------------
   -- Has_Body_Spec --
   -------------------

   function Has_Body_Spec
     (Item : Declaration)
      return Boolean
   is
   begin
      return Item.Body_Only;
   end Has_Body_Spec;

   ----------------
   -- Has_Output --
   ----------------

   function Has_Output
     (Item : Declaration;
      Writer : Writer_Interface'Class)
     return Boolean
   is
   begin
      case Writer.Context is
         when Compilation_Unit =>
            return False;
         when Package_Spec =>
            return not Item.Body_Only
              and then not Item.Private_Spec;
         when Package_Private =>
            return Declaration'Class (Item).Has_Private_Part
              or else Item.Private_Spec;
         when Package_Body =>
            return Declaration'Class (Item).Has_Body;
         when Package_Body_Specs =>
            return Declaration'Class (Item).Has_Body_Spec;
         when Block =>
            return True;
      end case;
   end Has_Output;

   ----------------------
   -- Has_Private_Part --
   ----------------------

   function Has_Private_Part
     (Item : Declaration)
      return Boolean
   is
      pragma Unreferenced (Item);
   begin
      return False;
   end Has_Private_Part;

   -----------------
   -- Has_Variant --
   -----------------

   function Has_Variant (Item : Type_Definition) return Boolean is
      pragma Unreferenced (Item);
   begin
      return False;
   end Has_Variant;

   ------------
   -- Indent --
   ------------

   procedure Indent (Writer : in out Writer_Interface'Class) is
   begin
      Writer.Indent (Writer.Col - 1);
   end Indent;

   ---------------
   -- Is_Tagged --
   ---------------

   function Is_Tagged (Item : Type_Definition) return Boolean is
      pragma Unreferenced (Item);
   begin
      return False;
   end Is_Tagged;

   -------------
   -- Literal --
   -------------

   function Literal (Value : Integer) return Expression'Class is
      Image : constant String :=
                Ada.Strings.Fixed.Trim (Integer'Image (Value),
                                        Ada.Strings.Left);
   begin
      return Result : Literal_Expression do
         Result.Literal := new String'(Image);
      end return;
   end Literal;

   -------------
   -- Literal --
   -------------

   function Literal (Value : String) return Expression'Class is
   begin
      return Result : Literal_Expression do
         Result.Literal := new String'('"' & Value & '"');
      end return;
   end Literal;

   -------------
   -- Literal --
   -------------

   function Literal (Value : Boolean) return Expression'Class is
   begin
      return Result : Literal_Expression do
         Result.Literal := new String'((if Value then "True" else "False"));
      end return;
   end Literal;

   -------------------
   -- Named_Subtype --
   -------------------

   function Named_Subtype (Name : String)
                          return Subtype_Indication'Class
   is
   begin
      return Result : Subtype_Indication do
         Result.Base_Type := new String'(Name);
      end return;
   end Named_Subtype;

   ----------------------
   -- New_Access_Type --
   ----------------------

   function New_Access_Type
     (Access_To : String;
      Access_All : Boolean)
      return Access_Type_Definition
   is
   begin
      return Result : Access_Type_Definition do
         Result.Access_To_Type := new String'(Access_To);
         Result.Access_All := Access_All;
      end return;
   end New_Access_Type;

   ----------------------
   -- New_Derived_Type --
   ----------------------

   function New_Derived_Type
     (Derived_From : String)
      return Derived_Type_Definition
   is
   begin
      return Result : Derived_Type_Definition do
         Result.Base_Type := new String'(Derived_From);
      end return;
   end New_Derived_Type;

   -----------------
   -- New_Literal --
   -----------------

   procedure New_Literal
     (Item    : in out Enumeration_Type_Definition;
      Literal : in String)
   is
   begin
      Item.Literals.Append (Literal);
   end New_Literal;

   ------------
   -- Object --
   ------------

   function Object
     (Name         : String;
      Dereferenced : Boolean := False)
      return Expression'Class
   is
   begin
      return Result : Literal_Expression do
         Result.Literal := new String'(Name);
         Result.Dereferenced := Dereferenced;
      end return;
   end Object;

   --------------
   -- Pop_Flag --
   --------------

   procedure Pop_Flag
     (Writer : in out Writer_Interface'Class;
      Flag   : Write_Flag)
   is
      pragma Unreferenced (Flag);
   begin
      Writer.Flag_Top := Writer.Flag_Top - 1;
   end Pop_Flag;

   ------------------------
   -- Pseudo_Declaration --
   ------------------------

   function Pseudo_Declaration
     (Item : Declaration)
     return Boolean
   is
      pragma Unreferenced (Item);
   begin
      return False;
   end Pseudo_Declaration;

   ---------------
   -- Push_Flag --
   ---------------

   procedure Push_Flag
     (Writer : in out Writer_Interface'Class;
      Flag   : Write_Flag;
      Value  : Boolean)
   is
   begin
      Writer.Flag_Top := Writer.Flag_Top + 1;
      Writer.Flags (Writer.Flag_Top) (Flag) := Value;
   end Push_Flag;

   --------------
   -- Put_Line --
   --------------

   procedure Put_Line (Writer : in out Writer_Interface'Class;
                       Text   : in     String)
   is
   begin
      Writer.Put (Text);
      Writer.New_Line;
   end Put_Line;

   ---------------
   -- Set_Label --
   ---------------

   procedure Set_Label (Item    : in out Statement;
                        Label   : in     String)
   is
   begin
      Item.Label := new String'(Label);
   end Set_Label;

   -----------------
   -- Set_Limited --
   -----------------

   procedure Set_Limited (Item  : in out Type_Definition'Class) is
   begin
      Item.Is_Limited := True;
   end Set_Limited;

   ----------------------
   -- Set_Private_Spec --
   ----------------------

   procedure Set_Private_Spec (D : in out Declaration) is
   begin
      D.Private_Spec := True;
   end Set_Private_Spec;

   -----------------
   -- To_Ada_Name --
   -----------------

   function To_Ada_Name (Text : String) return String is
      use Ada.Characters.Handling;
      Result : String := Text;
      Capital : Boolean := True;
   begin
      for I in Result'Range loop
         if Capital then
            Result (I) := To_Upper (Result (I));
            Capital := False;
         elsif Result (I) = '_'
           or else Result (I) = '.'
         then
            if I > Result'Last - 3
              or else Result (I .. I + 3) /= ".all"
            then
               Capital := True;
            end if;
         end if;
      end loop;
      return Result;
   end To_Ada_Name;

   -----------------
   -- To_Ada_Name --
   -----------------

   function To_Ada_Name (Text : String_Access) return String is
   begin
      return To_Ada_Name (Text.all);
   end To_Ada_Name;

   ------------------
   -- To_File_Name --
   ------------------

   function To_File_Name (Text : String_Access;
                          Spec : Boolean)
                         return String is
      use Ada.Characters.Handling;
      Result  : String := Text.all;
   begin
      for I in Result'Range loop
         if Result (I) = '.' then
            Result (I) := '-';
         elsif Is_Upper (Result (I)) then
            Result (I) := To_Lower (Result (I));
         end if;
      end loop;
      return Result & (if Spec then ".ads" else ".adb");
   end To_File_Name;

   -----------
   -- Value --
   -----------

   function Value (Image : String) return Expression'Class is
   begin
      return Result : Literal_Expression do
         Result.Literal := new String'(Image);
      end return;
   end Value;

   ---------------------
   -- Variant_Default --
   ---------------------

   function Variant_Default (Item : Type_Definition) return String is
      pragma Unreferenced (Item);
   begin
      return "";
   end Variant_Default;

   ------------------
   -- Variant_Name --
   ------------------

   function Variant_Name (Item : Type_Definition) return String is
      pragma Unreferenced (Item);
   begin
      return "";
   end Variant_Name;

   ------------------
   -- Variant_Type --
   ------------------

   function Variant_Type (Item : Type_Definition) return String is
      pragma Unreferenced (Item);
   begin
      return "";
   end Variant_Type;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (Item        : Access_Type_Definition;
      Writer      : in out Writer_Interface'Class)
   is
   begin
      Writer.Put ("access "
                  & (if Item.Access_All then "all " else "")
                  & To_Ada_Name (Item.Access_To_Type));
   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (Item        : Derived_Type_Definition;
      Writer      : in out Writer_Interface'Class)
   is
   begin
      Writer.Put ("new " & To_Ada_Name (Item.Base_Type));
   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write (Item        : Literal_Expression;
                    Writer      : in out Writer_Interface'Class)
   is
   begin
      Writer.Put (Item.Literal.all);
      if Item.Dereferenced then
         Writer.Put (".all");
      end if;
      if Item.Low /= null and then Item.High /= null then
         Writer.Put (" ");
         Writer.Optional_New_Line;
         Writer.Put ("(");
         Item.Low.Write (Writer);
         Writer.Put (" .. ");
         Item.High.Write (Writer);
         Writer.Put (")");
      end if;
   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write (Item        : Subtype_Indication;
                    Writer      : in out Writer_Interface'Class)
   is
   begin
      Writer.Put (To_Ada_Name (Item.Base_Type));
      if Item.Class_Wide then
         Writer.Put ("'Class");
      end if;
      if Item.Constrained then
         Writer.Optional_New_Line;
         Writer.Put (" (");
         Item.Low.Write (Writer);
         Writer.Put (" .. ");
         Item.High.Write (Writer);
         Writer.Put (")");
      end if;
   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (Item        : Enumeration_Type_Definition;
      Writer      : in out Writer_Interface'Class)
   is
      Old_Indent    : constant Natural := Writer.Indent;
      First         : Boolean := True;
   begin
      Writer.Put ("(");
      Writer.Indent;
      for Text of Item.Literals loop
         if First then
            Writer.Put (To_Ada_Name (Text));
            First := False;
         else
            Writer.Put (",");
            if Writer.Col + 2 + Text'Length > Right_Margin then
               Writer.New_Line;
            else
               Writer.Put (" ");
            end if;
            Writer.Put (To_Ada_Name (Text));
         end if;
      end loop;
      Writer.Put (")");
      Writer.Indent (Old_Indent);
   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write (Item        : Interface_Type_Definition;
                    Writer      : in out Writer_Interface'Class)
   is
      Current_Indent : constant Natural := Writer.Indent;
   begin
      if Item.Is_Limited then
         Writer.Put ("limited ");
      end if;
      Writer.Put ("interface");
      if Item.Parents.Last_Index > 0 then
         Writer.Indent (Current_Indent + 2);
         for Parent_Name of Item.Parents loop
            Writer.New_Line;
            Writer.Put ("and " & Parent_Name);
         end loop;
         Writer.Indent (Current_Indent);
      end if;
   end Write;

     -----------
     -- Write --
     -----------

   overriding
   procedure Write
     (Item        : Current_Line_Expression;
      Writer      : in out Writer_Interface'Class)
   is
      pragma Unreferenced (Item);
   begin
      Writer.Put
        (Ada.Strings.Fixed.Trim
           (Positive'Image (Writer.Line),
            Ada.Strings.Left));
   end Write;

end Syn;
