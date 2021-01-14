****************************************
Lexical Structure
****************************************



Input Format
========================================



An alba source file is interpreted as a sequence of unicode code points encoded
in UTF-8.

A UTF-8 byte order mark

.. code-block:: none

    0xEF 0xBB 0xBF

and a *shebang*

.. code-block:: bash

    #! /usr/bin/env albax

at the beginning of a file are ignored by the compiler.




Wildcard
========================================

The symbol ``_`` is a *wildcard*.




Punctuation Symbols
========================================


The following symbols are punctuation symbols. The unicode equivalents are in
parentheses.

.. code-block::

    : ( ) [ ] { } \ (λ) , ; -> (→) := ! ?




Identifiers
========================================

There are two ways to construct an indentifier.

- An nonempty sequence of letters, digits and underscores starting with a letter.

- An underscore followed by a nonempty sequence of letters digits and
  underscores.

Examples:

.. code-block::

    -- legal identifiers

    Natural
    BigType
    is_empty
    isEmpty
    _all
    _convert
    __

    -- illegal identifiers

    _                           -- single underscore is a wildcard
    reverse-append              -- hyphen not allowed



Keywords
========================================

The following keywords are reserved and cannot be used as identifiers. Some
keywords have unicode equivalents which are written within parentheses.

.. code-block::

    all (∀) and And (∧) Any
    case class
    do
    else
    ghost
    in (∈) inspect if
    let
    module mutual
    not Not (¬)
    once or Or (∨)
    Prop
    ref
    section some (∃)
    then
    use
    where

The recommended way to use a keyword as an identifer is to prefix it with an
underscore (e.g. ``_all``, ``_case``, ...).


Operators
========================================

We have the following ascii and unicode operator characters. Ascii equivalents
are in parentheses.

.. code-block::

    + - * / | \ < > = ~ :       -- ascii operator characters

    ≤ (<=) ≥ (>=)               -- unicode operator characters


An operator string is any nonempty sequence of operator characters which does
not consist only of a backslash ``'\'`` or a colon ``:``. Reason: The backslash
and the colon are a punctuation symbols.

An operator string and its ascii equivalent are the same.

The following are keyword operators:

.. code-block::

    and And (∧)
    in (∈)
    not Not (¬)
    or Or (∨)


An operator symbol is one of:

- A nonempty operator string ending with an optional question mark.

- An operator keyword.







Literals
========================================



Numbers
----------------------------------------



Characters
----------------------------------------


Strings
----------------------------------------


Comments
========================================

.. code-block::

    -- spans to the end of line

    --| docu comment spans to the end of line

    reverse {| short comment |} list

    {| Multiline comment

        spans several lines  {| can be nested |}
    |} all {A: Any}: A

    {|| multiline docu comment. |}  ℕ → ℤ




UTF-8 Encoding
========================================



.. code-block:: none

    First bytes in a unicode byte sequence

    0xxxxxxx                1 byte sequence i.e. ascii character
    110xxxxx                2 byte sequence
    1110xxxx                3 byte sequence
    11110xxx                4 byte sequence


    Continuation byte

    10xxxxxx                6 bits of information


The following encodings are possible:

1 Byte Sequence
    All Ascii characters up to ``U+7F`` i.e. 7 bits.

2 Byte Sequence
    Unicode code points up to ``U+07FF`` i.e. up to 11 bits.

3 Byte Sequence
    Unicode code points up to ``U+FFFF`` i.e. up to 16 bits.

4 Byte Sequence
    Unicode code points up to ``U+10FFFF`` i.e. up to 21 bits.

According to the unicode standard the values between ``U+D800`` and ``U+DFFF``
are not valid code points (they are used to encode surrogate pairs in UTF-16).



