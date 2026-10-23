with Rose.Capabilities;
with Rose.Invocation;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Body_Tests is

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
