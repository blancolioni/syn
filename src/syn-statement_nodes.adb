package body Syn.Statement_Nodes is

   use Syn.Documents;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Call_Statement_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Syn.Trees.To_Document (Item.Call, Style) & Text (";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Assignment_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Syn.Trees.To_Document (Item.Target, Style) & Text (" :=")
         & Nest (Style.Continuation,
                 Line & Syn.Trees.To_Document (Item.Value, Style))
         & Text (";"));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : If_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      --  If the condition does not fit on one line, "then" goes on a line
      --  of its own, level with "if".
      Result : Syn.Documents.Document :=
                 Group (Text ("if ")
                        & Syn.Trees.To_Document (Item.Condition, Style)
                        & Line & Text ("then"))
                 & Statements (Item.Then_Part, Style);
   begin
      if not Item.Else_Part.Is_Empty then
         Result := Result & Hard_Line & Text ("else")
           & Statements (Item.Else_Part, Style);
      end if;
      return Result & Hard_Line & Text ("end if;");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Return_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      if Item.Value = null then
         return Text ("return;");
      else
         return Text ("return ") & Syn.Trees.To_Document (Item.Value, Style)
           & Text (";");
      end if;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Raise_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Result : Syn.Documents.Document :=
                 Text ("raise ")
                 & Syn.Trees.To_Document (Item.Exception_Name, Style);
   begin
      if Item.Message /= null then
         Result := Result
           & Nest (Style.Continuation,
                   Line & Text ("with ")
                   & Syn.Trees.To_Document (Item.Message, Style));
      end if;
      return Group (Result & Text (";"));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Block_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Result : Syn.Documents.Document := Empty;
   begin
      if not Item.Declarations.Is_Empty then
         Result := Text ("declare")
           & Nest (Style.Indent, Syn.Trees.Lines (Item.Declarations, Style))
           & Hard_Line;
      end if;
      return Result & Text ("begin") & Statements (Item.Statements, Style)
        & Handlers (Item.Handlers, Style)
        & Hard_Line & Text ("end;");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Handler_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Result : Syn.Documents.Document := Text ("when ");
   begin
      if Item.Choice /= Null_Unbounded_String then
         Result := Result & Text (To_String (Item.Choice) & " : ");
      end if;

      if Item.Exceptions.Is_Empty then
         Result := Result & Text ("others");
      else
         for Index in 1 .. Natural (Item.Exceptions.Length) loop
            if Index > 1 then
               Result := Result & Text (" | ");
            end if;
            Result := Result
              & Syn.Trees.To_Document (Item.Exceptions (Index), Style);
         end loop;
      end if;

      return Result & Text (" =>") & Statements (Item.Statements, Style);
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : For_Of_Loop_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Text ("for " & To_String (Item.Name) & " of ")
        & Syn.Trees.To_Document (Item.Container, Style)
        & Text (" loop")
        & Statements (Item.Statements, Style)
        & Hard_Line & Text ("end loop;");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Null_Statement_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Item, Style, Pad);
   begin
      return Text ("null;");
   end Document;

   --------------
   -- Handlers --
   --------------

   function Handlers
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document
   is
   begin
      if Items.Is_Empty then
         return Empty;
      else
         return Hard_Line & Text ("exception")
           & Nest (Style.Indent, Syn.Trees.Lines (Items, Style));
      end if;
   end Handlers;

   ----------------
   -- Statements --
   ----------------

   function Statements
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document
   is
   begin
      if Items.Is_Empty then
         return Nest (Style.Indent, Hard_Line & Text ("null;"));
      else
         return Nest (Style.Indent, Syn.Trees.Lines (Items, Style));
      end if;
   end Statements;

end Syn.Statement_Nodes;
