****************
Basic Types
****************


General
========================================


Logical
----------------------------------------

.. code-block::

    Predicate (α: Any): Any := α → Proposition

    Relation (α β: Any): Any := α → β → Proposition

    Endorelation (α: Any): Any := Relation α

    class (=) (α: Any) (x: α): Predicate α :=
        identical: (=) x

    class Exist {α: Any} (P: Predicate α): Proposition :=
        exist {x}: P x → Exist

    class False: Proposition :=     -- no constructor

    class True: Proposition  := trivial

    (Not) (A: Proposition): Proposition := A → False

    class (∧) (A B: Proposition): Proposition :=
        (,): A → B → (∧)

    class (∨) (A B: Proposition): Proposition :=
        left  : A → (∨)
        right : B → (∨)

    class Accessible {α: Any} (R: Endorelation α): Predicate α :=
        access {x}: (∀ y, R y x → Accessible y) → Accessible x



General
----------------------------------------

.. code-block::

    class Void :=              -- no constructor

    class Unit := unit

    class Boolean := true; false

    class List {α: Any} := ([]); (::): α → List → List

    class (,) (α β: Any) := (,)

    class Result (A B: Any) :=
        ok      :   A → Result
        error   :   B → Result

    class Either (α β: Any) :=
        left    :   A → Either
        right   :   B → Either

    class Tristate (α β γ: Any) :=
        left    : α → Tristate
        middle  : β → Tristate
        right   : γ → Tristate

    Decision (A: Proposition) :=
        Either A (Not A)

    class Maybe (A: Any) :=
        nothing : Maybe
        just    : A -> Maybe

    class Refine {α: Any} (P: Predicate α) :=
        refine x: P x → Refine

    (|>) {α: Any} {B: α → Any} (x: α) (f: ∀ x: B x): B x :=
        f x

    (<|) {α: Any} {B: α → Any} (f: ∀ x: B x) (x: α): B x :=
        f x

    (>>) {α β γ: Any} (f: α → β) (g: β → γ): α → γ :=
        λ x := g (f x)

    (<<) {α β γ: Any} (g: β → γ) (f: α → β): α → γ :=
        λ x := g (f x)



Natural and Integer
----------------------------------------

There are arbitrary sized natural numbers and integer numbers. Both are given a
definition as an inductive type. However they are compiled to more efficient
types in the runtime.

Therefore the basic arithmetic functions and decision procedures are also
defined in terms of the inductive types. But these arithmetic functions and
decision procedures are compiled to more efficient runtime representations.

.. code-block::

    -- Natural Numbers
    class ℕ: Any := zero: ℕ; add1: ℕ → ℕ

    (=?): ℕ → ℕ → Boolean := case
        λ zero      zero        := true
        λ (add1 n)  (add1 m)    := true
        λ _         _           := false

    (<?): ℕ → ℕ → Boolean := case
        λ _         zero        := false
        λ zero      (add1 _)    := true
        λ (add1 n)  (add1 m)    := n <? m

    (+): ℕ → ℕ → ℕ := case
        λ n zero        := n
        λ n (add1 m)    := add1 (n + m)

    (-): ℕ → ℕ → ℕ := case
        λ n         zero        :=  n
        λ n         (add1 _)    :=  zero
        λ (add1 n)  (add1 m)    :=  n - m

    divAux: ℕ → ℕ → ℕ → ℕ → ℕ := case
            -- n / (add1 m) = divAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (add1 n)    zero    :=  divAux (add1 k) m n m
        λ k m   (add1 n)    (add1 j):=  divAux k m n j

    modAux: ℕ → ℕ → ℕ → ℕ → ℕ := case
            -- n % (add1 m) = modAux 0 m n m 
        λ k m   zero        j       :=  k
        λ k m   (add1 n)    zero    :=  modAux 0 m n m
        λ k m   (add1 n)    (add1 j):=  modAux (add1 k) m n j


Key idea in ``divAux`` and ``modAux``: The number ``k`` is initialized to
``zero`` and incremented in some cases such that at the end it is either the
quotient or the remainder. Both are total functions have efficient runtime
representations.


.. note::
    Instead of defining ``=?`` and ``<?``
    maybe it is better to define a function ``distance n m`` with 3 results. In
    the first case the number ``n`` is smaller than ``m`` and ``i`` is returned
    such that ``n + i + 1 = m`` is valid. In the second case both numbers are
    equal. And in the third case then number ``n`` is greater than the numer
    ``m`` and ``i`` is returned such that ``n = m + i + 1`` is valid.

    .. code-block::

        distance: ℕ → ℕ → Tristate ℕ Unit ℕ := case
            λ zero      (add1 i)    := left i
            λ zero      zero        := middle unit
            λ (add1 i)  zero        := right i
            λ (add1 i)  (add1 j)    := distance i j




.. code-block::

    -- Integer Numbers
    class ℤ: Any :=
        positive: ℕ → ℤ
        negative1: ℕ → ℤ    -- 'negative1 n' represents '- (add1 n)'

    (*): ℕ → ℕ → ℕ := ...
    (^): ℕ → ℕ → ℕ := ...

    (+): ℤ → ℤ → ℤ := ...
    (*): ℤ → ℤ → ℤ := ...

    ...         -- details left out here


.. note::

    Missing: We have to include definitions of all arithmetic operators and
    decision procedures (equality, order relation) which have an efficient
    builtin representation.








Scalar Types
================================

Integer Types
----------------------------------------

There are signed and unsigned integer for various bitsizes

``Byte``
    8 bit unsigned integer

``Int32, UInt32``
    32 bit signed and unsigned integer

``Character``
    32 bit unicode code point

``Int64, UInt64``
    64 bit signed and unsigned integer

``Int, UInt``
    architecture dependent signed and unsigned integer



Semantics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The semantics of builtin unsigned and signed integers is defined via an
embedding into ℕ or ℤ. This embedding is defined by an embedding function and a
proof that it is an embedding (i.e. it is injective).

In the following we show the necessary definitions for ``UInt32``.

.. code-block::

    UInt32.toℕ: UInt32 → ℕ
    UInt32.fromℕ: ℕ → UInt32        -- modulo 2^32

    UInt32.embeded: ∀ n m: toℕ n = toℕ → n = m

    UInt32.(≤) (n m: UInt32): Proposition :=
        toℕ n ≤ toℕ m

    UInt32.(≤?) (n m: UInt32): Decision (n ≤ m)

    Unit32.bitSize: ℕ      -- bitsize is 'n + 1', cannot be zero

    UInt32.(+) (n m: UInt32): UInt32 :=
        fromℕ (toℕ n + toℕ m)

    UInt32.(-) (n m: UInt32): UInt32 :=
        fromℕ (toℕ n + 2^(add1 bitsize)- toℕ m) 

    UInt32.plusProperty: ∀ (n m: UInt32):






Compile to Javascript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the node platform and the browser, scalar values up to the bitsize of 32 can
be represented as javascript numbers. 64 bit scalars have no direct
representation in javascript. We have to generate an object with two 32 bit
sized numbers.

This workaround is necessary although javascript numbers are 64 bit floating
point values. However it is not possible to do 64 bit integer arithmetic in
javascript on 64 bit floating point values.

With the ``x|0`` annotation we can force javascript to do signed 32 bit integer
arithmetics on javascript numbers. The expression ``x >> 0`` converts 32 bit
integer as well. ``x >>> 0`` converts to an unsigned 32 bit integer (i.e. ``-1
>>> 0`` is converted to ``0xff_ff_ff_ff``).

Signed and unsigned integer arithmetic is the same. Only the javascript
comparison operatos ``<=``, ``<``, ... give wrong results. Before doing the
comparisons, it is necessary to add the lowest negative number
``0x80_00_00_00`` which is :math:`-2^{31}`. This shifts the number zero to the
lowest negative number, i.e. all other numbers are greater or equal to this
number.  


Compile to Machine Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


If compiling to machine code (e.g. via LLVM or Rust) the situation is different.

Scalar types can be allocated on the stack. This is possible to bitsizes up to
128 (or maybe in LLVM even more).

The code is fastest if all scalar objects are allocated on the stack and scalar
objects within other objects are completely within the surrounding object. I.e.
there are no pointers to scalar objects (they are *unboxed*). This creates two
possible problems:

Garbage collection:
    Pointer occupy a machine word and the machine number occupies a machine word
    as well. The runtime cannot distinguish between a machine number and a
    pointer into the heap.

    Ocaml resolved this problem by making the machine numbers of size
    :math:`2^{31}` or :math:`2^{63}` and representing the number :math:`i` by
    the number :math:`2i + 1`. Therefore in machine numbers the least
    significant bit has always the value 1. Since heap locations are always word
    aligned the corresponding pointers have a least significant bit of 0. The
    garbage collector can recognize pointer into the heap by looking at the
    least significant digit.

Polymorphic Functions:
    Generic functions on objects pointing into the heap need only one machine
    code representation for all its possible types.

.. note::
    More detailed analysis needed!




Floating Point
----------------------------------------
