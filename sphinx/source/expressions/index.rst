****************************************
Expressions
****************************************



Inductive Types
========================================

.. note::
    The following is DRAFT



.. code-block::

    mutual
        (α: Any)            -- common parameter
    :=
        class Tree :=
            node: α → Forest → Tree
        class Forest :=
            []      : Forest
            (::)    : Tree → Forest → Forest


    mutual :=
        class Even: Predicate ℕ :=
            zero        : Even zero
            even1 {n}   : Odd n → Even (succ n)
        class Odd:  Predicate ℕ :=
            odd1 {n}    : Even n → Odd (succ n)








Pattern Match
========================================



Syntax
--------------------

A pattern is one of:

- A variable

- A constructor pattern ``c p₁ p₂ ...`` where ``c`` is a constructor and ``p₁ p₂
  ...`` are pattern

- A literal


All variables in a pattern must be distinct.

A pattern match expression has the form

.. code-block::

    case
        λ p₁₁ p₁₂ ... := e₁
        λ p₂₁ p₂₂ ... := e₂
        ...

where all lines have the same number of pattern.

A pattern match expression is a function with the type

.. code-block::

    A₁ → A₂ → ... → R

where the number of argument types is the same as the number of pattern in each
row. The type of each pattern is the type of the corresponding argument. Each
expression on the right hand side must have the result type ``R``.





Canonicalization
--------------------

A pattern match expression is in its canonical form, if all possible
combinations are explicit and in order of the constructors of the corresponding
inductive type and the more left patterns vary slower than the more right
patterns.

Example of a pattern match in canonical form and in noncanonical forms

.. code-block::

    case    -- canonical
        zero        []          := ...
        zero        (h :: t)    := ...
        (succ n)    []          := ...
        (succ n)    (h :: t)    := ...

    case    -- non canonical
        (succ n)    (h :: t)    := ...
        zero        _           := ...
        _           []          := ...

    case    -- non canonical
        (succ n)    (h :: t)    := ...
        zero        []          := ...
        _           _           := ...

    case    {| Illegal: The cases
                    zero     (h :: t)
                    (h :: t) zero
                are missing. |}
        (succ n)    (h :: t)    := ...
        zero        []          := ...


If a pattern match is exhaustive, it can always be canonicalized. A
nonexhaustive pattern match is illegal.

If all pattern in the first row are variables, nothing has to be done for that
row.

If all pattern in the first row are constructor patterns, the lines can be
sorted such that all constructor pattern with the same constructor are grouped
and the constructors appear in the order in which they appear in the
corresponding inductive definition. This is possible, because swapping adjacent
lines which begin both with a constructor pattern does not change the semantics.
Constructors are mutually exclusive.

If all pattern in a row are constructor pattern and there is a missing
constructor, then the pattern match is not exhaustive i.e. illegal.

If the pattern in the first row have constructors and variables, we have the
mixed case.

In the mixed case we have to split all lines with variables into the possible
constructor pattern. In the right hand side the variable must be replaced by the
corresponding constructed object. After the split we have all pattern of the
first row with constructor pattern. Now we can reorder the expressions without
changing the semantics.

During reordering there might appear subsequent pattern with the same
constructor. Only the first one is reachable. The subsequent pattern are not
reachable and can be eliminated.

If we continue the same algorithm with all rows we end up with a pattern match
expression in canonical form.

Example 1::

    case    -- non canonical
        λ (succ (succ n))     :=  e₁
        λ _                   :=  e₂

    case    -- wildcard '_'  splitted
        λ (succ (succ n))     :=  e₁
        λ zero                :=  e₂
        λ (succ _)            :=  e₂

    case    -- reordered
        λ zero                :=  e₂
        λ (succ (succ n))     :=  e₁
        λ (succ _)            :=  e₂

    case    -- wildcard '_'  splitted
        λ zero                :=  e₂
        λ (succ (succ n))     :=  e₁
        λ (succ zero)         :=  e₂
        λ (succ (succ n))     :=  e₂

    case    -- reordered
        λ zero                :=  e₂
        λ (succ zero)         :=  e₂
        λ (succ (succ n))     :=  e₁
        λ (succ (succ n))     :=  e₂

    case    -- redundant clause eliminated
        λ zero                :=  e₂
        λ (succ zero)         :=  e₂
        λ (succ (succ n))     :=  e₁


Example 2::

    case    -- non canonical
        λ (succ n)    (h :: t)    := e₁
        λ zero        []          := e₂
        λ m           ys          := e₃


    case    -- variable pattern 'm' splitted
        λ (succ n)    (h :: t)    := e₁
        λ zero        []          := e₂
        λ zero        ys          := f zero ys
        λ (succ n)    ys          := f (succ n) ys
    where
        f m ys := e

    case    -- reordered
        λ zero        []          := e₂
        λ zero        ys          := f zero ys
        λ (succ n)    (h :: t)    := e₁
        λ (succ n)    ys          := f (succ n) ys
    where
        f m ys := e₃

    case    -- variable pattern 'ys' splitted
        λ zero        []          := e₂
        λ zero        []          := f zero []            -- not reachable
        λ zero        (y ::ys)    := f zero (y :: ys)
        λ (succ n)    (h :: t)    := e₁
        λ (succ n)    []          := f (succ n) []
        λ (succ n)    (y :: ys)   := f (succ n) (y :: ys) -- not reachable
    where
        f m ys := e₃

    case    -- reorder and eliminate not reachable cases
        λ zero        []          := e₂
        λ zero        (y ::ys)    := f zero (y :: ys)
        λ (succ n)    []          := f (succ n) []
        λ (succ n)    (h :: t)    := e₁
    where
        f m ys := e₃








Dependent Pattern Match
========================================

Type
--------------------

In the previous chapter we just described pattern match expressions whose types
are not dependent. Now we describe the general case. The type of a pattern match
expression is a function type which has the general form

.. code-block::

    ∀ (x₁: A₁) (x₂: A₂) ... : R

    -- example

    ∀ {n m}: succ n ≤ succ m → n ≤ m

    -- in long form

    ∀ {n m: ℕ} (_: succ n ≤ add2 m): n ≤ m

Note that type annotations can be ommitted as long as the compiler can infer
them and ``A → B`` is a shorthand for ``∀ (_: A): B``. Braces are used to mark
implicit arguments.

Variables which occur in types are inferrable variables and the corresponding
types are dependent types. In the example ``n`` and ``m`` are inferrable
variables and ``succ n ≤ succ m`` and ``n ≤ m`` are dependent types.

In a type of a pattern match expression, all implicit variables must be
inferrable variables. The reverse is not true in general.





Syntax
--------------------

The general form of a pattern match expression:

.. code-block::

    case
        λ (p₁₁: A₁₁) (p₁₂: A₁₂) ... : R₁ := e₁      -- a pattern clause
        λ (p₂₁: A₂₁) (p₂₂: A₂₂) ... : R₂ := e₂
        ...

    -- Type:

        ∀ (x₁: A₁) (x₂: A₂) ... : R

Type annotations for the pattern and the results in the pattern match expression
are optional. Note that ``R`` can be a function type of the form ``∀ (y: B):
C``.

Pattern can be explicit (``p`` or ``(p: A)``) or implicit (``{p}`` or ``{p:
A}``.


A pattern is one of:

- variable (or a wildcard ``_``)

- constructor applied to pattern

- arbitrary expression (only allowed in implicit pattern)





Rules
--------------------

Distinct pattern variables:
    All variables used in the explicit pattern of the same pattern clause have
    to be distinct.

    Variables in inferable pattern of the same pattern clause need not be
    distinct.


Number of pattern:
    The number of arguments in the type and the number of matched patterns in
    each line must be the same.

    However if there are implicit arguments in the type, the corresponing pattern
    in the pattern match lines can be ommitted because the compiler can infer
    them.

    The compiler adds wildcard arguments ``{_}`` for the missing implicit
    arguments in the pattern clauses.


Implicit arguments in braces:
    The pattern corresponding to implicit arguments in the type of the pattern
    match expression have to be put in braces.


Type completeness:
    All variables occuring in the types ``A₁, A₂, ..., R`` (i.e. all *inferable*
    variables) of the type must occur as variables in the type. E.g. the type
    ``n ≤ m`` is not a legal type of a pattern match expression. ``∀ {n m}: n ≤
    m`` is a legal type.


Consistent types:
    The types in the ``i``\ th pattern clause (``Ai₁ Ai₂ ... Ri``) must be
    unifiable with the corresponding types (``A₁ A₂ ... R``) of the type of the
    pattern match expression where all inferable variables are considered as
    unification variables.

    This consistency requirement excludes pattern clauses with some pattern
    combinations where the types of the pattern clause are not unifiable with the
    corresponding types in the type of the pattern match. In the extreme case
    there are no allowed pattern clauses and the pattern match is empty.

Exhaustive:
    For all possible arguments which do not contain variables at least one of
    the pattern clauses must match. The check for being exhaustive can be done
    by transforming a pattern match expression into its canonical form (see next
    chapter).

Reachable:
    All clauses must be reachable. I.e. for each clause there is at least one
    set of arguments which matches the clause whih fails to match all previous
    clauses.




Canonical Forms
--------------------

The transformation into canonical form works by case splitting on variable
pattern, reordering of the pattern clauses and dropping of non reachable
clauses.



Focus of Subsequent Clauses
^^^^^^^^^^^^^^^^^^^^^^^^^^^

We consider two pattern as equivalent if the have the same structure and only
have different variables at the same position.

The pattern in focus of two subsequent clauses is the first pattern on which
both clauses are different. If there is no focal pattern, then the second one is
unreachable.

The focal point of two pattern is the first subpattern when scanned from left to
right where they are different. The difference can be because of two different
constructors at the focal point or a constructor and a variable at the focal
point.

If two clause have a focal pattern and the first has a variable at the focal
point, then the second clause is unreachable.



Reorder Clauses
^^^^^^^^^^^^^^^

We reorder clauses in order to transform them into the lexicographic order. The
order is induced by the order in which the constructors are introduced in the
corresponding inductive type.

We swap the order of two subsequent clauses with a common prefix of pattern
followed by a pattern which is out of order.

Two pattern are out of order if they have identical structure scanned from left
to right up to a point where they have different constructor pattern and the
constructors are out of order.

Examples of *out of order* clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...


    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ zero    ) ...     := ...

We can swap the out of order clauses without changing the semantics of the
pattern match expression.


Split a Variable Pattern
^^^^^^^^^^^^^^^^^^^^^^^^

Variable splitting occurs on two subsequent clauses with a common prefix. The
suffix of both start with an overlapping pattern and an arbitrary suffix.

Two pattern overlap if scanned from left to right have an identical structure
and then one of them has a variable pattern and the second one has a constructor
pattern at the same position.

Examples of overlapping clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ m       ) ...     := ...

Note that both clauses must have identical structure up to the variable pattern.

If we have two subsequent overlapping clauses, then we cannot swap the order
without changing the semantics.

If the first of two subsequent overlapping clauses contains the variable where
the second one has a constructor pattern, then the second clause is not
reachable (non reachable clauses are illegal).

In order to split the variable pattern of two subsequent clauses we do a case
split of the variable and replace the variable with all constructors by
introducing new variables.

Example::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...

    -- split 'm'

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...
    λ p₁ p₂ ... (succ m       ) ...     := ...

After the splitting we can reorder the first and the second clause.





Draft Examples
--------------------

.. note::
    The following are DRAFT examples


.. code-block::

    -- Example: ≤ -----------------

    class (≤): Endorelation ℕ :=
        start {n}   : zero ≤ n
        next  {n m} : n ≤ m → succ n ≤ succ m

    reject: ∀ {n: ℕ}: succ n ≤ zero → False :=
        case        -- no case match

    inject: ∀ {n m: ℕ}: succ n ≤ succ m → n ≤ m := case
        λ (next le):= le

    -- long form:

    inject: ∀ {n m: ℕ}: succ n ≤ succ m → n ≤ m := case
        λ   {i}
            {j} 
            (next {i j} (le: i ≤ j): succ i ≤ succ j)
        : i ≤ j
        := le

.. code-block::

    -- Example 'Vector'

    class Vector (α: Any): ℕ → Any :=
        []      : Vector zero
        (::)    : ∀ {n}: α → Vector n → Vector (succ n)

    map {α β γ: Any} (f: α → β → γ)
    : ∀ {n}: Vector α n → Vector β n → Vector γ n
    := case
        λ {zero}        []                  []  :=
            []

        λ {succ n}      ((::) {n} x xs)     ((::) {n} y ys) :=
            (::)
                {n}
                (f x y)
                (map {n} xs ys)





.. code-block::

    section {α β γ: Any} :=
        map (f: α → β → γ)
        : ∀ {n}: Vector α n → Vector β n → Vector γ n
        := case
            λ []        []          := []
            λ (x :: xs) (y :: ys)   := f x y :: map xs ys

        class Image (f: α → β): β → Any :=
            image a: Image (f a)

        invers {f: α → β}: ∀ {b}: Image f b → α := case
            λ (image a) := a

