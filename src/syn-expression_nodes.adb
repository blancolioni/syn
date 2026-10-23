with Ada.Characters.Latin_1;

package body Syn.Expression_Nodes is

   use Ada.Strings.Unbounded;
   use Syn.Documents;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Text_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Style, Pad);
   begin
      return Text (To_String (Item.Text));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Raw_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Style, Pad);
      Source : constant String := To_String (Item.Text);
      Result : Syn.Documents.Document := Empty;
      Start  : Positive := Source'First;
   begin
      for Index in Source'Range loop
         if Source (Index) = Ada.Characters.Latin_1.LF then
            Result := Result & Text (Source (Start .. Index - 1)) & Hard_Line;
            Start := Index + 1;
         end if;
      end loop;
      if Start <= Source'Last then
         Result := Result & Text (Source (Start .. Source'Last));
      end if;
      return Result;
   end Document;

end Syn.Expression_Nodes;
