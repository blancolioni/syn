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

   --  Expressions

   function New_Call
     (Self      : in out Factory;
      Prefix    : not null Node_Access;
      Arguments : Node_Array)
      return not null Node_Access;
   --  Prefix (Arguments): a function call, the call in a procedure call
   --  statement, or an indexed component.

   function New_Call
     (Self      : in out Factory;
      Name      : String;
      Arguments : Node_Array)
      return not null Node_Access;
   --  New_Call with the name Name as its prefix.

   function New_Binary
     (Self     : in out Factory;
      Left     : not null Node_Access;
      Operator : String;
      Right    : not null Node_Access)
      return not null Node_Access;
   --  Left Operator Right, such as X /= Y or A and then B.

   function New_Named
     (Self  : in out Factory;
      Name  : String;
      Value : not null Node_Access)
      return not null Node_Access;
   --  Name => Value, as in a named association in a call.

   function New_Concatenation
     (Self  : in out Factory;
      Parts : Node_Array)
      return not null Node_Access
     with Pre => Parts'Length > 0;
   --  Parts joined by "&", breaking before "&" when they do not fit on
   --  one line.

   function New_Unary
     (Self     : in out Factory;
      Operator : String;
      Operand  : not null Node_Access)
      return not null Node_Access;
   --  Operator Operand, such as not X or -Y.

   function New_Attribute
     (Self      : in out Factory;
      Prefix    : not null Node_Access;
      Attribute : String)
      return not null Node_Access;
   --  Prefix'Attribute, such as Handle_Set_Timer'Access.

   --  Statements

   function New_Call_Statement
     (Self : in out Factory;
      Call : not null Node_Access)
      return not null Node_Access;
   --  A procedure call statement, from a call or a name.

   function New_Assignment
     (Self   : in out Factory;
      Target : not null Node_Access;
      Value  : not null Node_Access)
      return not null Node_Access;

   function New_If
     (Self      : in out Factory;
      Condition : not null Node_Access;
      Then_Part : Node_Array;
      Else_Part : Node_Array := No_Nodes)
      return not null Node_Access;

   function New_Return
     (Self  : in out Factory;
      Value : Node_Access := null)
      return not null Node_Access;
   --  A return statement, with Value if it is not null.

   function New_Block
     (Self         : in out Factory;
      Declarations : Node_Array := No_Nodes;
      Statements   : Node_Array)
      return not null Node_Access;
   --  A block statement, starting with "declare" if it has declarations.

   function New_For_Of_Loop
     (Self       : in out Factory;
      Name       : String;
      Container  : not null Node_Access;
      Statements : Node_Array)
      return not null Node_Access;
   --  for Name of Container loop Statements end loop;

   function New_Null_Statement
     (Self : in out Factory)
      return not null Node_Access;

   --  Declarations

   function New_With
     (Self      : in out Factory;
      Unit_Name : String)
      return not null Node_Access;

   function New_Use
     (Self     : in out Factory;
      Name     : String;
      Use_Type : Boolean := False)
      return not null Node_Access;
   --  A use clause, or a use type clause if Use_Type is True.

   function New_Package
     (Self         : in out Factory;
      Name         : String;
      Public_Part  : Node_Array := No_Nodes;
      Private_Part : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A package specification.

   function New_Package_Body
     (Self         : in out Factory;
      Name         : String;
      Declarations : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A package body. Each subprogram body in it is preceded by a header
   --  comment with the subprogram's name.

   function New_Object
     (Self          : in out Factory;
      Name          : String;
      Object_Type   : Node_Access := null;
      Initial_Value : Node_Access := null;
      Is_Constant   : Boolean := False;
      Is_Aliased    : Boolean := False;
      Aspects       : Node_Array := No_Nodes)
      return not null Node_Access
     with Pre => Object_Type /= null
                 or else (Is_Constant and then Initial_Value /= null);
   --  An object or constant declaration. A constant without a type is a
   --  named number. Aspects come from New_Aspect.

   function New_Aspect
     (Self       : in out Factory;
      Name       : String;
      Definition : Node_Access := null)
      return not null Node_Access;
   --  An aspect specification, such as Import or Address => X.

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

   function New_Range_Type
     (Self : in out Factory;
      Name : String;
      Low  : not null Node_Access;
      High : not null Node_Access)
      return not null Node_Access;
   --  type Name is range Low .. High;

   function New_Derived_Type
     (Self   : in out Factory;
      Name   : String;
      Parent : not null Node_Access)
      return not null Node_Access;
   --  type Name is new Parent;

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
   --  A procedure declaration. It can also be the specification of a
   --  procedure body.

   function New_Function
     (Self        : in out Factory;
      Name        : String;
      Result_Type : not null Node_Access;
      Parameters  : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A function declaration. It can also be the specification of a
   --  function body or an expression function.

   function New_Access_Procedure_Type
     (Self       : in out Factory;
      Name       : String;
      Parameters : Node_Array := No_Nodes)
      return not null Node_Access;
   --  type Name is access procedure (Parameters);

   function New_Access_Function_Type
     (Self        : in out Factory;
      Name        : String;
      Result_Type : not null Node_Access;
      Parameters  : Node_Array := No_Nodes)
      return not null Node_Access;
   --  type Name is access function (Parameters) return Result_Type;

   function New_Subprogram_Body
     (Self          : in out Factory;
      Specification : not null Node_Access;
      Declarations  : Node_Array := No_Nodes;
      Statements    : Node_Array := No_Nodes)
      return not null Node_Access;
   --  The body of the subprogram declared by Specification, which must
   --  come from New_Procedure or New_Function. With no statements, the
   --  body is "null;". Raises Constraint_Error if Specification is not a
   --  subprogram declaration.

   function New_Expression_Function
     (Self          : in out Factory;
      Specification : not null Node_Access;
      Expression    : not null Node_Access)
      return not null Node_Access;
   --  function ... is (Expression); Specification must come from
   --  New_Function. Raises Constraint_Error if it does not.

   --  Compilation units

   function New_Compilation_Unit
     (Self    : in out Factory;
      Item    : not null Node_Access;
      Context : Node_Array := No_Nodes)
      return not null Node_Access;
   --  A compilation unit for Item, with the context clauses Context. Item
   --  must be a package, a package body, a subprogram declaration or a
   --  subprogram body; Constraint_Error is raised if it is none of these.

private

   package Node_Lists is
     new Ada.Containers.Vectors (Positive, Node_Access);

   type Factory is new Ada.Finalization.Limited_Controlled with record
      Nodes : Node_Lists.Vector;
   end record;

   overriding procedure Finalize (Self : in out Factory);

end Syn.Factory;
