with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

with Syn.Declaration_Nodes;
with Syn.Expression_Nodes;
with Syn.Statement_Nodes;
with Syn.Trees;
with Syn.Unit_Nodes;

package body Syn.Factory is

   use Ada.Strings.Unbounded;

   function "+" (Item : String) return Unbounded_String
                 renames To_Unbounded_String;

   function Add
     (Self : in out Factory;
      Item : not null Node_Access)
      return not null Node_Access;
   --  Record Item as owned by Self, and return it.

   function Integer_Image
     (Value : Long_Long_Long_Integer;
      Base  : Positive;
      Group : Natural)
      return String;

   function New_Subprogram
     (Self        : in out Factory;
      Name        : String;
      Parameters  : Node_Array;
      Result_Type : Node_Access;
      Access_Name : String := "")
      return not null Node_Access;

   procedure Check_Specification
     (Item          : not null Node_Access;
      Function_Only : Boolean);
   --  Raise Constraint_Error unless Item is a subprogram declaration (a
   --  function declaration, if Function_Only), and not an access type.

   ---------
   -- Add --
   ---------

   function Add
     (Self : in out Factory;
      Item : not null Node_Access)
      return not null Node_Access
   is
   begin
      Self.Nodes.Append (Item);
      return Item;
   end Add;

   -------------------------
   -- Check_Specification --
   -------------------------

   procedure Check_Specification
     (Item          : not null Node_Access;
      Function_Only : Boolean)
   is
      use Syn.Declaration_Nodes;
   begin
      if Item.all not in Subprogram_Node'Class
        or else Length (Subprogram_Node'Class (Item.all).Access_Type_Name) > 0
      then
         raise Constraint_Error with "not a subprogram declaration";
      elsif Function_Only
        and then Subprogram_Node'Class (Item.all).Result_Type = null
      then
         raise Constraint_Error with "not a function declaration";
      end if;
   end Check_Specification;

   --------------
   -- Finalize --
   --------------

   overriding procedure Finalize (Self : in out Factory) is
      procedure Free is
        new Ada.Unchecked_Deallocation (Node'Class, Node_Access);
   begin
      for Item of Self.Nodes loop
         Free (Item);
      end loop;
      Self.Nodes.Clear;
   end Finalize;

   -------------------
   -- Integer_Image --
   -------------------

   function Integer_Image
     (Value : Long_Long_Long_Integer;
      Base  : Positive;
      Group : Natural)
      return String
   is
      Digit_Text : constant String := "0123456789ABCDEF";
      Radix      : constant Long_Long_Long_Integer :=
                     Long_Long_Long_Integer (Base);
      Magnitude  : Long_Long_Long_Integer := abs Value;
      Result     : Unbounded_String;
      Count      : Natural := 0;
   begin
      loop
         if Group > 0 and then Count > 0 and then Count mod Group = 0 then
            Result := "_" & Result;
         end if;
         Result := Digit_Text (Natural (Magnitude mod Radix) + 1) & Result;
         Count := Count + 1;
         Magnitude := Magnitude / Radix;
         exit when Magnitude = 0;
      end loop;

      if Base /= 10 then
         Result := Ada.Strings.Fixed.Trim (Base'Image, Ada.Strings.Left)
           & "#" & Result & "#";
      end if;

      if Value < 0 then
         Result := "-" & Result;
      end if;

      return To_String (Result);
   end Integer_Image;

   ------------------------------
   -- New_Access_Function_Type --
   ------------------------------

   function New_Access_Function_Type
     (Self        : in out Factory;
      Name        : String;
      Result_Type : not null Node_Access;
      Parameters  : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.New_Subprogram ("", Parameters, Result_Type, Name);
   end New_Access_Function_Type;

   -------------------------------
   -- New_Access_Procedure_Type --
   -------------------------------

   function New_Access_Procedure_Type
     (Self       : in out Factory;
      Name       : String;
      Parameters : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.New_Subprogram ("", Parameters, null, Name);
   end New_Access_Procedure_Type;

   --------------------
   -- New_Assignment --
   --------------------

   function New_Assignment
     (Self   : in out Factory;
      Target : not null Node_Access;
      Value  : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.Assignment_Node'
           (Syn.Trees.Tree_Node with Target => Target, Value => Value));
   end New_Assignment;

   -------------------
   -- New_Attribute --
   -------------------

   function New_Attribute
     (Self      : in out Factory;
      Prefix    : not null Node_Access;
      Attribute : String)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Attribute_Node'
           (Syn.Trees.Tree_Node with
            Prefix => Prefix, Attribute => +Attribute));
   end New_Attribute;

   ----------------
   -- New_Binary --
   ----------------

   function New_Binary
     (Self     : in out Factory;
      Left     : not null Node_Access;
      Operator : String;
      Right    : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Binary_Node'
           (Syn.Trees.Tree_Node with
            Left => Left, Operator => +Operator, Right => Right));
   end New_Binary;

   ---------------
   -- New_Block --
   ---------------

   function New_Block
     (Self         : in out Factory;
      Declarations : Node_Array := No_Nodes;
      Statements   : Node_Array)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.Block_Node'
           (Syn.Trees.Tree_Node with
            Declarations => Syn.Trees.To_Vector (Declarations),
            Statements   => Syn.Trees.To_Vector (Statements)));
   end New_Block;

   --------------
   -- New_Call --
   --------------

   function New_Call
     (Self      : in out Factory;
      Prefix    : not null Node_Access;
      Arguments : Node_Array)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Call_Node'
           (Syn.Trees.Tree_Node with
            Prefix    => Prefix,
            Arguments => Syn.Trees.To_Vector (Arguments)));
   end New_Call;

   --------------
   -- New_Call --
   --------------

   function New_Call
     (Self      : in out Factory;
      Name      : String;
      Arguments : Node_Array)
      return not null Node_Access
   is
   begin
      return Self.New_Call (Self.New_Name (Name), Arguments);
   end New_Call;

   ------------------------
   -- New_Call_Statement --
   ------------------------

   function New_Call_Statement
     (Self : in out Factory;
      Call : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.Call_Statement_Node'
           (Syn.Trees.Tree_Node with Call => Call));
   end New_Call_Statement;

   --------------------------
   -- New_Compilation_Unit --
   --------------------------

   function New_Compilation_Unit
     (Self    : in out Factory;
      Item    : not null Node_Access;
      Context : Node_Array := No_Nodes)
      return not null Node_Access
   is
      use Syn.Declaration_Nodes;
      Name    : Unbounded_String;
      Is_Spec : Boolean;
   begin
      if Item.all in Package_Node'Class then
         Name := Package_Node'Class (Item.all).Name;
         Is_Spec := True;
      elsif Item.all in Package_Body_Node'Class then
         Name := Package_Body_Node'Class (Item.all).Name;
         Is_Spec := False;
      else
         raise Constraint_Error with
           "a compilation unit must contain a package or a package body";
      end if;

      return Self.Add
        (new Syn.Unit_Nodes.Unit_Node'
           (Syn.Trees.Tree_Node with
            Context   => Syn.Trees.To_Vector (Context),
            Item      => Item,
            Unit_Name => Name,
            Is_Spec   => Is_Spec));
   end New_Compilation_Unit;

   -------------------
   -- New_Component --
   -------------------

   function New_Component
     (Self           : in out Factory;
      Name           : String;
      Component_Type : not null Node_Access;
      Default        : Node_Access := null)
      return not null Node_Access
   is
   begin
      return Self.New_Object
        (Name          => Name,
         Object_Type   => Component_Type,
         Initial_Value => Default);
   end New_Component;

   ----------------------
   -- New_Derived_Type --
   ----------------------

   function New_Derived_Type
     (Self   : in out Factory;
      Name   : String;
      Parent : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Derived_Type_Node'
           (Syn.Trees.Tree_Node with
            Name   => +Name,
            Parent => Parent));
   end New_Derived_Type;

   --------------------------
   -- New_Enumeration_Type --
   --------------------------

   function New_Enumeration_Type
     (Self     : in out Factory;
      Name     : String;
      Literals : Node_Array)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Enumeration_Node'
           (Syn.Trees.Tree_Node with
            Name     => +Name,
            Literals => Syn.Trees.To_Vector (Literals)));
   end New_Enumeration_Type;

   -----------------------------
   -- New_Expression_Function --
   -----------------------------

   function New_Expression_Function
     (Self          : in out Factory;
      Specification : not null Node_Access;
      Expression    : not null Node_Access)
      return not null Node_Access
   is
   begin
      Check_Specification (Specification, Function_Only => True);
      return Self.Add
        (new Syn.Declaration_Nodes.Expression_Function_Node'
           (Syn.Trees.Tree_Node with
            Specification => Specification,
            Expression    => Expression));
   end New_Expression_Function;

   ------------------
   -- New_Function --
   ------------------

   function New_Function
     (Self        : in out Factory;
      Name        : String;
      Result_Type : not null Node_Access;
      Parameters  : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.New_Subprogram (Name, Parameters, Result_Type);
   end New_Function;

   ------------
   -- New_If --
   ------------

   function New_If
     (Self      : in out Factory;
      Condition : not null Node_Access;
      Then_Part : Node_Array;
      Else_Part : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.If_Node'
           (Syn.Trees.Tree_Node with
            Condition => Condition,
            Then_Part => Syn.Trees.To_Vector (Then_Part),
            Else_Part => Syn.Trees.To_Vector (Else_Part)));
   end New_If;

   -------------------------
   -- New_Integer_Literal --
   -------------------------

   function New_Integer_Literal
     (Self  : in out Factory;
      Value : Long_Long_Long_Integer;
      Base  : Positive := 10;
      Group : Natural := 0)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Text_Node'
           (Syn.Trees.Tree_Node with
            Text => +Integer_Image (Value, Base, Group)));
   end New_Integer_Literal;

   --------------
   -- New_Name --
   --------------

   function New_Name
     (Self : in out Factory;
      Name : String)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Text_Node'
           (Syn.Trees.Tree_Node with Text => +Name));
   end New_Name;

   ------------------------
   -- New_Null_Statement --
   ------------------------

   function New_Null_Statement
     (Self : in out Factory)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.Null_Statement_Node'
           (Syn.Trees.Tree_Node with null record));
   end New_Null_Statement;

   ----------------
   -- New_Object --
   ----------------

   function New_Object
     (Self          : in out Factory;
      Name          : String;
      Object_Type   : Node_Access := null;
      Initial_Value : Node_Access := null;
      Is_Constant   : Boolean := False;
      Is_Aliased    : Boolean := False)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Object_Node'
           (Syn.Trees.Tree_Node with
            Name          => +Name,
            Object_Type   => Object_Type,
            Initial_Value => Initial_Value,
            Is_Constant   => Is_Constant,
            Is_Aliased    => Is_Aliased));
   end New_Object;

   -----------------
   -- New_Package --
   -----------------

   function New_Package
     (Self         : in out Factory;
      Name         : String;
      Public_Part  : Node_Array := No_Nodes;
      Private_Part : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Package_Node'
           (Syn.Trees.Tree_Node with
            Name         => +Name,
            Public_Part  => Syn.Trees.To_Vector (Public_Part),
            Private_Part => Syn.Trees.To_Vector (Private_Part)));
   end New_Package;

   ----------------------
   -- New_Package_Body --
   ----------------------

   function New_Package_Body
     (Self         : in out Factory;
      Name         : String;
      Declarations : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Package_Body_Node'
           (Syn.Trees.Tree_Node with
            Name         => +Name,
            Declarations => Syn.Trees.To_Vector (Declarations)));
   end New_Package_Body;

   -------------------
   -- New_Parameter --
   -------------------

   function New_Parameter
     (Self           : in out Factory;
      Name           : String;
      Parameter_Type : not null Node_Access;
      Mode           : Parameter_Mode := In_Mode;
      Default        : Node_Access := null)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Parameter_Node'
           (Syn.Trees.Tree_Node with
            Name           => +Name,
            Mode           => Mode,
            Parameter_Type => Parameter_Type,
            Default        => Default));
   end New_Parameter;

   ----------------------
   -- New_Private_Type --
   ----------------------

   function New_Private_Type
     (Self : in out Factory;
      Name : String)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Private_Type_Node'
           (Syn.Trees.Tree_Node with Name => +Name));
   end New_Private_Type;

   -------------------
   -- New_Procedure --
   -------------------

   function New_Procedure
     (Self       : in out Factory;
      Name       : String;
      Parameters : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.New_Subprogram (Name, Parameters, null);
   end New_Procedure;

   --------------------
   -- New_Range_Type --
   --------------------

   function New_Range_Type
     (Self : in out Factory;
      Name : String;
      Low  : not null Node_Access;
      High : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Range_Type_Node'
           (Syn.Trees.Tree_Node with
            Name => +Name,
            Low  => Low,
            High => High));
   end New_Range_Type;

   -------------
   -- New_Raw --
   -------------

   function New_Raw
     (Self : in out Factory;
      Text : String)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Raw_Node'
           (Syn.Trees.Tree_Node with Text => +Text));
   end New_Raw;

   ---------------------
   -- New_Record_Type --
   ---------------------

   function New_Record_Type
     (Self       : in out Factory;
      Name       : String;
      Components : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Record_Node'
           (Syn.Trees.Tree_Node with
            Name       => +Name,
            Components => Syn.Trees.To_Vector (Components)));
   end New_Record_Type;

   ----------------
   -- New_Return --
   ----------------

   function New_Return
     (Self  : in out Factory;
      Value : Node_Access := null)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Statement_Nodes.Return_Node'
           (Syn.Trees.Tree_Node with Value => Value));
   end New_Return;

   ------------------------
   -- New_String_Literal --
   ------------------------

   function New_String_Literal
     (Self : in out Factory;
      Text : String)
      return not null Node_Access
   is
      Quoted : Unbounded_String := +"""";
   begin
      for Ch of Text loop
         if Ch = '"' then
            Append (Quoted, """""");
         else
            Append (Quoted, Ch);
         end if;
      end loop;
      Append (Quoted, '"');

      return Self.Add
        (new Syn.Expression_Nodes.Text_Node'
           (Syn.Trees.Tree_Node with Text => Quoted));
   end New_String_Literal;

   --------------------
   -- New_Subprogram --
   --------------------

   function New_Subprogram
     (Self        : in out Factory;
      Name        : String;
      Parameters  : Node_Array;
      Result_Type : Node_Access;
      Access_Name : String := "")
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Subprogram_Node'
           (Syn.Trees.Tree_Node with
            Name             => +Name,
            Parameters       => Syn.Trees.To_Vector (Parameters),
            Result_Type      => Result_Type,
            Access_Type_Name => +Access_Name));
   end New_Subprogram;

   -------------------------
   -- New_Subprogram_Body --
   -------------------------

   function New_Subprogram_Body
     (Self          : in out Factory;
      Specification : not null Node_Access;
      Declarations  : Node_Array := No_Nodes;
      Statements    : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      Check_Specification (Specification, Function_Only => False);
      return Self.Add
        (new Syn.Declaration_Nodes.Subprogram_Body_Node'
           (Syn.Trees.Tree_Node with
            Specification => Specification,
            Declarations  => Syn.Trees.To_Vector (Declarations),
            Statements    => Syn.Trees.To_Vector (Statements)));
   end New_Subprogram_Body;

   ---------------
   -- New_Unary --
   ---------------

   function New_Unary
     (Self     : in out Factory;
      Operator : String;
      Operand  : not null Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Expression_Nodes.Unary_Node'
           (Syn.Trees.Tree_Node with
            Operator => +Operator, Operand => Operand));
   end New_Unary;

   -------------
   -- New_Use --
   -------------

   function New_Use
     (Self     : in out Factory;
      Name     : String;
      Use_Type : Boolean := False)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Use_Node'
           (Syn.Trees.Tree_Node with Name => +Name, Use_Type => Use_Type));
   end New_Use;

   --------------
   -- New_With --
   --------------

   function New_With
     (Self      : in out Factory;
      Unit_Name : String)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.With_Node'
           (Syn.Trees.Tree_Node with Unit_Name => +Unit_Name));
   end New_With;

end Syn.Factory;
