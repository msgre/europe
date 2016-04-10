Directory with initial questions.

Each subdirectory represent one of the category used in the game. There must
be script `initial.py`, and inside function named `load` accepting 2 named
arguments `stdout` and `stderr`:

    def load(stdout=None, stderr=None):
        # ... your code follows

There is custom management command `initial_questions` in django application,
which will dynamicaly look into this directory and invoke all `load` functions.
You just provide path to content directory, for example:

    ./manage.py initial_questions /content

It's up to you how you implement `load` function. Look into already defined
subdirectories. You find there examples how to load simple textual questions or
image based questions.

For further information see docstring inside `initial.py` files.
