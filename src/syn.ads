--  Syn generates Ada source code. A program builds a tree of Ada
--  constructs with a Syn.Factory.Factory, and Syn.Units lays the tree
--  out and writes it to files.

package Syn is

   type Node is abstract tagged limited private;
   --  An Ada construct. Nodes are created and owned by a factory, and
   --  cannot be changed once created.

   type Node_Access is access all Node'Class;

   type Node_Array is array (Positive range <>) of not null Node_Access;

   No_Nodes : constant Node_Array;

   type Parameter_Mode is (In_Mode, Out_Mode, In_Out_Mode);

   type Overriding_Kind is (No_Indicator, Is_Overriding, Is_Not_Overriding);
   --  The indicator before a subprogram declaration or body: none,
   --  "overriding", or "not overriding".

private

   type Node is abstract tagged limited null record;

   No_Nodes : constant Node_Array (1 .. 0) := [];

end Syn;
