============================================
LLPI
============================================

Low Level Dependently Typed Language


:math:`LL \Pi`

✓

There are currently various dependently typed languages available. The most
prominent ones are ``Coq``, ``Lean``, ``Agda`` and ``Idris``. They have
different features. ``Coq`` and ``Lean`` are mainly a proof assistants.
``Idris`` and ``Agda`` are designed to be programming languages with the
possibility to generate executable programs.

All dependently typed languages are very different source languages with
different syntax, different automation facilities and different philosophy. But
they share to a great extent the type system.

All are based on the calculus of inductive constructions with cumulative
universes. I.e. it should be possible to define a type system which is a
superset of all type systems.

The basic idea described here is to define this type system and a low level
language to write definitions in that common type system.

:math:`\pi`.

.. math::
   \Pi



::

    +--------+   +-------+    +-------+
    |        | --+ ditaa +--> |       |
    |  Text  |   +-------+    |diagram|
    |Document|   |!magic!|    |       |
    |     {d}|   |       |    |       |
    +---+----+   +-------+    +-------+
        :                         ^
        |       Lots of work      |
        +-------------------------+

.. highlight:: alba

.. code-block::

    -- Comment all to the end of the line

    all (x: A): B
    class List (α: Any) :=
        ([]): List {- a short comment -}
        (::): α → List → List

    class Natural :=
        zero: Natural
        add1: Natural → Natural -- successor

    4 + 5 - 7 / 9 * 6


.. code-block:: coq

    Inductive Natural: Type :=
        | zero: Natural
        | add1: Natural -> Natural.
