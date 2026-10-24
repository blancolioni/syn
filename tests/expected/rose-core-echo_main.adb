with Rose.Command_Line.Launch;
with Rose.Core.Echo;

procedure Rose.Core.Echo_Main is
   Call : Rose.Command_Line.Launch.Launch_Call;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Core.Echo
     (New_Line => Rose.Command_Line.Launch.Boolean_Argument (Call, 0));
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Echo_Main;
