with Syn.Style;

package Syn.Units is

   --  Laying out and writing compilation units. Each operation raises
   --  Constraint_Error if Unit is not a compilation unit.

   function To_Text
     (Unit  : not null Node_Access;
      Style : Syn.Style.Settings := Syn.Style.Default)
      return String;
   --  The source text of Unit, ending with a line feed.

   function File_Name (Unit : not null Node_Access) return String;
   --  The file GNAT expects Unit to be in, such as
   --  rose-interfaces-timer.ads.

   procedure Write
     (Unit      : not null Node_Access;
      Directory : String;
      Style     : Syn.Style.Settings := Syn.Style.Default);
   --  Write the source text of Unit to File_Name (Unit) in Directory,
   --  replacing any file already there.

end Syn.Units;
