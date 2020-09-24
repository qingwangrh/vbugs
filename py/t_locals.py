import os
import tempfile


def test():
    a = 1
    b = 2

    def funca():
        print("global:", globals())
        globals()["a"] = 2
        globals()["b"] = 3

    def funcb():
        vars=locals()
        print("locals", vars)
        vars["a"] = 4
        vars["b"] = 5

    print(a, b)
    funcb()
    print(a, b)
    funca()
    print(a, b)


test()
