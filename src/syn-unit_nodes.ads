with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Style;
with Syn.Trees;

private package Syn.Unit_Nodes is

   type Unit_Node is new Syn.Trees.Tree_Node with record
      Context   : Syn.Trees.Node_Vectors.Vector;
      Item      : Node_Access;
      Unit_Name : Ada.Strings.Unbounded.Unbounded_String;
      Is_Spec   : Boolean;
   end record;
   --  A compilation unit: its context clauses and the library item.

   overriding function Document
     (Item  : Unit_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

end Syn.Unit_Nodes;
