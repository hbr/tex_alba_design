.. _Style:


************************************************************
Style and Conventions
************************************************************



Generous Spacing
============================================================


Although it is syntactically possible, squeezing many things on one line is not
the recommended style. The indentation sensitivity of the syntax makes it
possible to visualize the structure of an expression graphically.

::

    -- Ok
    class Color = red; green; blue

    -- Better readable
    class Color :=
        red
        green
        blue


    -- Don't do
    class List (α: Any) := []; (::): α → List → List

    -- Recommended
    class List (α: Any) :=
        []      : List
        (::)    : α → List → List

    -- Maybe even more generous
    class
        List (α: Any)
    :=
        []      : List
        (::)    : α → List → List




Choosing Names
============================================================

Global names i.e. externally visible names should not be abbreviated. Long names
should be written in camel case. The javascript libraries are a good example for
choosing global names. In javascript you write ``requestAnimationFrame`` and not
``reqAniFrm``. Avoiding abbreviations help memorizing the names and usually
people do not agree on good abbreviations.


Local names can be short, if the context and the type are good clues to convey
the meaning. If it is clear from the context that a variable is an index, then
it does not make a lot of sense to call it ``index``. A simple ``i`` or ``n``
might be sufficient.

Since local names have a short validity span, abbreviations can be used to make
them short. E.g. ``le`` for ``lessEqual`` or ``eqAB`` for ``equalAB``. There is
no need to memorize local names. The names should be chosen to understand the
function or the algorithm well.

The keywords have been chosen to be short. Long keywords would just clutter up
the source code and reduce readability.



Identifier Case
============================================================

Because Alba is a dependently typed language, objects, types, propositions, etc.
are all in the same syntactic category. In order to distinguish optically
between terms and types we use

- upper case names for types and type constructors and

- lower case names for objects (i.e. runtime objects like data and functions or
  proofs)

Examples::

    -- Types

    List
    String

    -- Objects
    zero
    succ




However the language does not enforce the distinction.
