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

   type Object_Node is new Syn.Trees.Tree_Node with record
      Name          : Unbounded_String;
      Object_Type   : Node_Access;
      Initial_Value : Node_Access;
      Is_Constant   : Boolean;
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
      Name        : Unbounded_String;
      Parameters  : Syn.Trees.Node_Vectors.Vector;
      Result_Type : Node_Access;
      --  Null for a procedure.
   end record;

   overriding function Document
     (Item  : Subprogram_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

end Syn.Declaration_Nodes;
