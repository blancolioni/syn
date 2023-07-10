with Ada.Containers.Doubly_Linked_Lists;

with Syn.Declarations;

package Syn.Types is

   function New_Range_Definition
     (Low, High : String)
      return Type_Definition'Class;

   function New_Subprogram_Type_Definition
     (Signature : Syn.Declarations.Subprogram_Declaration'Class)
      return Type_Definition'Class;

   type Record_Type_Definition is
     new Interface_Type_Definition with private;

   overriding
   function Has_Variant (Item : Record_Type_Definition) return Boolean;

   overriding
   function Variant_Name (Item : Record_Type_Definition) return String;

   overriding
   function Variant_Type (Item : Record_Type_Definition) return String;

   overriding
   function Variant_Default (Item : Record_Type_Definition) return String;

   overriding
   function Is_Tagged (Item : Record_Type_Definition) return Boolean;

   overriding procedure Add_Parent
     (Item : in out Record_Type_Definition;
      Name : in     String);

   procedure Add_Component
     (To_Record      : in out Record_Type_Definition'Class;
      Component_Name : in String;
      Component_Type : in Subtype_Indication'Class;
      Is_Access      : in Boolean := False;
      Is_Constant    : in Boolean := False)
     with Pre => Is_Access or else not Is_Constant;

   procedure Add_Component
     (To_Record      : in out Record_Type_Definition'Class;
      Component_Name : in String;
      Component_Type : in String;
      Is_Access      : in Boolean := False;
      Is_Constant    : in Boolean := False)
     with Pre => Is_Access or else not Is_Constant;

   procedure Add_Component
     (To_Record         : in out Record_Type_Definition'Class;
      Component_Name    : in String;
      Component_Type    : in String;
      Component_Default : in String);

   procedure Add_Component
     (To_Record         : in out Record_Type_Definition'Class;
      Component_Name    : in String;
      Component_Type    : in Subtype_Indication'Class;
      Component_Default : in Expression'Class);

   procedure Add_Variant
     (To_Record         : in out Record_Type_Definition'Class;
      Variant_Name      : in     String;
      Variant_Type      : in     String;
      Variant_Default   : in     String  := "");

   procedure Start_Case (Rec   : in out Record_Type_Definition'Class;
                         Value : in     String);
   procedure Next_Case_Option (Rec   : in out Record_Type_Definition'Class;
                               Value : in     String);
   procedure End_Case (Rec : in out Record_Type_Definition'Class);

   procedure Set_Abstract (Rec : in out Record_Type_Definition'Class);
   procedure Set_Tagged (Rec : in out Record_Type_Definition'Class);
   procedure Set_Visible_Derivation
     (Rec : in out Record_Type_Definition'Class);

   overriding
   procedure Write (Item        : Record_Type_Definition;
                    Writer      : in out Writer_Interface'Class);

private

   type Record_Component is
      record
         Component_Case_Value  : access String;
         Component_Name        : access String;
         Component_Type        : access Subtype_Indication'Class;
         Component_Default     : access Expression'Class;
         Component_Is_Access   : Boolean;
         Component_Is_Constant : Boolean;
      end record;

   package Record_Component_List is
     new Ada.Containers.Doubly_Linked_Lists (Record_Component);

   type Record_Type_Definition is
     new Interface_Type_Definition with
      record
         Variant            : Boolean := False;
         Variant_Name       : access String;
         Variant_Type       : access String;
         Variant_Default    : access String;
         Current_Case_Value : access String;
         Case_Values        : String_Vector.Vector;
         Case_Level         : Natural := 0;
         Components         : Record_Component_List.List;
         Is_Tagged          : Boolean := False;
      end record;

end Syn.Types;
