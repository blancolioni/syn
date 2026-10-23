package Syn.Names is

   function File_Name (Unit_Name : String; Is_Spec : Boolean) return String;
   --  GNAT's file name for a unit: the unit name in lower case, with each
   --  "." replaced by "-", and ".ads" for a specification or ".adb" for a
   --  body. For example, Core_Utilities.Echo gives core_utilities-echo.ads.

end Syn.Names;
