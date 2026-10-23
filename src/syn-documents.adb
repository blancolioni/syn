with Ada.Characters.Latin_1;
with Ada.Containers.Vectors;
with Ada.Strings.Fixed;

package body Syn.Documents is

   use Ada.Strings.Unbounded;

   type Work_Item is record
      Indent : Natural;
      Flat   : Boolean;
      Item   : Document;
   end record;
   --  An item still to be laid out: a document, the indentation for its
   --  line breaks, and whether its group is laid out on one line.

   package Work_Vectors is
     new Ada.Containers.Vectors (Positive, Work_Item);

   Line_Item      : constant Document :=
                      new Document_Record'(Kind => Line_Doc);
   Soft_Line_Item : constant Document :=
                      new Document_Record'(Kind => Soft_Line_Doc);
   Hard_Line_Item : constant Document :=
                      new Document_Record'(Kind => Hard_Line_Doc);

   function Fits
     (Room  : Integer;
      First : Work_Item;
      Rest  : Work_Vectors.Vector)
      return Boolean;
   --  True if First, laid out on one line, and whatever follows it up to
   --  the next line break, fit in Room columns. Rest is the work stack
   --  under First, with its top item last.

   procedure Push
     (Stack  : in out Work_Vectors.Vector;
      Indent : Natural;
      Flat   : Boolean;
      Item   : Document);

   procedure Push_Children
     (Stack : in out Work_Vectors.Vector;
      Top   : Work_Item);
   --  Push the parts of Top, which is a Nest, Align, Choice or Concat,
   --  for layout in Top's mode. An Align pushes its inner document with
   --  Top's indentation; Render replaces that with the current column.

   function Strip_Trailing_Spaces (Item : String) return String;

   ---------
   -- "&" --
   ---------

   function "&" (Left, Right : Document) return Document is
   begin
      if Left = null then
         return Right;
      elsif Right = null then
         return Left;
      else
         return new Document_Record'
           (Kind => Concat_Doc, Left => Left, Right => Right);
      end if;
   end "&";

   -----------
   -- Align --
   -----------

   function Align (Item : Document) return Document is
   begin
      return (if Item = null then null
              else new Document_Record'(Kind => Align_Doc, Inner => Item));
   end Align;

   ----------
   -- Fits --
   ----------

   function Fits
     (Room  : Integer;
      First : Work_Item;
      Rest  : Work_Vectors.Vector)
      return Boolean
   is
      Remaining : Integer := Room;
      Local     : Work_Vectors.Vector;
      Next_Rest : Natural := Rest.Last_Index;
   begin
      Local.Append (First);

      loop
         if Remaining < 0 then
            return False;
         end if;

         if Local.Is_Empty then
            if Next_Rest = 0 then
               return True;
            end if;
            Local.Append (Rest (Next_Rest));
            Next_Rest := Next_Rest - 1;
         end if;

         declare
            Top : constant Work_Item := Local.Last_Element;
         begin
            Local.Delete_Last;

            if Top.Item /= null then
               case Top.Item.Kind is
                  when Text_Doc =>
                     Remaining := Remaining - Length (Top.Item.Text);
                  when Line_Doc =>
                     if Top.Flat then
                        Remaining := Remaining - 1;
                     else
                        return True;
                     end if;
                  when Soft_Line_Doc =>
                     if not Top.Flat then
                        return True;
                     end if;
                  when Hard_Line_Doc =>
                     return not Top.Flat;
                  when Group_Doc =>
                     Push (Local, Top.Indent, Top.Flat, Top.Item.Inner);
                  when Nest_Doc | Align_Doc | Choice_Doc | Concat_Doc =>
                     Push_Children (Local, Top);
               end case;
            end if;
         end;
      end loop;
   end Fits;

   -----------
   -- Group --
   -----------

   function Group (Item : Document) return Document is
   begin
      return (if Item = null then null
              else new Document_Record'(Kind => Group_Doc, Inner => Item));
   end Group;

   ---------------
   -- Hard_Line --
   ---------------

   function Hard_Line return Document is (Hard_Line_Item);

   -------------
   -- If_Flat --
   -------------

   function If_Flat (Flat, Broken : Document) return Document is
   begin
      return new Document_Record'
        (Kind => Choice_Doc, Flat => Flat, Broken => Broken);
   end If_Flat;

   ----------
   -- Join --
   ----------

   function Join
     (Items     : Document_Array;
      Separator : Document)
      return Document
   is
      Result : Document := Empty;
   begin
      for Index in Items'Range loop
         if Index > Items'First then
            Result := Result & Separator;
         end if;
         Result := Result & Items (Index);
      end loop;
      return Result;
   end Join;

   ----------
   -- Line --
   ----------

   function Line return Document is (Line_Item);

   ----------
   -- Nest --
   ----------

   function Nest (Indent : Natural; Item : Document) return Document is
   begin
      return (if Item = null then null
              else new Document_Record'
                (Kind => Nest_Doc, Indent => Indent, Nested => Item));
   end Nest;

   ----------
   -- Push --
   ----------

   procedure Push
     (Stack  : in out Work_Vectors.Vector;
      Indent : Natural;
      Flat   : Boolean;
      Item   : Document)
   is
   begin
      Stack.Append (Work_Item'(Indent => Indent, Flat => Flat, Item => Item));
   end Push;

   -------------------
   -- Push_Children --
   -------------------

   procedure Push_Children
     (Stack : in out Work_Vectors.Vector;
      Top   : Work_Item)
   is
   begin
      case Top.Item.Kind is
         when Nest_Doc =>
            Push (Stack, Top.Indent + Top.Item.Indent, Top.Flat,
                  Top.Item.Nested);
         when Align_Doc =>
            Push (Stack, Top.Indent, Top.Flat, Top.Item.Inner);
         when Choice_Doc =>
            Push (Stack, Top.Indent, Top.Flat,
                  (if Top.Flat then Top.Item.Flat else Top.Item.Broken));
         when Concat_Doc =>
            Push (Stack, Top.Indent, Top.Flat, Top.Item.Right);
            Push (Stack, Top.Indent, Top.Flat, Top.Item.Left);
         when others =>
            raise Program_Error;
      end case;
   end Push_Children;

   ------------
   -- Render --
   ------------

   function Render (Item : Document; Width : Positive) return String is
      Result  : Unbounded_String;
      Column  : Natural := 0;
      Pending : Natural := 0;
      --  Spaces owed at the start of the current line. They are written
      --  only when text follows, so blank lines stay empty.
      Stack   : Work_Vectors.Vector;

      procedure New_Line (Indent : Natural);
      procedure Put (Text : String);

      --------------
      -- New_Line --
      --------------

      procedure New_Line (Indent : Natural) is
      begin
         Append (Result, Ada.Characters.Latin_1.LF);
         Column := Indent;
         Pending := Indent;
      end New_Line;

      ---------
      -- Put --
      ---------

      procedure Put (Text : String) is
      begin
         if Text'Length > 0 then
            if Pending > 0 then
               Append (Result, Ada.Strings.Fixed."*" (Pending, ' '));
               Pending := 0;
            end if;
            Append (Result, Text);
            Column := Column + Text'Length;
         end if;
      end Put;

   begin
      Push (Stack, 0, False, Item);

      while not Stack.Is_Empty loop
         declare
            Top : constant Work_Item := Stack.Last_Element;
         begin
            Stack.Delete_Last;

            if Top.Item /= null then
               case Top.Item.Kind is
                  when Text_Doc =>
                     Put (To_String (Top.Item.Text));
                  when Line_Doc =>
                     if Top.Flat then
                        Put (" ");
                     else
                        New_Line (Top.Indent);
                     end if;
                  when Soft_Line_Doc =>
                     if not Top.Flat then
                        New_Line (Top.Indent);
                     end if;
                  when Hard_Line_Doc =>
                     New_Line (Top.Indent);
                  when Align_Doc =>
                     Push (Stack, Column, Top.Flat, Top.Item.Inner);
                  when Group_Doc =>
                     if Top.Flat
                       or else Fits
                         (Width - Column,
                          Work_Item'(Top.Indent, True, Top.Item.Inner),
                          Stack)
                     then
                        Push (Stack, Top.Indent, True, Top.Item.Inner);
                     else
                        Push (Stack, Top.Indent, False, Top.Item.Inner);
                     end if;
                  when Nest_Doc | Choice_Doc | Concat_Doc =>
                     Push_Children (Stack, Top);
               end case;
            end if;
         end;
      end loop;

      return Strip_Trailing_Spaces (To_String (Result));
   end Render;

   ---------------
   -- Soft_Line --
   ---------------

   function Soft_Line return Document is (Soft_Line_Item);

   ------------
   -- Spaces --
   ------------

   function Spaces (Count : Natural) return Document is
   begin
      return (if Count = 0 then null
              else Text (Ada.Strings.Fixed."*" (Count, ' ')));
   end Spaces;

   ---------------------------
   -- Strip_Trailing_Spaces --
   ---------------------------

   function Strip_Trailing_Spaces (Item : String) return String is
      Result : Unbounded_String;
      Start  : Positive := Item'First;
   begin
      for Index in Item'Range loop
         if Item (Index) = Ada.Characters.Latin_1.LF then
            Append (Result, Ada.Strings.Fixed.Trim
                    (Item (Start .. Index - 1), Ada.Strings.Right));
            Append (Result, Ada.Characters.Latin_1.LF);
            Start := Index + 1;
         end if;
      end loop;
      if Start <= Item'Last then
         Append (Result, Ada.Strings.Fixed.Trim
                 (Item (Start .. Item'Last), Ada.Strings.Right));
      end if;
      return To_String (Result);
   end Strip_Trailing_Spaces;

   ----------
   -- Text --
   ----------

   function Text (Item : String) return Document is
   begin
      return (if Item = "" then null
              else new Document_Record'
                (Kind => Text_Doc, Text => To_Unbounded_String (Item)));
   end Text;

end Syn.Documents;
