with Ada.Characters.Handling;

package body Syn.Names is

   ---------------
   -- File_Name --
   ---------------

   function File_Name (Unit_Name : String; Is_Spec : Boolean) return String
   is
      Result : String := Ada.Characters.Handling.To_Lower (Unit_Name);
   begin
      for Ch of Result loop
         if Ch = '.' then
            Ch := '-';
         end if;
      end loop;
      return Result & (if Is_Spec then ".ads" else ".adb");
   end File_Name;

end Syn.Names;
