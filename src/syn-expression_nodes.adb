with Ada.Characters.Latin_1;

package body Syn.Expression_Nodes is

   use Syn.Documents;

   --  Operator precedence, from Ada's lowest (logical operators) to
   --  highest; names, literals and calls are primaries.

   Logical_Level        : constant := 1;
   Relational_Level     : constant := 2;
   Adding_Level         : constant := 3;
   Multiplying_Level    : constant := 4;
   Highest_Level        : constant := 5;
   Primary_Level        : constant := 6;

   function Operator_Level (Operator : String) return Positive;
   --  The precedence level of a binary operator.

   function Level (Item : not null Node_Access) return Positive;
   --  The precedence level of the expression Item.

   function Operand
     (Item          : not null Node_Access;
      Style         : Syn.Style.Settings;
      Parenthesized : Boolean)
      return Syn.Documents.Document;
   --  Item, in parentheses if Parenthesized.

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Text_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Source : constant String := To_String (Item.Text);
      Result : Syn.Documents.Document := Syn.Documents.Empty;
      Start  : Positive := Source'First;

      function Is_Dotted_Name return Boolean;
      --  True if Source is an identifier or a name of identifiers
      --  separated by dots, and not a literal.

      --------------------
      -- Is_Dotted_Name --
      --------------------

      function Is_Dotted_Name return Boolean is
      begin
         if Source'Length = 0
           or else Source (Source'First) not in 'A' .. 'Z' | 'a' .. 'z'
         then
            return False;
         end if;

         for Ch of Source loop
            if Ch not in 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_' | '.'
            then
               return False;
            end if;
         end loop;
         return True;
      end Is_Dotted_Name;

   begin
      if not Is_Dotted_Name then
         return Text (Source);
      end if;

      --  A dotted name can break before each dot. The groups nest to the
      --  left, so the outermost group holds the last dot: a name that
      --  doesn't fit breaks before its last selector first, and before
      --  earlier ones only if it still doesn't fit.

      for Index in Source'Range loop
         if Source (Index) = '.' then
            if Result = Syn.Documents.Empty then
               Result := Text (Source (Start .. Index - 1));
            else
               Result :=
                 Group
                   (Result
                    & Nest (Style.Continuation,
                            Soft_Line & Text (Source (Start .. Index - 1))));
            end if;
            Start := Index;
         end if;
      end loop;

      if Result = Syn.Documents.Empty then
         return Text (Source);
      end if;

      return Group
        (Result
         & Nest (Style.Continuation,
                 Soft_Line & Text (Source (Start .. Source'Last))));
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

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Call_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Arguments : Syn.Documents.Document := Empty;
   begin
      for Argument of Item.Arguments loop
         if Arguments /= Empty then
            Arguments := Arguments & Text (",") & Line;
         end if;
         Arguments := Arguments & Syn.Trees.To_Document (Argument, Style);
      end loop;

      return Group
        (Syn.Trees.To_Document (Item.Prefix, Style)
         & Nest (Style.Continuation,
                 Line & Text ("(") & Align (Arguments) & Text (")")));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Binary_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Operator : constant String := To_String (Item.Operator);
      Own      : constant Positive := Operator_Level (Operator);

      function Mixed_Logical (Side : not null Node_Access) return Boolean
      is (Own = Logical_Level
          and then Level (Side) = Logical_Level
          and then To_String (Binary_Node'Class (Side.all).Operator)
                     /= Operator);
      --  Ada does not allow different logical operators to be mixed
      --  without parentheses, as in A and B or C.

   begin
      --  Operators are left associative, so a left operand at the same
      --  level needs no parentheses, but a right operand does.
      return Operand
               (Item.Left, Style,
                Level (Item.Left) < Own or else Mixed_Logical (Item.Left))
        & Text (" " & Operator & " ")
        & Operand (Item.Right, Style, Level (Item.Right) <= Own);
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Unary_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Operator : constant String := To_String (Item.Operator);
   begin
      --  A word operator such as "not" or "abs" is followed by a space;
      --  a symbol such as "-" is not. Any operand that is itself an
      --  operator expression is parenthesized: not (A = B).
      return Text (Operator
                   & (if Operator in "-" | "+" then "" else " "))
        & Operand (Item.Operand, Style,
                   Level (Item.Operand) < Primary_Level);
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Attribute_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Syn.Trees.To_Document (Item.Prefix, Style)
        & Text ("'" & To_String (Item.Attribute));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Named_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Text (To_String (Item.Name) & " =>")
         & Nest (Style.Continuation,
                 Line & Syn.Trees.To_Document (Item.Value, Style)));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Concatenation_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Result : Syn.Documents.Document := Empty;
   begin
      for Part of Item.Parts loop
         if Result /= Empty then
            Result := Result & Line & Text ("& ");
         end if;
         Result := Result
           & Operand (Part, Style, Level (Part) <= Adding_Level);
      end loop;
      return Group (Align (Result));
   end Document;

   -----------
   -- Level --
   -----------

   function Level (Item : not null Node_Access) return Positive is
   begin
      if Item.all in Binary_Node'Class then
         return Operator_Level
           (To_String (Binary_Node'Class (Item.all).Operator));
      elsif Item.all in Concatenation_Node'Class then
         return Adding_Level;
      elsif Item.all in Unary_Node'Class then
         return (if To_String (Unary_Node'Class (Item.all).Operator)
                      in "-" | "+"
                 then Adding_Level
                 else Highest_Level);
      else
         return Primary_Level;
      end if;
   end Level;

   -------------
   -- Operand --
   -------------

   function Operand
     (Item          : not null Node_Access;
      Style         : Syn.Style.Settings;
      Parenthesized : Boolean)
      return Syn.Documents.Document
   is
   begin
      if Parenthesized then
         return Text ("(") & Syn.Trees.To_Document (Item, Style)
           & Text (")");
      else
         return Syn.Trees.To_Document (Item, Style);
      end if;
   end Operand;

   --------------------
   -- Operator_Level --
   --------------------

   function Operator_Level (Operator : String) return Positive is
   begin
      if Operator in "and" | "or" | "xor" | "and then" | "or else" then
         return Logical_Level;
      elsif Operator in "=" | "/=" | "<" | "<=" | ">" | ">=" | "in" | "not in"
      then
         return Relational_Level;
      elsif Operator in "+" | "-" | "&" then
         return Adding_Level;
      elsif Operator in "*" | "/" | "mod" | "rem" then
         return Multiplying_Level;
      else
         return Highest_Level;
      end if;
   end Operator_Level;

end Syn.Expression_Nodes;
