with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Style;
with Syn.Trees;

private package Syn.Declaration_Nodes is

   use Ada.Strings.Unbounded;

   type With_Node is new Syn.Trees.Tree_Node with record
      Unit_Name : Unbounded_String;
   end record;

   overriding function Document
     (Item  : With_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Use_Node is new Syn.Trees.Tree_Node with record
      Name     : Unbounded_String;
      Use_Type : Boolean;
   end record;
   --  "use Name;", or "use type Name;".

   overriding function Document
     (Item  : Use_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Package_Node is new Syn.Trees.Tree_Node with record
      Name         : Unbounded_String;
      Public_Part  : Syn.Trees.Node_Vectors.Vector;
      Private_Part : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Package_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Package_Body_Node is new Syn.Trees.Tree_Node with record
      Name         : Unbounded_String;
      Declarations : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Package_Body_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Object_Node is new Syn.Trees.Tree_Node with record
      Name          : Unbounded_String;
      Object_Type   : Node_Access;
      Initial_Value : Node_Access;
      Is_Constant   : Boolean;
      Is_Aliased    : Boolean;
   end record;
   --  An object, constant, named number or record component.

   overriding function Document
     (Item  : Object_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   overriding function Defining_Width (Item : Object_Node) return Natural
   is (Length (Item.Name));

   type Enumeration_Node is new Syn.Trees.Tree_Node with record
      Name     : Unbounded_String;
      Literals : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Enumeration_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Private_Type_Node is new Syn.Trees.Tree_Node with record
      Name : Unbounded_String;
   end record;

   overriding function Document
     (Item  : Private_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Record_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Components : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Record_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Parameter_Node is new Syn.Trees.Tree_Node with record
      Name           : Unbounded_String;
      Mode           : Parameter_Mode;
      Parameter_Type : Node_Access;
      Default        : Node_Access;
   end record;

   overriding function Document
     (Item  : Parameter_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   overriding function Defining_Width (Item : Parameter_Node) return Natural
   is (Length (Item.Name));

   type Subprogram_Node is new Syn.Trees.Tree_Node with record
      Name             : Unbounded_String;
      Parameters       : Syn.Trees.Node_Vectors.Vector;
      Result_Type      : Node_Access;
      --  Null for a procedure.
      Access_Type_Name : Unbounded_String;
      --  If not empty, this is an access-to-subprogram type with this
      --  name, and Name is unused.
   end record;
   --  A subprogram declaration, or an access-to-subprogram type. Bodies
   --  and expression functions use one as their specification.

   overriding function Document
     (Item  : Subprogram_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Subprogram_Body_Node is new Syn.Trees.Tree_Node with record
      Specification : Node_Access;
      --  A Subprogram_Node.
      Declarations  : Syn.Trees.Node_Vectors.Vector;
      Statements    : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Subprogram_Body_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   overriding function Body_Name
     (Item : Subprogram_Body_Node)
      return String;

   type Expression_Function_Node is new Syn.Trees.Tree_Node with record
      Specification : Node_Access;
      --  A Subprogram_Node for a function.
      Expression    : Node_Access;
   end record;

   overriding function Document
     (Item  : Expression_Function_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   overriding function Body_Name
     (Item : Expression_Function_Node)
      return String;

end Syn.Declaration_Nodes;
