.. _Universes:

****************************************
Universes
****************************************


There are universe levels. Universe levels are::

    10              -- a specific level
    u               -- a variable
    u + 3           -- the universe level three above 'u'
    max u v ...     -- the maximum of the levels 'u', 'v', ...

Universe levels have the type ``Level``.


Universe levels can only by used as parameters to ``Any``::

    Any[10]
    Any[u]
    Any[u + 8]
    Any[max u v w]
    -- ^ No blank allowed between 'Any' and '('


We have the valid typing judgements::

    Prop:       Any[0]

    Any[0]:     Any[1]

    Any[u]:     Any[u + 10]

    Any[v]:     Any[max ... v ...]

The sort ``Any`` can be at any universe level. If there is no universe level
specified in a declaration or definition, then the compiler assumes ``Any[u]``
for all occurences of ``Any`` in the same declaration for some universe level
``u``.

Example::

    class List (α: Any) :=
        []      : List
        (::)    : α → List → List

    -- is interpreted as

    class List {u: Level} (α: Any[u]): Any[u] :=
        []      : List
        (::)    : α → List → List


Having this interpretation we can define a list of types::

    Int:    Any[0]
    Bool:   Any[0]
    String: Any[0]

    [Int, Bool, String]: List Any[0]

    -- where
    List Any[0]: Any[1]


Using universe levels it is possible to define hetergeneous lists::

    class HList {α: Any} (P: α → Any): List α → Any :=
        hnil    : HList []
        hcons   : ∀ {x: α} {xs: List α}: P x → HList xs → Hlist (x :: xs)
