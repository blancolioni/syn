with Ada.Strings.Unbounded;

with Syn.Documents;
with Syn.Style;
with Syn.Trees;

private package Syn.Expression_Nodes is

   use Ada.Strings.Unbounded;

   type Text_Node is new Syn.Trees.Tree_Node with record
      Text : Unbounded_String;
   end record;
   --  A name or literal, already in its final form.

   overriding function Document
     (Item  : Text_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Raw_Node is new Syn.Trees.Tree_Node with record
      Text : Unbounded_String;
   end record;
   --  Source text written as it is, which may contain line breaks.

   overriding function Document
     (Item  : Raw_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Call_Node is new Syn.Trees.Tree_Node with record
      Prefix    : Node_Access;
      Arguments : Syn.Trees.Node_Vectors.Vector;
   end record;
   --  A function call, procedure call or indexed component:
   --  Prefix (Arguments).

   overriding function Document
     (Item  : Call_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Binary_Node is new Syn.Trees.Tree_Node with record
      Left     : Node_Access;
      Operator : Unbounded_String;
      Right    : Node_Access;
   end record;

   overriding function Document
     (Item  : Binary_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Unary_Node is new Syn.Trees.Tree_Node with record
      Operator : Unbounded_String;
      Operand  : Node_Access;
   end record;

   overriding function Document
     (Item  : Unary_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Named_Node is new Syn.Trees.Tree_Node with record
      Name  : Unbounded_String;
      Value : Node_Access;
   end record;
   --  Name => Value, as in a named association.

   overriding function Document
     (Item  : Named_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Concatenation_Node is new Syn.Trees.Tree_Node with record
      Parts : Syn.Trees.Node_Vectors.Vector;
   end record;
   --  Parts joined by "&". When they do not fit on one line, each part
   --  after the first starts a line with "&".

   overriding function Document
     (Item  : Concatenation_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

   type Attribute_Node is new Syn.Trees.Tree_Node with record
      Prefix    : Node_Access;
      Attribute : Unbounded_String;
   end record;
   --  Prefix'Attribute.

   overriding function Document
     (Item  : Attribute_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document;

end Syn.Expression_Nodes;
