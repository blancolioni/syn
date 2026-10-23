package body Syn.Unit_Nodes is

   use Syn.Documents;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Unit_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Result : Syn.Documents.Document := Empty;
   begin
      for Clause of Item.Context loop
         Result := Result & Syn.Trees.To_Document (Clause, Style) & Hard_Line;
      end loop;

      if not Item.Context.Is_Empty then
         Result := Result & Hard_Line;
      end if;

      return Result & Syn.Trees.To_Document (Item.Item, Style);
   end Document;

end Syn.Unit_Nodes;
