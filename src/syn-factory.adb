with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

with Syn.Declaration_Nodes;
with Syn.Expression_Nodes;
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
      Result_Type : Node_Access)
      return not null Node_Access;

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

   --------------------------
   -- New_Compilation_Unit --
   --------------------------

   function New_Compilation_Unit
     (Self    : in out Factory;
      Item    : not null Node_Access;
      Context : Node_Array := No_Nodes)
      return not null Node_Access
   is
   begin
      if Item.all not in Syn.Declaration_Nodes.Package_Node'Class then
         raise Constraint_Error with
           "a compilation unit must contain a package";
      end if;

      return Self.Add
        (new Syn.Unit_Nodes.Unit_Node'
           (Syn.Trees.Tree_Node with
            Context   => Syn.Trees.To_Vector (Context),
            Item      => Item,
            Unit_Name =>
              Syn.Declaration_Nodes.Package_Node'Class (Item.all).Name,
            Is_Spec   => True));
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

   ----------------
   -- New_Object --
   ----------------

   function New_Object
     (Self          : in out Factory;
      Name          : String;
      Object_Type   : Node_Access := null;
      Initial_Value : Node_Access := null;
      Is_Constant   : Boolean := False)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Object_Node'
           (Syn.Trees.Tree_Node with
            Name          => +Name,
            Object_Type   => Object_Type,
            Initial_Value => Initial_Value,
            Is_Constant   => Is_Constant));
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
      Result_Type : Node_Access)
      return not null Node_Access
   is
   begin
      return Self.Add
        (new Syn.Declaration_Nodes.Subprogram_Node'
           (Syn.Trees.Tree_Node with
            Name        => +Name,
            Parameters  => Syn.Trees.To_Vector (Parameters),
            Result_Type => Result_Type));
   end New_Subprogram;

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
