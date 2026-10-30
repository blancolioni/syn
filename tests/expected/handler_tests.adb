with Rose.Invocation;
with Rose.System_Calls;

package body Handler_Tests is

   --------------
   -- Dispatch --
   --------------

   procedure Dispatch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Count : Natural;
   begin
      Count := Rose.System_Calls.Count (Parameters);
   exception
      when others =>
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Unknown_Error);
   end Dispatch;

   -------------
   -- Guarded --
   -------------

   procedure Guarded (Parameters : in out Rose.Invocation.Invocation_Record) is
   begin
      declare
         Count : Natural;
      begin
         Count := Rose.System_Calls.Count (Parameters);
      exception
         when Error : Constraint_Error | Program_Error =>
            Rose.System_Calls.Send_Error (Parameters, Rose.Invocation.Closed);
         when others =>
            raise Program_Error;
      end;
   end Guarded;

end Handler_Tests;
