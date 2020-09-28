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

    def funcc():
        nonlocal a
        a = 3

    def funcd():
        vars["a"] = 4
        vars["b"] = 5
    def p():
        print("p:",a, b)

    print(a, b)
    funcb()
    print(a, b)
    funcc()
    print(a, b)
    vars=locals()
    funcd()
    # funca()
    print(vars)
    print(a, b)
    p()


test()
