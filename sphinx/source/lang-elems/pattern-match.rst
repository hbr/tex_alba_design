.. _Pattern Match:

****************************************
Pattern Match
****************************************


Type
==============================


The type of a pattern match
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
==============================

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
==============================

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
==============================

The transformation into canonical form works by case splitting on variable
pattern, reordering of the pattern clauses and dropping of non reachable
clauses.



Focus of Subsequent Clauses
---------------------------

We consider two pattern as equivalent if the have the same structure and only
have different variables at the same position. Furthermore inferable pattern are
always considered as equivalent.

The pattern in focus of two subsequent clauses is the first pattern on which
both clauses are different. If there is no focal pattern, then the second one is
unreachable.

The focal point of two pattern is the first subpattern when scanned from left to
right where they are different. The difference can be because of two different
constructors at the focal point or a constructor and a variable at the focal
point.




Reorder Clauses
---------------

We reorder clauses in order to transform them into the lexicographic order. The
order is induced by the order in which the constructors are introduced in the
corresponding inductive type.

We swap the order of two subsequent clauses if there is a focal pattern where
both have a constructor at the focal point and the constructor of the second
clause comes before the constructor in the first clause in the corresponding
inductive type.

Examples of *out of order* clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...
    --           ^ focal point with out of order constructors

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ zero    ) ...     := ...
    --                ^ focal point with out of order constructors

The swapping of the clauses does not change the semantics of the pattern match
expression.



Split a Variable Pattern
------------------------

Case splitting of a variable occurs if we have two subsequent clauses with a
focal point where one has a constructor at the focal point and the other
has a variable at the focal point.


Examples of overlapping clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...
    --          ^ focal point with overlap

    λ p₁ p₂ ... (succ m       ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    --                ^ focal point with overlap

We do a case split on the variable. The case splitting does not change the
semantics of the pattern match expression.


Example 1::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...
    --          ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...
    λ p₁ p₂ ... (succ m       ) ...     := ...


Example 2::

    λ p₁ p₂ ... (succ m       ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    --                ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... (succ zero    ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...



Example 3::

    λ p₁ p₂ ... zero        ...                := ...
    λ p₁ p₂ ... m           ...     := ...
    --          ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... zero        ...     := ...
    λ p₁ p₂ ... zero        ...     := ...
    λ p₁ p₂ ... (succ m)    ...     := ...





Transform into Canonical Form
------------------------------

Definition of *canonical form*:
    A pattern match expression is in canonical form if there are no two
    subsequent clauses with a focal pattern.


Transformation into *canonical form*:
    Search for a focal pattern in two subsequent clauses and do a reordering or
    a case splitting until no more focal pattern in subsequent clauses can be
    found.


It remains to be shown that the algorithm terminates.

The pattern match expression has an initial maximal constructor nesting
:math:`m`. This maximal constructor nesting :math:`m` remains constant during
the algorithm

Proof:
    A reordering does not change the maximal constructor nesting.

    A variable case split does not change the maximal constructor nesting.
    During a variable case split, the splitted clauses have a new constructor at
    the place of the variable. At that place the other clause had already a
    constructor.  Therefore the maximal constructor nesting does not change.


Now we create a sequence of numbers :math:`n_0 n_1 n_2 \ldots n_m i` for each
step. :math:`n_k` is the number of variables which are nested below :math:`k`
constructors and :math:`i` is the number of out of order clauses in the pattern
match expression. Clearly there cannot be any variable nested below more than
:math:`m` constructors, because :math:`m` is the maximal constructor nesting
during the algorithm.

We consider a lexicographic order on the sequence :math:`n_0 n_1 n_2 \ldots n_m
i` and claim that this sequence decreases lexicographically at each step of the
algorithm.

Proof:
    Reordering does not change :math:``n_0 n_1 \ldots n_m``, it only decreases
    :math:`i`.

    Variable case splitting decreases the sequence lexicographically. The
    case splitted variable occurs at a certain nesting depth :math:`k`. After
    the split the number :math:`n_k` has decreased by one. The numbers
    :math:`n_{k+1} \ldots n_m i` might increase. But the number :math:`n_k` has
    higher significance in the lexicographic order.





Reachability
==============================

Reachability is can be checked by transforming a pattern match expression into
its canonical form. Clauses which are unreachable follow immediately the
clause which shadows the unreachable clauses. The unreachable clauses have to be
eliminated.

Each clause in the canonical form stems exactly from one original clause. If all
clauses stemming from the same original clause are unreachable, then the
original clause is unreachable which has to be flagged as an error.







Exhaustiveness
==============================

Exhaustiveness can be easily checked in the canonical form where all
nonreachable clauses have been removed.

In the canonical form the sequence of clauses are nicely grouped. The pattern
vary from left to right from low frequency to the highest frequence. Therefore
missing variations can be easily spotted.

We can ignore all missing variations in inferable pattern. We concentrate only
on the non inferable pattern. If a clause is missing and it is unifiable with
the type, then the pattern match is not exhaustive. If all missing clauses are
not unifiable, then the pattern match is exhaustive even if not all combinations
are present.

We demonstrate the check on the following inductive types::

    class (=) {α: Any} (x: α): α → Prop :=
        identical: (=) x

    class (≤): Endorelation ℕ :=
        start {n}   : zero ≤ n
        next  {n m} : n ≤ m → succ n ≤ succ m

    class Vector (α: Any): ℕ → Any :=
        []      : Vector zero
        (::)    : ∀ {n}: α → Vector n → Vector (succ n)


We look at the follwing pattern match expressions in canonical form


Example 1::

    -- Type
    ∀ {n: ℕ}: zero = succ n → False

    -- Pattern match expression
    case
        -- no clauses

Since there are no clauses, the expression is certainly in canonical form. The
missing clause has the form::

    λ {i} (identical: zero = zero)    :=  ...

Unification of the argument types with the pattern types gives the following
unification problem::

    -- unify
    zero    =   succ n
    zero    =   zero

The unification problem has no solution. Therefore the potentially missing
clause is not really missing.



Example 2::

    -- Type
    ∀ {n m: ℕ}: succ n ≤ succ m → n ≤ m

    -- Pattern match expression
    case
        λ {i j} (next {i j} (le: i ≤ j): add1 i ≤ add1 j) := le

The obviously missing clause has the form::

    λ {i j} (start {k}: zero ≤ k)   :=

The unification of the argument types with the pattern types gives the following
unsolvable unification problem::

    -- unify
    succ n  ≤   succ m
    zero    ≤   k

Therefore the obviously missing clause is not really missing.



Example 3::

    -- Type
    ∀ {n: ℕ}: Vector ℕ n → Vector ℕ n → Vector ℕ n

    -- Pattern match expression
    case
        λ {zero}    []              []                  :=  ...
        λ {i}       ((::) {j} x xs) ((::) {k} y ys)     :=  ...


The obviously missing clauses are the *mixed* cases::

    λ {i}       []                  ((::) {k} y ys)     :=  ...
    λ {i}       ((::) {j} x xs)     []                  :=  ...


Let's look at the unification problems generated by the first seemingly missing
case::

    -- unify first argument types
    Vector ℕ n
    Vector ℕ zero

    -- solution
    n := zero

    -- unify second argument types
    Vector ℕ n                  -- where 'n := zero'
    Vector N (succ k)

The unification of the second argument types is not possible, because the first
unification problem already requires ``n = zero``. Therefore the clause is not
really missing.

The same reasoning applies to the second seemingly missing case.
