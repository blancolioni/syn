package Syn.Blocks is

   type Block_Type is
     new Syntax_Root
     and Statement_Sequencer
   with private;

   overriding
   procedure Write (Item        : Block_Type;
                    Writer      : in out Writer_Interface'Class);

   procedure Add_Declaration
     (Block : in out Block_Type;
      Item  : in     Declaration'Class);

   procedure Add_Statement
     (Block : in out Block_Type;
      Item  : in     Statement'Class);

   procedure Add_Statement
     (Block : in out Block_Type;
      Item  : in     String);

   overriding
   procedure Append
     (Block : in out Block_Type;
      Item  : in     Statement'Class)
      renames Add_Statement;

   function Create_Block
     (Item : Statement'Class)
      return Block_Type'Class;

   function Create_Block
     (Item : Statement_Sequencer'Class)
      return Block_Type'Class;

private

   type Block_Type is
     new Syntax_Root
     and Statement_Sequencer
   with
      record
         Declarations : Declaration_Vectors.Vector;
         Statements   : Statement_Vectors.Vector;
      end record;

   overriding procedure Iterate
     (Block   : Block_Type;
      Process : not null access
        procedure (S : Statement'Class));

end Syn.Blocks;
