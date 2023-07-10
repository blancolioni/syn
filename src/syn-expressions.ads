package Syn.Expressions is

   function Operator (Name    : String;
                      Left    : Expression'Class;
                      Right   : Expression'Class)
                      return Expression'Class;

   function Operator (Name    : String;
                      Left    : Expression'Class)
                      return Expression'Class;

   function Long_Operator (Name    : String;
                           Left    : Expression'Class;
                           Right   : Expression'Class)
                           return Expression'Class;

   type Allocation_Expression is
     new Expression with private;

   overriding
   procedure Write (Item   : Allocation_Expression;
                    Writer : in out Writer_Interface'Class);

   function New_Allocation_Expression
     (Allocated_Type : String)
      return Allocation_Expression;

   procedure Add_Initialiser
     (Item  : in out Allocation_Expression'Class;
      Name  : String;
      Value : Expression'Class);

   procedure Add_Initialiser
     (Item  : in out Allocation_Expression'Class;
      Name  : String;
      Value : String);

   type Function_Call_Expression is
     new Expression with private;

   overriding
   procedure Write (Item   : Function_Call_Expression;
                    Writer : in out Writer_Interface'Class);

   function New_Function_Call_Expression
     (Procedure_Name : String)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument       : Expression'Class)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument_1     : Expression'Class;
      Argument_2     : Expression'Class)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument_1     : Expression'Class;
      Argument_2     : Expression'Class;
      Argument_3     : Expression'Class)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument_1     : Expression'Class;
      Argument_2     : Expression'Class;
      Argument_3     : Expression'Class;
      Argument_4     : Expression'Class)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument       : String)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument_1     : String;
      Argument_2     : String)
      return Function_Call_Expression;

   function New_Function_Call_Expression
     (Procedure_Name : String;
      Argument_1     : String;
      Argument_2     : String;
      Argument_3     : String)
      return Function_Call_Expression;

   procedure Add_Actual_Argument
     (Call      : in out Function_Call_Expression;
      Name      : in     String;
      Value     : in     Expression'Class);

   procedure Add_Actual_Argument
     (Call      : in out Function_Call_Expression;
      Value     : in     Expression'Class);

private

   type Initialiser is
      record
         Name : access String;
         Value : access Expression'Class;
      end record;

   package Initialiser_Lists is
     new Ada.Containers.Doubly_Linked_Lists (Initialiser);

   type Allocation_Expression is
     new Expression with
      record
         Allocated_Type : access String;
         Initialisers   : Initialiser_Lists.List;
      end record;

   type Function_Call_Expression is
     new Expression with
      record
         Name      : access String;
         Arguments : Actual_Argument_Lists.List;
      end record;

end Syn.Expressions;
