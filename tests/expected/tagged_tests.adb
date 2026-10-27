with Rose.Interfaces.Objects;

package body Tagged_Tests is

   ----------
   -- Area --
   ----------

   overriding function Area (Item : Square) return Natural is
   begin
      if Item.Side = 0 then
         raise Constraint_Error;
      end if;
      return Item.Side * Item.Side;
   end Area;

   -----------
   -- Check --
   -----------

   procedure Check (Value : Natural) is
   begin
      if Value > 100 then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Stream_Writer.Write: the server replied with an error";
      end if;
   end Check;

   ---------------
   -- Perimeter --
   ---------------

   not overriding function Perimeter
     (Item : Square)
      return Natural
   is (4 * Item.Side);

end Tagged_Tests;
