with Rose.Capabilities;
with Rose.Invocation;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Body_Tests is

   type Block_Size_Type is range 0 .. 4096;

   type Block_Address_Type is new Rose.Words.Word_64;

   type Callback is access procedure (Code : Natural);

   type Set_Timer_Handler is access function
     (Id           : Rose.Objects.Capability_Identifier;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   Set_Timer_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#D25E_5101_0B66#;

   Server_Instance    : Rose.Server.Server_Instance;

   function Count return Natural;

   function Is_Ready (Item : Natural) return Boolean;

   procedure Register (Context : in out Rose.Server.Server_Context);

   procedure Reset;

end Body_Tests;
