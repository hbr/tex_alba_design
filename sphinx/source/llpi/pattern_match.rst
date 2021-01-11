***************
Pattern Match
***************

.. highlight:: alba


A pattern match expression is a **function**.

If we have a function type ``A → B`` or ``∀(x: A): B``, then the function object
has the form ``λ x := e``. This definition of a function does not *look* into the
form the object bound by the variable ``x`` has been constructed.

However if we have the function type ``ℕ → ℕ`` then we can pattern match on the
argument i.e. inspect on how the argument has been constructed. There are two
possibilities ``zero`` and ``add1 n``. Therefore we can use two functions, one
for the first case and one for the second case. Example:

.. code-block::

    (+): ℕ → ℕ → ℕ :=
        case
            λ n zero        := n
            λ n (add1 m)    := add1 (n + m)

I.e. instead of binding to variables ``λ x₁ x₂ ... := e`` we bind to patterns
``λ p₁ p₂ ... := e`` and the patterns here are ``zero`` and ``add1 m`` where the
second pattern binds a new variable.

A pattern is

- a variable

- a constructor applied to other pattern

- a constant of a decidable type (e.g. characters, strings, numbers, ...)


Indexed types:

- If the actual index is not a variable, but an expression, then the
  corresponding function need not return a result for all possible values of the
  index but only for this specific value.

- However the elimination function treats the index with the specific value as
  a variable and can compute the expected result type for all possible values of
  the index. Only for the substituted index, the result type must correspond to
  the expected result type of the function.

- If the indices of an inductive type are variables, then the patterns cannot
  bind the index to a variable (only to the nameless variable ``_``). Reason:
  The variable is fixed by the type. It is uniquely determined by the pattern
  variables which match the inductive object.

  It is not possible to match the index variable with a constructor and to match
  the corresponding inductive object in the same match case. The match case
  uniquely determines the index which depends on the constructor variables.

.. note::

    How are indices treated in pattern matches. If the indices of an inductive
    type are variables, then they are present in the context. However they are
    not free. Every match case constructs an object with a specific index.


.. code-block::

    class (=) {α: Any} (x: α): Predicate α :=
        identical: (=) x

    :check identical: ∀ {α: Any} {x: α}: x = x

    ℕ.reject {n: ℕ}: zero = add1 n -> False :=
        case
            case
                λ zero     _ := True
                λ (add1 m) _ := False   -- not used in match, only in result
            λ eq :=
                trueValid

    ℕ.inject {n m: ℕ}: add1 n = add1 m -> n = m :=
        case
            case
                λ zero      _   := False    -- not used!
                λ (add1 m)  _   := n = m
            λ identical := identical

    (=).symmetric {α: Any}: ∀ {x y: α}: x = y → y = x :=
        case
            case
                λ {x y} _ := y = x
            λ {x _} (identical: x = x): x = x :=
                identical




.. code-block::

    class (≤): Endorelation Natural :=
        init {n}: zero ≤ n
        step {m n}: m ≤ n → add1 m ≤ add1 n


    (≤).reject {n: ℕ}: add1 n ≤ zero -> False :=
        case
            case
                λ {zero _}  _           := True
                λ {(add1 n) zero}       := False
                λ {(add1 n) (add1 m)    := True
            λ init      := trueValid
            λ (step _)  := trueValid

    (≤).inject {n m: ℕ}: add1 n ≤ add1 m -> n ≤ m :=
        case
            case
                λ {zero     _}          _   := True
                λ {(add1 n) zero}       _   := True
                λ {(add1 n) (add1 m)}   _   := n ≤ m
            λ init      := trueValid
            λ (step le) := le



Example: List filtering.

.. code-block::

    List.filter {α: Any} (p: α → Boolean) : List α → List α :=
        case
            λ [] := []
            λ (x :: xs) :=
                inspect p x case
                    λ true  := x :: filter xs
                    λ false := filter xs


.. note::

    Languages like Agda, Idris etc. have a with abstraction to integrate the
    inner pattern match into the outer. Does this make sense in ``Alba`` as
    well?.
                
