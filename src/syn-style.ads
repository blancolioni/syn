--  Layout settings. The defaults match GNAT's own style.

package Syn.Style is

   type Settings is record
      Width        : Positive := 79;
      --  Lines are broken to fit this many columns where possible.

      Indent       : Positive := 3;
      --  Indentation of nested declarations and statements.

      Continuation : Positive := 2;
      --  Indentation of a continuation line, relative to the start of
      --  the construct it continues.
   end record;

   Default : constant Settings := (others => <>);

end Syn.Style;
