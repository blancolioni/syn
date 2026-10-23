package body Syn.Trees is

   ------------------------
   -- Max_Defining_Width --
   ------------------------

   function Max_Defining_Width (Items : Node_Vectors.Vector) return Natural
   is
      Result : Natural := 0;
   begin
      for Item of Items loop
         Result := Natural'Max (Result, Defining_Width (Item));
      end loop;
      return Result;
   end Max_Defining_Width;

   ---------------
   -- To_Vector --
   ---------------

   function To_Vector (Items : Node_Array) return Node_Vectors.Vector is
   begin
      return Result : Node_Vectors.Vector do
         for Item of Items loop
            Result.Append (Item);
         end loop;
      end return;
   end To_Vector;

end Syn.Trees;
