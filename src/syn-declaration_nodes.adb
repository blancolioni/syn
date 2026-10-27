with Ada.Strings.Fixed;

with Syn.Statement_Nodes;

package body Syn.Declaration_Nodes is

   use Syn.Documents;

   function Declarative_Part
     (Items   : Syn.Trees.Node_Vectors.Vector;
      Style   : Syn.Style.Settings;
      Headers : Boolean)
      return Syn.Documents.Document;
   --  Items, one per line with a blank line between each, indented one
   --  level, with their defining names aligned. If Headers is True, each
   --  subprogram body is preceded by a header comment with its name.

   function Documents
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Document_Array;

   function Header (Name : String) return Syn.Documents.Document;
   --  The GNAT-style comment box before a subprogram body:
   --
   --     ----------
   --     -- Name --
   --     ----------

   function Mode_Text (Mode : Parameter_Mode) return String;

   function Padding
     (Name : String;
      Pad  : Natural)
      return Syn.Documents.Document;
   --  The spaces that pad Name to Pad columns, if it is shorter.

   function Profile
     (Item  : Subprogram_Node'Class;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document;
   --  The specification of Item, without the final ";" or "is", and not
   --  grouped, so the caller can add an ending in the same group.

   ---------------
   -- Body_Name --
   ---------------

   overriding function Body_Name
     (Item : Subprogram_Body_Node)
      return String
   is (To_String (Subprogram_Node'Class (Item.Specification.all).Name));

   ---------------
   -- Body_Name --
   ---------------

   overriding function Body_Name
     (Item : Expression_Function_Node)
      return String
   is (To_String (Subprogram_Node'Class (Item.Specification.all).Name));

   ----------------------
   -- Declarative_Part --
   ----------------------

   function Declarative_Part
     (Items   : Syn.Trees.Node_Vectors.Vector;
      Style   : Syn.Style.Settings;
      Headers : Boolean)
      return Syn.Documents.Document
   is
      Pad    : constant Natural := Syn.Trees.Max_Defining_Width (Items);
      Result : Syn.Documents.Document := Empty;
   begin
      for Item of Items loop
         Result := Result & Hard_Line & Hard_Line;
         if Headers and then Syn.Trees.Body_Name (Item) /= "" then
            Result := Result & Header (Syn.Trees.Body_Name (Item))
              & Hard_Line & Hard_Line;
         end if;
         Result := Result & Syn.Trees.To_Document (Item, Style, Pad);
      end loop;
      return Nest (Style.Indent, Result);
   end Declarative_Part;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : With_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Style, Pad);
   begin
      return Text
        ((if Item.Is_Limited then "limited " else "")
         & "with " & To_String (Item.Unit_Name) & ";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Use_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Style, Pad);
   begin
      return Text ((if Item.Use_Type then "use type " else "use ")
                   & To_String (Item.Name) & ";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Package_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Name   : constant String := To_String (Item.Name);
      Result : Syn.Documents.Document := Text ("package " & Name & " is");
   begin
      if Item.Public_Part.Is_Empty and then Item.Private_Part.Is_Empty then
         return Result & Hard_Line & Text ("end " & Name & ";");
      end if;

      Result := Result & Declarative_Part (Item.Public_Part, Style, False);

      if not Item.Private_Part.Is_Empty then
         Result := Result & Hard_Line & Hard_Line & Text ("private")
           & Declarative_Part (Item.Private_Part, Style, False);
      end if;

      return Result & Hard_Line & Hard_Line & Text ("end " & Name & ";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Package_Body_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Name : constant String := To_String (Item.Name);
   begin
      if Item.Declarations.Is_Empty then
         return Text ("package body " & Name & " is")
           & Hard_Line & Text ("end " & Name & ";");
      end if;

      return Text ("package body " & Name & " is")
        & Declarative_Part (Item.Declarations, Style, True)
        & Hard_Line & Hard_Line & Text ("end " & Name & ";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Object_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      Name   : constant String := To_String (Item.Name);
      Result : Syn.Documents.Document :=
                 Text (Name) & Padding (Name, Pad) & Text (" : ");
   begin
      if Item.Is_Aliased then
         Result := Result & Text ("aliased ");
      end if;

      if Item.Is_Constant then
         Result := Result & Text ("constant");
         if Item.Object_Type /= null then
            Result := Result & Text (" ");
         end if;
      end if;

      if Item.Object_Type /= null then
         Result := Result
           & Syn.Trees.To_Document (Item.Object_Type, Style);
      end if;

      if Item.Initial_Value /= null then
         Result := Result & Text (" :=")
           & Nest (Style.Continuation,
                   Line & Syn.Trees.To_Document (Item.Initial_Value, Style));
      end if;

      if not Item.Aspects.Is_Empty then
         Result := Result
           & Nest (Style.Continuation,
                   Line & Text ("with ")
                   & Group (Align (Join (Documents (Item.Aspects, Style, 0),
                                         Text (",") & Line))));
      end if;

      return Group (Result & Text (";"));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Enumeration_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Text ("type " & To_String (Item.Name) & " is")
         & Nest (Style.Continuation,
                 Line & Text ("(")
                 & Align (Group (Join (Documents (Item.Literals, Style, 0),
                                       Text (",") & Line)))
                 & Text (");")));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Aspect_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      if Item.Definition = null then
         return Text (To_String (Item.Name));
      else
         return Text (To_String (Item.Name) & " => ")
           & Syn.Trees.To_Document (Item.Definition, Style);
      end if;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Range_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Text ("type " & To_String (Item.Name) & " is")
         & Nest (Style.Continuation,
                 Line & Text ("range ")
                 & Syn.Trees.To_Document (Item.Low, Style)
                 & Text (" .. ")
                 & Syn.Trees.To_Document (Item.High, Style)
                 & Text (";")));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Derived_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Text ("type " & To_String (Item.Name) & " is")
         & Nest (Style.Continuation,
                 Line & Text ("new ")
                 & Syn.Trees.To_Document (Item.Parent, Style)
                 & Text (";")));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Private_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Style, Pad);
   begin
      return Text ("type " & To_String (Item.Name) & " is private;");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Record_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Name : constant String := To_String (Item.Name);
   begin
      if Item.Components.Is_Empty then
         return Text ("type " & Name & " is null record;");
      end if;

      return Text ("type " & Name & " is record")
        & Nest (Style.Indent, Syn.Trees.Lines (Item.Components, Style))
        & Hard_Line & Text ("end record;");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Interface_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Header : constant String :=
                 "type " & To_String (Item.Name) & " is "
                 & (if Item.Is_Limited then "limited " else "")
                 & "interface";
      Parents : Syn.Documents.Document := Empty;
   begin
      if Item.Parents.Is_Empty then
         return Text (Header & ";");
      end if;

      for Parent of Item.Parents loop
         Parents := Parents & Line & Text ("and ")
           & Syn.Trees.To_Document (Parent, Style);
      end loop;

      return Group (Text (Header) & Nest (Style.Continuation, Parents)
                    & Text (";"));
   end Document;

   --------------
   -- Document --
   --------------

   --  On one line if it fits:
   --
   --     type Name is limited new Parent and Other with private;
   --
   --  and otherwise with the parent, each interface and the rest of the
   --  declaration on lines of their own; a record extension's components
   --  are always on lines of their own:
   --
   --     type Name is
   --       limited new Parent
   --       and Other
   --     with record
   --        Component : Component_Type;
   --     end record;

   overriding function Document
     (Item  : Extension_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Ancestry : Syn.Documents.Document :=
                   Line
                   & Text ((if Item.Is_Limited then "limited " else "")
                           & "new ")
                   & Syn.Trees.To_Document (Item.Parent, Style);
      Header   : Syn.Documents.Document;
   begin
      for Interface_Item of Item.Interfaces loop
         Ancestry := Ancestry & Line & Text ("and ")
           & Syn.Trees.To_Document (Interface_Item, Style);
      end loop;

      Header := Text ("type " & To_String (Item.Name) & " is")
        & Nest (Style.Continuation, Ancestry);

      if Item.Kind = Private_Extension then
         return Group
           (Header & Nest (Style.Continuation, Line & Text ("with private;")));
      elsif Item.Components.Is_Empty then
         return Group
           (Header
            & Nest (Style.Continuation, Line & Text ("with null record;")));
      else
         return Group (Header & Line & Text ("with record"))
           & Nest (Style.Indent, Syn.Trees.Lines (Item.Components, Style))
           & Hard_Line & Text ("end record;");
      end if;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Access_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Kind : constant String :=
               (case Item.Kind is
                   when Pool_Access     => "access ",
                   when All_Access      => "access all ",
                   when Constant_Access => "access constant ");
   begin
      return Group
        (Text ("type " & To_String (Item.Name) & " is")
         & Nest (Style.Continuation,
                 Line & Text (Kind)
                 & Syn.Trees.To_Document (Item.Designated, Style)
                 & Text (";")));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Array_Type_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Text ("type " & To_String (Item.Name) & " is")
         & Nest (Style.Continuation,
                 Line
                 & Group (Text ("array (")
                          & Syn.Trees.To_Document (Item.Index, Style)
                          & Text (")") & Line & Text ("of ")
                          & Syn.Trees.To_Document (Item.Component, Style)
                          & Text (";"))));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Parameter_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      Name   : constant String := To_String (Item.Name);
      Mode   : constant String := Mode_Text (Item.Mode);
      Result : Syn.Documents.Document :=
                 Text (Name)
                 & If_Flat (Empty, Padding (Name, Pad))
                 & Text (" :"
                         & (if Mode = ""
                            then ""
                            else " " & Mode (Mode'First .. Mode'Last - 1)))
                 & Group
                     (Nest (Style.Continuation,
                            Line
                            & Syn.Trees.To_Document
                                (Item.Parameter_Type, Style)));
      --  A type that does not fit after the mode goes on the next line.
   begin
      if Item.Default /= null then
         Result := Result & Text (" := ")
           & Syn.Trees.To_Document (Item.Default, Style);
      end if;
      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Subprogram_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      if Item.Is_Abstract then
         --  "is abstract" goes on a line of its own if it does not fit
         --  after the profile.
         return Group
           (Profile (Item, Style)
            & Group (Line & Text ("is abstract;")));
      else
         return Group (Profile (Item, Style) & Text (";"));
      end if;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Subprogram_Body_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
      Specification : Subprogram_Node'Class renames
                        Subprogram_Node'Class (Item.Specification.all);
   begin
      return Group (Profile (Specification, Style)
                    & If_Flat (Text (" is"), Line & Text ("is")))
        & Nest (Style.Indent, Syn.Trees.Lines (Item.Declarations, Style))
        & Hard_Line & Text ("begin")
        & Syn.Statement_Nodes.Statements (Item.Statements, Style)
        & Hard_Line
        & Text ("end " & To_String (Specification.Name) & ";");
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Item  : Expression_Function_Node;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Syn.Documents.Document
   is
      pragma Unreferenced (Pad);
   begin
      return Group
        (Profile (Subprogram_Node'Class (Item.Specification.all), Style)
         & If_Flat (Text (" is ("), Line & Text ("is ("))
         & Syn.Trees.To_Document (Item.Expression, Style)
         & Text (");"));
   end Document;

   ---------------
   -- Documents --
   ---------------

   function Documents
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Document_Array
   is
   begin
      return Result : Document_Array (1 .. Natural (Items.Length)) do
         for Index in Result'Range loop
            Result (Index) :=
              Syn.Trees.To_Document (Items (Index), Style, Pad);
         end loop;
      end return;
   end Documents;

   ------------
   -- Header --
   ------------

   function Header (Name : String) return Syn.Documents.Document is
      Rule : constant String := Ada.Strings.Fixed."*" (Name'Length + 6, '-');
   begin
      return Text (Rule) & Hard_Line
        & Text ("-- " & Name & " --") & Hard_Line
        & Text (Rule);
   end Header;

   ---------------
   -- Mode_Text --
   ---------------

   function Mode_Text (Mode : Parameter_Mode) return String
   is (case Mode is
          when In_Mode     => "",
          when Out_Mode    => "out ",
          when In_Out_Mode => "in out ");

   -------------
   -- Padding --
   -------------

   function Padding
     (Name : String;
      Pad  : Natural)
      return Syn.Documents.Document
   is (Spaces (Natural'Max (0, Pad - Name'Length)));

   -------------
   -- Profile --
   -------------

   function Profile
     (Item  : Subprogram_Node'Class;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document
   is
      Is_Function : constant Boolean := Item.Result_Type /= null;
      Kind        : constant String :=
                      (if Is_Function then "function" else "procedure");
      Indicator   : constant String :=
                      (case Item.Indicator is
                          when No_Indicator      => "",
                          when Is_Overriding     => "overriding ",
                          when Is_Not_Overriding => "not overriding ");
      Result      : Syn.Documents.Document :=
                      (if Length (Item.Access_Type_Name) > 0
                       then Text ("type " & To_String (Item.Access_Type_Name)
                                  & " is access " & Kind)
                       else Text (Indicator & Kind & " "
                                  & To_String (Item.Name)));
   begin
      if not Item.Parameters.Is_Empty then
         Result := Result
           & Nest (Style.Continuation,
                   Line & Text ("(")
                   & Align
                       (Join
                          (Documents
                             (Item.Parameters, Style,
                              Syn.Trees.Max_Defining_Width (Item.Parameters)),
                           Text (";") & Line))
                   & Text (")"));
      end if;

      if Is_Function then
         Result := Result
           & Nest (Style.Continuation + 1,
                   Line & Text ("return ")
                   & Syn.Trees.To_Document (Item.Result_Type, Style));
      end if;

      return Result;
   end Profile;

end Syn.Declaration_Nodes;
