.. _Universes:

****************************************
Universes / Sorts
****************************************




Basics
========================================


Universes and sorts are the same thing. There are the following universes::

    Prop            -- Impredicate universe of propositions
    Any level       -- Stratified predicative universes
    Level           -- The type of predicative levels

where ``levels`` are defined by the grammar::

    level ::=
        i               -- Fixed universe levels 0 1 2 ...
    |   u               -- Universe level variables
    |   u + i           -- Universe level 'i' above 'u'
    |   max u v ...     -- The maximum of the levels 'u', 'v', ...
    |   ω               -- The highest possible level

Examples of predicative universes::

    Any 0
    Any 10
    Any (u + 4)
    Any (max u (v + 3))


The levels have a partial order::

    0 < 1 < 2 < ... < ω

    0 ≤ u < ω

    u < u + i       -- for 0 < i

    v ≤ max . . . v . . .

Different universe variables are unrelated. The partial order on the levels
induces a partial order on the universes::

    Prop < Any 0 < Any 1 < ... < Any ω

    Any u < Any v       -- if u < v

    Any u ≤ Any v       -- if u ≤ v

    Any u < Any ω

    Level < Any ω

All universes except ``Any ω`` have types with the typing rules::

    s₁  <   s₂
    ----------
    s₁  :   s₂

where ``s₁`` and ``s₂`` are universes (or sorts). Since ``Any ω`` is the highest
possible universe, there is no higher universe and therefore ``Any ω`` does not
have a type.

Because of the typing rule for variable introduction::

    Γ ⊢ A : s
    ------------------
    Γ, x: A ⊢ x : A

we can substitute all universes except ``Any ω`` for `A`` and
define variables which has the corresponding universes as type. E.g.::

    α: Prop

    β: Any u

    u: Level


All fully elaborated polymorphic types and functions use universes and universe
levels::

    class List₀ (α: Any 0): Any 0 :=
        []      :   List
        (::)    :   α → List → List

    append {α: Any 0}: List₀ α → List₀ α → List₀ α := case
        λ []        ys  :=  ys
        λ (x :: xs) ys  :=  x :: append xs ys

    class List₁ (α: Any 1): Any 1 :=
        []      :   List
        (::)    :   α → List → List

    class List {u: Level} (α: Any u): Any u :=
        []      :   List
        (::)    :   α → List → List

    append {u: Level} {α: Any u}: List α → List α → List α
    := case
        λ []        ys  :=  ys
        λ (x :: xs) ys  :=  x :: append xs ys


The last two definitions are universe polymorphic. They can be instantiated at
any universe level.

Some illegal and legal types::

    List₀ ℕ                 -- Legal: List of natural numbers. 'ℕ : Any 0' is valid

    List₀ (Any 0)           -- Illegal, because 'Any 0 : Any 0' is invalid

    List₁ (Any 0)           -- Legal, because 'Any 0 : Any 1' is valid

    List {1} (Any 0)        -- Legal, because 'Any 0 : Any 1' is valid


Using ``List₁`` or ``List`` it is possible to construct a list of types::

    [Int, String, Bool] : List₁ (Any 0)

    [Int, String, Bool] : List (Any 0)

    -- because of
    Int     :   Any 0
    String  :   Any 0
    Bool    :   Any 0

Usually it is not necessary to spell out the universes in the source code,
because the elaborator can derive the most general fully elaborated definition.
E.g. if the compiler is fed with the definition::

    class List (α: Any) :=
        []      :   List
        (::)    :   α → List → List

it generates the above fully elaborated definition of ``List``.



Subtyping
========================================

The type system has the subtyping rule::

    Γ ⊢ x : T
    T < U
    -------------------
    Γ ⊢ x : U



We can instantiate this rule for sorts::

    Γ ⊢ α : s₁
    s₁ < s₂
    -------------------
    Γ ⊢ α : s₂

and specifically for predicative universes::

    Γ ⊢ α : Any u
    -------------------
    Γ ⊢ α : Any (u + i)

I.e. any type in the universe at level ``u`` is also a type in the universe at
level ``u + i`` for any ``0 < i``.

This eliminates the need to define e.g. tuples with two universe levels::

    -- Definition with two universe levels
    class
        Tuple {u v: Level} (α: Any u) (β: Any u): Any (max u v)
    :=
        (,): α → β → Tuple

    -- Equivalent definition with one universe level
    class
        Tuple {u: Level} (α β: Any u): Any u
    :=
        (,): α → β → Tuple


    -- Typing judgements
    1       : ℕ
    Bool    : Any 0

    (1, Bool): Tuple ℕ (Any 0)

    ℕ       : Any 1
    Any 0   : Any 1

    Tuple ℕ (Any 0): Any 1





Draft
========================================




Using universe levels it is possible to define heterogeneous lists::

    class
        HList {u: Level} {α: Any u} (P: α → Any u): List α → Any u
    :=
        hnil    : HList []
        hcons   : ∀ {x: α} {xs: List α}: P x → HList xs → Hlist (x :: xs)

    class
        HList {u: Level} {α: Any u} (P: α → Any u): List α → Any u
    :=
        hnil    : HList []
        hcons   : ∀ {x: α} {xs: List α}: P x → HList xs → Hlist (x :: xs)
