with Rose.Capabilities;
with Rose.Interfaces.Cap.Client;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Timer.Client is

   type Timer_Client is private;

   procedure Open
     (Client        : out Timer_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Timer_Client);

   function Set_Timer
     (Item         : Timer_Client;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Interfaces.Cap.Client.Cap_Client;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Timer_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability := 0;
      Set_Timer     : Rose.Capabilities.Capability := 0;
   end record;

end Rose.Interfaces.Timer.Client;
