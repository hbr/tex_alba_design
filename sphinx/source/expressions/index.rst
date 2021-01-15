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
            even1 {n}   : Odd n → Even (add1 n)
        class Odd:  Predicate ℕ :=
            odd1 {n}    : Even n → Odd (add1 n)




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
        (add1 n)    []          := ...
        (add1 n)    (h :: t)    := ...

    case    -- non canonical
        (add1 n)    (h :: t)    := ...
        zero        _           := ...
        _           []          := ...

    case    -- non canonical
        (add1 n)    (h :: t)    := ...
        zero        []          := ...
        _           _           := ...

    case    {| Illegal: The cases
                    zero     (h :: t)
                    (h :: t) zero
                are missing. |}
        (add1 n)    (h :: t)    := ...
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

Example:

.. code-block::

    case    -- non canonical
        (add1 n)    (h :: t)    := e₁
        zero        []          := e₂
        m           ys          := e3


    case    -- variable pattern 'xs' splitted
        (add1 n)    (h :: t)    := e₁
        zero        []          := e₂
        zero        ys          := f zero ys
        (add1 n)    ys          := f (add1 n) ys
    where
        f m ys := e

    case    -- reordered
        zero        []          := e₂
        zero        ys          := f zero ys
        (add1 n)    (h :: t)    := e₁
        (add1 n)    ys          := f (add1 n) ys
    where
        f m ys := e₃

    case    -- variable pattern 'ys' splitted
        zero        []          := e₂
        zero        []          := f zero []            -- not reachable
        zero        (y ::ys)    := f zero (y :: ys)
        (add1 n)    (h :: t)    := e₁
        (add1 n)    []          := f (add1 n) []
        (add1 n)    (y :: ys)   := f (add1 n) (y :: ys) -- not reachable
    where
        f m ys := e₃

    case    -- reorder and eliminate not reachable cases
        zero        []          := e₂
        zero        (y ::ys)    := f zero (y :: ys)
        (add1 n)    []          := f (add1 n) []
        (add1 n)    (h :: t)    := e₁
    where
        f m ys := e₃



Dependent Pattern Match
========================================


.. note::
    The following are DRAFT examples


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

