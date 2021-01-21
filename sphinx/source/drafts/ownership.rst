**************
Ownership
**************


Linear Types
============


Some kind of linear types can be useful to implement interactions with the io
system or the runtime system.

A file descriptor can be considered as a resource. To open and close a file we
can have the interface

.. code-block:: alba

    open (name: String) (mode: Mode): IO once FileHandle

    close (fd: once FileHandle): IO Unit

The annotation ``once`` means that the type ``FileHandle`` is a resource
which has to be used exactly once. With this annotations, the compiler can check
that each opening of a file is followed by a closing of the file.

The functions to read and write a file should not be considered as *using* the
file descriptor. We can similar to rust introduce some reference type.

.. code-block:: alba

    write (bd: ref BufferHandle) (fd: ref FileHandle): IO Unit
    read  (bd: ref BufferHandle) (fd: ref FileHandle): IO Unit


A programm which opens a file reads to and then closes it has the form (error
handling ommitted)

.. code-block:: alba

    do
        fd := open "my-file" read
        bd := alloc 1024
        ...                 -- fill the buffer
        write &bd &fd       -- '&' converts from 'once' to 'ref'
        ...                 -- fill the buffer again
        write (ref bd) (ref fd)
        free bd
        close fd


Language Elements
=================

.. only:: draft

  My personal thoughts


Type attributes:

``once T``
    The type ``once T`` considered as a linear type, i.e. it has to be used
    exactly once. An object of type ``once T`` can only passed as an actual
    argument to functions if the type of the formal argument is also ``once
    T`` or if the formal argument is declared as ``once name: T``.

    ``once T`` does not conform to ``T``, because the receiving function can
    use the object arbitrarily often and does not guarantee the *once* usage
    constraint.

    .. note::
        Open question: Does ``T`` conform to ``once T``?

        .. only:: draft

            It might be possible. But it is more conservative to no allow
            objects of type ``T`` to given as arguments to functions expecting a
            ``once T``. At first sight there are no problems, because the
            function treats the object like a resource.

            However problems might arise, if the function uses a ``T`` which it
            thinks is a ``once T`` creates other once objects with it.




``ghost T``
    An object of this type can only be used in propositional functions. It is
    not available at runtime i.e. the compiler erases it at code generation.

    ``T`` conforms to ``ghost> T``. Any object of type ``T`` can be passed to a
    function expecting a ``ghost T``.

    ``<ghost> T`` does not conform to ``T``.  Reason: The function might use the
    object to make decisions or construct other runtime objects from it.


``ref T``
    A reference to the type ``T``. A reference cannot live longer than the
    original object.


``&name``
    The name ``name`` must be bound to a resource object. ``name`` is a
    reference to the resource. Its livetime is limited to the livetime of the
    resource.

    We have the typing judgement ``ref &name: ref T`` only
    if ``name: once T`` is valid.



Name attributes:

``once name``
    When a formal argument of a function has the declaration ``(once name:
    T)`` it is guaranteed that the function uses its argument only once. I.e.
    the function can handle objects of type ``T`` and objects of type ``once
    T``.


Being a *once* object is infectuous to the parent objects. A list of linear
objects is a linear object as well. If a name is bound to a linear list, then
the name has to be used in a pattern match. The pattern match reveals the linear
head and tail which have to be consumed as well. A pattern match on the empty
list consumes the empty list and there remain no other linear objects which have
to be consumed.
