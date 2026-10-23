with Rose.Objects;

package Rose.Interfaces.Timer is

   Max_Timers         : constant := 64;

   Timer_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#3D3E_F48A_496A#;

   Set_Timer_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#D25E_5101_0B66#;

end Rose.Interfaces.Timer;
