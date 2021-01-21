.. _Intermediate Representation:


************************************************************
Intermediate Representation
************************************************************



Basics
============================================================

The intermediate representation of a module is all its declarations and
definitions in fully elaborated form. Fully elaborated means specifically:

- All binders are fully typed (argument types and return types).

- All implicit arguments are present in braces.

- All pattern match expressions are typed. I.e. before the match clauses the
  type on the pattern match expression is added enclosed in braces.

- Overloaded symbols are disambiguated with their namespace.

- No operator expressions. Only function application, i.e. ``2 + 3`` is not
  allowed, it has to be encoded as ``$Int.+ 2 3``.

- Global and local names are encoded especially as described in the section
  `Names`_.

A module implementation file in intermediate representation has the suffix
``.pi`` and a module interface file in intermediate representation has the
suffix ``.pii``.

In order to read a file in the intermediate language it is sufficient to
generate a parse tree of all terms, definitions and declarations and typecheck
it.

The intermediate language makes it possible to use an external type checker to
verify a compiled Alba module independently.

All optimizations can be done in the intermediate representation. This
guarantees that all optimization steps can be type checked and the semantics
does not change.

Furthermore it is possible to compile programs written in other dependently type
programming languages into the intermediate representation and use the available
backends to compile to javascript or machine code (or any other target for which
a backend is available).

The intermediate representation decouples the source language from the
optimizers and the backends.

The files ``*.pi`` and ``*.pii`` are human readable and need an indentation
sensitive parser to read them. It is possible to encode the intermediate
representation into binary form ``*.pi.bc`` ``*.pii.bc`` or into sexp form
``*.pi.sexp`` ``*.pii.sexp`` in order to use more efficient parsers.

In the first version of the language only the human readable form is
implemented.





Names
============================================================

All identifiers and operators have to be prefixed. There are the following
prefixes:

``$``
    For global names and operators.

``%``
    For local names. Local names consisting only of digits are treated as de
    Bruijn indices. The first digit in a name which is not a de Bruijn index has
    to be escaped.


The name or operator strings end with a blank or a dot. Blanks or dots within
the name string have to be escaped. The escape character is the backslash.

The dot ``.`` is the namespace separator. Examples::

    $ℕ.zero             -- constructor 'zero' of ℕ
    $ℕ.succ             -- constructor 'succ' of ℕ

    $≤.start            -- constructor 'start' of '≤'

    $natural.ℕ.+        -- operator '+' of type ℕ within module 'natural'


All identifiers without a prefix are keywords.

With this strategy, the intermediate language and the source language are
decoupled with respect to names and keywords and can evolve independently.

Example of a list in the intermediate language::

    class
        $List {%u: Level} (%A: Any %u): Any %u
    :=
        $[]     :   $List
        $::     :   %A -> $List -> $List


    -- or with de Bruijn indices

    class
        $List {Level} (Any %0): Any %1
    :=
        $[]     :   $List
        $::     :   %0 -> $List -> $List
