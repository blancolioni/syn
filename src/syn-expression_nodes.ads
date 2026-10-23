with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Style;
with Syn.Trees;

private package Syn.Expression_Nodes is

   type Text_Node is new Syn.Trees.Tree_Node with record
      Text : Ada.Strings.Unbounded.Unbounded_String;
   end record;
   --  A name or literal, already in its final form.

   overriding function Document
     (Item  : Text_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Raw_Node is new Syn.Trees.Tree_Node with record
      Text : Ada.Strings.Unbounded.Unbounded_String;
   end record;
   --  Source text written as it is, which may contain line breaks.

   overriding function Document
     (Item  : Raw_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

end Syn.Expression_Nodes;
