with Rose.System_Calls;

package body Body_Tests is

   Counter : Natural := 0;

   Params  : aliased Rose.Invocation.Invocation_Record;

   Summary : constant String :=
     "Writes each argument to standard output, "
     & "separated by single spaces."
     & ASCII.LF;

   procedure Handle (Parameters : in out Rose.Invocation.Invocation_Record);

   -----------
   -- Count --
   -----------

   function Count return Natural is (Counter);

   ------------
   -- Handle --
   ------------

   procedure Handle (Parameters : in out Rose.Invocation.Invocation_Record) is
      use Rose.Capabilities;
      Cap        : Capability;
      Name       : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Counter = 0 then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Set_Timer_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Set_Timer_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Set_Timer_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Set_Timer_Endpoint,
              Identifier);
      else
         Cap := Null_Capability;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle;

   --------------
   -- Is_Ready --
   --------------

   function Is_Ready (Item : Natural) return Boolean is
   begin
      declare
         Twice : constant Natural := Item * 2;
      begin
         return Twice > 4 and then not (Counter = Item);
      end;
   end Is_Ready;

   --------------
   -- Register --
   --------------

   procedure Register (Context : in out Rose.Server.Server_Context) is
   begin
      Rose.Server.Register_Handler
        (Context,
         Set_Timer_Endpoint,
         Handle'Access);
      Rose.Core.Echo
        (New_Line => Rose.Command_Line.Launch.Boolean_Argument (Call, 0),
         Arguments => Arguments);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Counter := Counter + 1;
   end Register;

   -----------
   -- Reset --
   -----------

   procedure Reset is
   begin
      null;
   end Reset;

end Body_Tests;
