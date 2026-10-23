private with Ada.Strings.Unbounded;

package Syn.Documents is

   --  A document is text with places where a line may be broken, in the
   --  style of Wadler's "A prettier printer". Render lays a document out
   --  for a line width, breaking the fewest groups it needs to.
   --
   --  Documents are never freed. They are small, and every program that
   --  uses Syn generates its files and exits.

   type Document is private;

   type Document_Array is array (Positive range <>) of Document;

   Empty : constant Document;

   function Text (Item : String) return Document;
   --  Item, which must not contain a line break.

   function Spaces (Count : Natural) return Document;
   --  Count spaces.

   function Line return Document;
   --  A line break, or a space if the enclosing group fits on one line.

   function Soft_Line return Document;
   --  A line break, or nothing if the enclosing group fits on one line.

   function Hard_Line return Document;
   --  Always a line break. A group containing one never fits on a line.

   function Nest (Indent : Natural; Item : Document) return Document;
   --  Item, with the lines after its breaks indented a further Indent
   --  columns.

   function Align (Item : Document) return Document;
   --  Item, with the lines after its breaks indented to the column where
   --  Item starts.

   function Group (Item : Document) return Document;
   --  Item on one line if it fits, otherwise with all its own breaks
   --  taken.

   function If_Flat (Flat, Broken : Document) return Document;
   --  Flat if the enclosing group fits on one line, otherwise Broken.

   function "&" (Left, Right : Document) return Document;

   function Join
     (Items     : Document_Array;
      Separator : Document)
      return Document;
   --  Items, with Separator between each pair.

   function Render (Item : Document; Width : Positive) return String;
   --  Item laid out for lines of Width columns. Lines end with a line
   --  feed, and never with a space.

private

   type Document_Kind is
     (Text_Doc, Line_Doc, Soft_Line_Doc, Hard_Line_Doc,
      Nest_Doc, Align_Doc, Group_Doc, Choice_Doc, Concat_Doc);

   type Document_Record;

   type Document is access constant Document_Record;

   type Document_Record (Kind : Document_Kind) is record
      case Kind is
         when Text_Doc =>
            Text : Ada.Strings.Unbounded.Unbounded_String;
         when Line_Doc | Soft_Line_Doc | Hard_Line_Doc =>
            null;
         when Nest_Doc =>
            Indent : Natural;
            Nested : Document;
         when Align_Doc | Group_Doc =>
            Inner : Document;
         when Choice_Doc =>
            Flat   : Document;
            Broken : Document;
         when Concat_Doc =>
            Left   : Document;
            Right  : Document;
      end case;
   end record;

   Empty : constant Document := null;

end Syn.Documents;
