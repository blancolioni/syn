with Rose.Capabilities;
with Rose.Interfaces.Restorable;
with Rose.Interfaces.Stream_Writer;
with Rose.Objects;
limited with Rose.Interfaces.File;

package Tagged_Tests is

   type Shape is limited interface;

   function Area (Item : Shape) return Natural is abstract;

   procedure Scale (Item : in out Shape; Factor : Positive) is abstract;

   procedure Listen
     (Item     : in out Shape;
      Listener : in out
        Rose.Interfaces.Event_Listener.Event_Listener_Object'Class)
   is abstract;

   function Window_Cap
     (Item   : in out Shape;
      Window : in out Rose.Interfaces.Window.Window_Object'Class)
      return Rose.Capabilities.Capability is abstract;

   function Shape_Cap
     (Item         : in out Shape;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Stream_Writer.Stream_Writer_Interface)
      return Rose.Capabilities.Capability is abstract;

   type Labelled is limited interface and Shape;

   type Stream_Writer_Interface is limited interface
     and Rose.Interfaces.Stream_Writer.Stream_Writer_Object
     and Rose.Interfaces.Restorable.Restorable_Object;

   type Square is new Shape with private;

   type Stream_Writer_Client is
     limited new Rose.Interfaces.Stream_Writer.Stream_Writer_Object
     and Rose.Interfaces.Restorable.Restorable_Object
     with private;

   overriding function Area (Item : Square) return Natural;

   not overriding function Perimeter (Item : Square) return Natural;

   procedure Check (Value : Natural);

   type Shape_Access is access all Shape'Class;

   type Shape_Reference is access constant Shape'Class;

   type Square_Pointer is access Square;

   type Shape_Table is array (0 .. 15) of Shape_Access;

   type Writer_Table is
     array (Rose.Objects.Capability_Identifier)
     of Rose.Interfaces.Stream_Writer.Stream_Writer_Object_Access;

private

   type Square is new Shape with record
      Side : Natural := 0;
   end record;

   type Stream_Writer_Client is
     limited new Rose.Interfaces.Stream_Writer.Stream_Writer_Object
     and Rose.Interfaces.Restorable.Restorable_Object
   with record
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

   type Marker is new Shape with null record;

end Tagged_Tests;
