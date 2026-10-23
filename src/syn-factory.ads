private with Ada.Containers.Vectors;
private with Ada.Finalization;

package Syn.Factory is

   type Factory is tagged limited private;
   --  Creates nodes, and owns them: every node a factory created is freed
   --  when the factory is finalised.

   --  Names and literals

   function New_Name
     (Self : in out Factory;
      Name : String)
      return not null Node_Access;
   --  A name, such as Natural or Rose.Objects.Endpoint_Id.

   function New_Integer_Literal
     (Self  : in out Factory;
      Value : Long_Long_Long_Integer;
      Base  : Positive := 10;
      Group : Natural := 0)
      return not null Node_Access
     with Pre => Base in 2 .. 16
                 and then Value > Long_Long_Long_Integer'First;
   --  An integer literal of any size, written in Base, with an underscore
   --  between each Group digits counting from the right, or none if Group
   --  is zero. For example, Base 16 and Group 4 give 16#3D3E_F48A_496A#.

   function New_String_Literal
     (Self : in out Factory;
      Text : String)
      return not null Node_Access;
   --  A string literal containing Text, with any quotation marks doubled.

   function New_Raw
     (Self : in out Factory;
      Text : String)
      return not null Node_Access;
   --  Source text written exactly as it is. It may contain line breaks.
   --  Use this for what the other nodes do not cover.

   --  Declarations

   function New_With
     (Self      : in out Factory;
      Unit_Name : String)
      return not null Node_Access;

   function New_Package
     (Self         : in out Factory;
      Name         : String;
      Public_Part  : Node_Array := No_Nodes;
      Private_Part : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A package specification.

   function New_Object
     (Self          : in out Factory;
      Name          : String;
      Object_Type   : Node_Access := null;
      Initial_Value : Node_Access := null;
      Is_Constant   : Boolean := False)
      return not null Node_Access
     with Pre => Object_Type /= null
                 or else (Is_Constant and then Initial_Value /= null);
   --  An object or constant declaration. A constant without a type is a
   --  named number.

   function New_Component
     (Self           : in out Factory;
      Name           : String;
      Component_Type : not null Node_Access;
      Default        : Node_Access := null)
      return not null Node_Access;
   --  A record component.

   function New_Enumeration_Type
     (Self     : in out Factory;
      Name     : String;
      Literals : Node_Array)
      return not null Node_Access
     with Pre => Literals'Length > 0;

   function New_Private_Type
     (Self : in out Factory;
      Name : String)
      return not null Node_Access;

   function New_Record_Type
     (Self       : in out Factory;
      Name       : String;
      Components : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A record type. With no components, it is a null record.

   function New_Parameter
     (Self           : in out Factory;
      Name           : String;
      Parameter_Type : not null Node_Access;
      Mode           : Parameter_Mode := In_Mode;
      Default        : Node_Access := null)
      return not null Node_Access;

   function New_Procedure
     (Self       : in out Factory;
      Name       : String;
      Parameters : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A procedure declaration.

   function New_Function
     (Self        : in out Factory;
      Name        : String;
      Result_Type : not null Node_Access;
      Parameters  : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A function declaration.

   --  Compilation units

   function New_Compilation_Unit
     (Self    : in out Factory;
      Item    : not null Node_Access;
      Context : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A compilation unit for Item, which must be a package, with the
   --  context clauses Context. Raises Constraint_Error if Item is not a
   --  package.

private

   package Node_Lists is
     new Ada.Containers.Vectors (Positive, Node_Access);

   type Factory is new Ada.Finalization.Limited_Controlled with record
      Nodes : Node_Lists.Vector;
   end record;

   overriding procedure Finalize (Self : in out Factory);

end Syn.Factory;
