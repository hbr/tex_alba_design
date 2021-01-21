.. _Inspect Expression:

************************************************************
Inspect Expression
************************************************************


A :ref:`pattern match expression <Pattern Match>` is a function. Therefore it is
very convenient to use it to define a function. However it is a little bit
clumsy to apply a pattern match expression directly to arguments.

In order to express such an application more conveniently there is an inspect
expression with the syntax::

    inspect
        a₁ a₂ ...
    case
        -- list of clauses
        ...

which is equivalent to::

    (case
        -- list of clauses
        ...
    ) a₁ a₂ ...

As in normal function application implicit arguments can be ommitted and will be
reconstructed by the elaborator.

Note that the arguments ``a₁ a₂ ...`` can be arbitrary expressions.
