****************************************
Inductive Types
****************************************

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
