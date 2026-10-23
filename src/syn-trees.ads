with Ada.Containers.Vectors;

with Syn.Documents;
with Syn.Style;

private package Syn.Trees is

   --  Every node created by a factory is a Tree_Node. Each kind of node
   --  lays itself out as a document; Syn.Documents decides the line
   --  breaks.

   type Tree_Node is abstract new Node with null record;

   function Document
     (Item  : Tree_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
      is abstract;
   --  Item laid out in Style. Pad is the width to pad Item's defining
   --  name to, when Item is one of a list whose names are aligned.

   function Defining_Width (Item : Tree_Node) return Natural is (0);
   --  The length of Item's defining name, if it is aligned with others
   --  in a list, otherwise zero.

   function To_Document
     (Item  : not null Node_Access;
      Style : Syn.Style.Settings;
      Pad   : Natural := 0)
      return Syn.Documents.Document
   is (Tree_Node'Class (Item.all).Document (Style, Pad));

   function Defining_Width (Item : not null Node_Access) return Natural
   is (Tree_Node'Class (Item.all).Defining_Width);

   package Node_Vectors is
     new Ada.Containers.Vectors (Positive, Node_Access);

   function To_Vector (Items : Node_Array) return Node_Vectors.Vector;

   function Max_Defining_Width (Items : Node_Vectors.Vector) return Natural;
   --  The longest defining name in Items, for aligning them.

end Syn.Trees;
