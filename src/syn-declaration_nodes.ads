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
      Aspects       : Syn.Trees.Node_Vectors.Vector;
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

   type Aspect_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Definition : Node_Access;
   end record;
   --  Name, or Name => Definition if Definition is not null.

   overriding function Document
     (Item  : Aspect_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Range_Type_Node is new Syn.Trees.Tree_Node with record
      Name : Unbounded_String;
      Low  : Node_Access;
      High : Node_Access;
   end record;

   overriding function Document
     (Item  : Range_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Derived_Type_Node is new Syn.Trees.Tree_Node with record
      Name   : Unbounded_String;
      Parent : Node_Access;
   end record;

   overriding function Document
     (Item  : Derived_Type_Node;
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

   type Interface_Type_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Parents    : Syn.Trees.Node_Vectors.Vector;
      Is_Limited : Boolean;
   end record;
   --  type Name is [limited] interface [and Parent ...];

   overriding function Document
     (Item  : Interface_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Extension_Kind is (Private_Extension, Record_Extension);

   type Extension_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Kind       : Extension_Kind;
      Parent     : Node_Access;
      Interfaces : Syn.Trees.Node_Vectors.Vector;
      Components : Syn.Trees.Node_Vectors.Vector;
      --  Unused for a private extension.
      Is_Limited : Boolean;
   end record;
   --  type Name is [limited] new Parent [and Interface ...] with private;
   --  or the same with a record, or a null record if it has no
   --  components.

   overriding function Document
     (Item  : Extension_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Access_Kind is (Pool_Access, All_Access, Constant_Access);
   --  "access", "access all" or "access constant".

   type Access_Type_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Kind       : Access_Kind;
      Designated : Node_Access;
   end record;

   overriding function Document
     (Item  : Access_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Array_Type_Node is new Syn.Trees.Tree_Node with record
      Name      : Unbounded_String;
      Index     : Node_Access;
      Component : Node_Access;
   end record;
   --  type Name is array (Index) of Component;

   overriding function Document
     (Item  : Array_Type_Node;
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
      Indicator        : Overriding_Kind;
      Is_Abstract      : Boolean;
   end record;
   --  A subprogram declaration, or an access-to-subprogram type. Bodies
   --  and expression functions use one as their specification, and so
   --  repeat its overriding indicator.

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
