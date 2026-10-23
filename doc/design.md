# Syn: design

Syn is a library for generating Ada source code from a program. You build a tree of Ada constructs, and Syn lays it out and writes the files. Its first user will be `idle`, the new interface definition language compiler for [Rose](https://github.com/blancolioni/rose) (rose#136).

This version replaces [syn-legacy](https://github.com/blancolioni/syn-legacy). It keeps what worked there, takes its programming interface from [ada-pretty](https://github.com/reznikmm/ada-pretty), and fixes the gaps found when ada-pretty was tried as a generator for `idle` (rose#136).

## Goals

- **Plain `String`.** Names, literals and comments are ordinary Ada strings.
- **No dependencies** beyond the GNAT runtime, so that a tool using Syn builds with `alr build` and nothing else.
- **A tree, built through a factory.** Programs describe *what* to generate; Syn decides *how* it is laid out.
- **Output that compiles under strict style checks.** Generated code passes GNAT's `-gnaty` style checks and `-gnatwe` without the caller doing anything special.
- **One model, two files.** A package is described once, and Syn writes both its specification and its body.
- **Published on Alire** from the first release.

## Non-goals

- Parsing Ada, or reformatting existing source. Syn only generates.
- Checking that the generated code is legal Ada. Syn checks the shape of the tree (a statement where a statement belongs), not name resolution or types.
- Writing GNAT project files. syn-legacy could (`Syn.Projects`); tools that need project files write them themselves.

## Lessons from syn-legacy

- **Keep: one model for spec and body.** In syn-legacy every declaration knows whether it has a part in the specification, the private part and the body (`Has_Private_Part`, `Has_Body`, `Has_Body_Spec`), so a single package model produces both files. ada-pretty has no equivalent; this is worth keeping.
- **Change: mutable records and overloads.** Nodes are records filled in with procedures (`Append`, `Add_Actual_Argument`, `Add_Elsif`), and constructors multiply into overloads (eight versions of `New_Function_Call_Expression`, six of `New_Procedure_Call_Statement`). A factory with a few general constructors and lists of child nodes covers the same ground more simply.
- **Change: layout spread through `Write`.** Each node writes itself with `Col`, `Set_Col`, `Indent` and `Optional_New_Line`, so layout decisions are scattered. In this version, nodes produce documents and one pretty printer lays them out.
- **Keep, but make explicit: raw text.** The Rose IDL generator calls `Syn.Object` (an expression from a string) 134 times, more than anything else. Some generated text will always be easier to write by hand, so there is a raw-text node, but it is a deliberate escape hatch rather than the normal way to build expressions.

## Lessons from ada-pretty

- **Adopt: the factory and node set.** `New_Package`, `New_Subprogram_Body`, `New_Apply`, `New_If` and so on, returning nodes, with lists of nodes for sequences. Its node set is a good checklist.
- **Adopt: a Wadler-style pretty printer**, which chooses line breaks for the whole construct, and aligns names in declarations, parameter lists and associations.
- **Avoid: `League.Strings.Universal_String`** and the `matreshka_league` dependency (322 MB fetched, a `make reconfig` step, about four minutes for a first build).
- **Fix: what the trial found** (rose#136):
  - literals are limited to `Natural`, too small for 64-bit values such as endpoint ids;
  - no `raise` statement, exception handler or enumeration type constructors;
  - enumeration literals padded for alignment (`(Directory    , Ordinary_File )`), a style error;
  - no line break before `exception` in a subprogram body, a style error;
  - a trailing space after `access function`, a style error.

## Architecture

| Package | Purpose |
|---|---|
| `Syn` | Root: node type and lists. |
| `Syn.Factory` | Constructors for every node. |
| `Syn.Documents` | Documents and the pretty printer (text, line breaks, nesting, groups). |
| `Syn.Style` | Layout settings: line width, indentation, alignment, blank lines. |
| `Syn.Units` | Compilation units, and writing a unit's specification and body to files. |
| `Syn.Names` | Helpers for Ada names and GNAT file names (`Core_Utilities.Echo` to `core_utilities-echo.ads`). |

- **Nodes are immutable** once built. The factory owns them, and they are freed when the factory is finalised, so callers never manage memory.
  Every current use is a run-once tool that generates its files and exits, so this is enough. A long-running, server-style user would be the reason to revisit it, for example with reference-counted nodes that can outlive the factory.
- **Each node produces a document**, and `Syn.Documents` lays out the document for the given width. Nodes never write text themselves.
- **Syn carries its own printer** in `Syn.Documents`, at least for the first version, rather than depending on a separate implementation of Wadler's algorithm.
- **Writing a unit** produces the specification and, if any declaration needs one, the body, with the file names GNAT expects.

## Node coverage

The first release covers everything `idle` needs, and the rest of ada-pretty's set:

- **Units and clauses:** compilation units, child units, `with` (including `limited` and `private`), `use` and `use type`, pragmas and aspects.
- **Declarations:** packages (with private parts), package bodies, generic packages and subprograms with their formal parts, instantiations, subprogram specifications, declarations, bodies, expression functions and renamings, objects, constants, renamings, types and subtypes.
- **Type definitions:** enumerations, signed integer and modular types, ranges, records (including tagged, limited and with discriminants), private types, derived types, interfaces, arrays and access types.
- **Statements:** assignment, procedure calls, `if`, `case`, loops (`while`, `for`, `for ... of`), `return` and extended `return`, `declare` blocks, `null`, `raise` (with a message) and exception handlers with choice parameters (`when E : others =>`).
- **Expressions:** names, selected names, attributes, calls and indexing, operators, parentheses, aggregates, qualified expressions, `if` and `case` expressions, and literals of any size, in any base, with or without underscores (`16#0C71_18A7_C791#`).
- **SPARK** is written with the general aspect and pragma nodes (`SPARK_Mode`, `Pre`, `Post`, `Global` and so on). Dedicated SPARK nodes are a possible future enhancement.
- **Comments** on declarations and statements, and a licence header for each unit.
- **Raw text**, for what the node set does not cover.

## Layout

The default style matches GNAT's own, so the output passes `-gnatyabcefhiklmnoprst`:

- three-space indentation, and continuation lines two spaces in from the construct they continue (`procedure Open` then `  (Client ...`);
- a 79-character line width;
- names aligned in declarative lists, parameter lists, record components and named associations;
- one blank line between declarations, and before and after `private` in a package specification; none before `begin` or `exception`;
- no trailing spaces, and one statement per line.

`Syn.Style` makes these settable for projects with a different house style.

## Testing

- **Golden files.** Each test builds a tree and compares the output with an expected file.
- **Compile every expected file** with `gcc -c -gnats -gnatyabcefhiklmnoprst -gnatwe -gnat2022` as part of the test suite, so a layout bug is a test failure, not a surprise in a user's build.
- **The Rose interfaces as a test case:** the generated `Rose.Interfaces` packages for the kernel target should match the output of today's IDL compiler, apart from layout.
