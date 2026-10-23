package body Syn.Declaration_Nodes is

   use Syn.Documents;

   function Declarative_Part
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document;
   --  Items, one per line with a blank line between each, indented one
   --  level, with their defining names aligned.

   function Documents
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings;
      Pad   : Natural)
      return Document_Array;

   function Mode_Text (Mode : Parameter_Mode) return String;

   function Padding
     (Name : String;
      Pad  : Natural)
      return Syn.Documents.Document;
   --  The spaces that pad Name to Pad columns, if it is shorter.

   ----------------------
   -- Declarative_Part --
   ----------------------

   function Declarative_Part
     (Items : Syn.Trees.Node_Vectors.Vector;
      Style : Syn.Style.Settings)
      return Syn.Documents.Document
   is
      Pad    : constant Natural := Syn.Trees.Max_Defining_Width (Items);
      Result : Syn.Documents.Document := Empty;
   begin
      for Item of Items loop
         Result := Result & Hard_Line & Hard_Line
           & Syn.Trees.To_Document (Item, Style, Pad);
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
      return Text ("with " & To_String (Item.Unit_Name) & ";");
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

      Result := Result & Declarative_Part (Item.Public_Part, Style);

      if not Item.Private_Part.Is_Empty then
         Result := Result & Hard_Line & Hard_Line & Text ("private")
           & Declarative_Part (Item.Private_Part, Style);
      end if;

      return Result & Hard_Line & Hard_Line & Text ("end " & Name & ";");
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

      declare
         Width  : constant Natural :=
                    Syn.Trees.Max_Defining_Width (Item.Components);
         Fields : Syn.Documents.Document := Empty;
      begin
         for Component of Item.Components loop
            Fields := Fields & Hard_Line
              & Syn.Trees.To_Document (Component, Style, Width);
         end loop;

         return Text ("type " & Name & " is record")
           & Nest (Style.Indent, Fields)
           & Hard_Line & Text ("end record;");
      end;
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
      Result : Syn.Documents.Document :=
                 Text (Name)
                 & If_Flat (Empty, Padding (Name, Pad))
                 & Text (" : " & Mode_Text (Item.Mode))
                 & Syn.Trees.To_Document (Item.Parameter_Type, Style);
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
      Is_Function : constant Boolean := Item.Result_Type /= null;
      Result      : Syn.Documents.Document :=
                      Text ((if Is_Function then "function " else "procedure ")
                            & To_String (Item.Name));
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

      return Group (Result & Text (";"));
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

end Syn.Declaration_Nodes;
