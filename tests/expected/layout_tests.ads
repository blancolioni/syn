package Layout_Tests is

   type Short_Kind is (A, B, C);

   type Capability_Type is
     (Null_Cap,
      Page_Object_Cap,
      Meta_Cap,
      Process_Cap,
      Endpoint_Cap,
      Receive_Cap,
      Interrupt_Cap,
      Kernel_Cap);

   Greeting : constant String := "Say ""hello""";

   Mask     : constant := 2#1111_0000_1111_0000#;

   Offset   : constant Integer := -42;

   Counter  : Natural;

   --  Raw text is written as it is,
   --  on as many lines as it has.

   type Empty is null record;

   procedure Reset;

   function Count return Natural;

   procedure Configure
     (Device_Name : String;
      Block_Size  : Positive := 512;
      Device      : in out Device_Type);

end Layout_Tests;
