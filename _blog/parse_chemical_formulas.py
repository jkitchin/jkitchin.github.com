#!/usr/bin/env python

import sys
from pylisp import *
from pyparsing import *

from pyparsing import *

element = oneOf( """H He Li Be B C N O F Ne Na Mg Al Si P S Cl
            Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge
            As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag
            Cd In Sn Sb Te I Xe Cs Ba Lu Hf Ta W Re Os
            Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Lr Rf
            Db Sg Bh Hs Mt Ds Rg Uub Uut Uuq Uup Uuh Uus
            Uuo La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm
            Yb Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No""" )

integer = Word(nums)
elementRef = Group(element
                    + Optional( integer, default="1" )
                    + Optional(Or([Literal("-"),
                                   Literal("+")])))
chemicalFormula = OneOrMore(elementRef) + NotAny(Word(alphas))

formulas = []

text = sys.stdin.read().strip()

for match, start, stop in chemicalFormula.scanString(text):
  formulas.append(text[start:stop])

print "'{}".format(formulas.lisp)
