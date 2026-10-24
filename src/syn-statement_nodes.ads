with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Style;
with Syn.Trees;

private package Syn.Statement_Nodes is

   use Ada.Strings.Unbounded;

   type Call_Statement_Node is new Syn.Trees.Tree_Node with record
      Call : Node_Access;
   end record;
   --  A procedure call: a call node or a name, followed by ";".

   overriding function Document
     (Item  : Call_Statement_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Assignment_Node is new Syn.Trees.Tree_Node with record
      Target : Node_Access;
      Value  : Node_Access;
   end record;

   overriding function Document
     (Item  : Assignment_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type If_Node is new Syn.Trees.Tree_Node with record
      Condition : Node_Access;
      Then_Part : Syn.Trees.Node_Vectors.Vector;
      Else_Part : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : If_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Return_Node is new Syn.Trees.Tree_Node with record
      Value : Node_Access;
      --  Null for a return from a procedure.
   end record;

   overriding function Document
     (Item  : Return_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Block_Node is new Syn.Trees.Tree_Node with record
      Declarations : Syn.Trees.Node_Vectors.Vector;
      Statements   : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : Block_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type For_Of_Loop_Node is new Syn.Trees.Tree_Node with record
      Name       : Unbounded_String;
      Container  : Node_Access;
      Statements : Syn.Trees.Node_Vectors.Vector;
   end record;

   overriding function Document
     (Item  : For_Of_Loop_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Null_Statement_Node is new Syn.Trees.Tree_Node with null record;

   overriding function Document
     (Item  : Null_Statement_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   function Statements
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document;
   --  Items, one per line, each preceded by a line break, indented one
   --  level; "null;" if Items is empty.

end Syn.Statement_Nodes;
