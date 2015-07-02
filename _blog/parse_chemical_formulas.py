#!/usr/bin/env python

import sys
from pyparsing import *

element_string =  """H He Li Be B C N O F Ne Na Mg Al Si P S Cl
            Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge
            As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag
            Cd In Sn Sb Te I Xe Cs Ba Lu Hf Ta W Re Os
            Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Lr Rf
            Db Sg Bh Hs Mt Ds Rg Uub Uut Uuq Uup Uuh Uus
            Uuo La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm
            Yb Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No"""
element = oneOf([x for x in element_string.split()])

integer = Word(nums)
elementRef = Group(element + Optional(integer))
chemicalFormula = (WordStart(alphas.upper()).leaveWhitespace()
                   + OneOrMore(elementRef).leaveWhitespace()
                   + Optional(Or([Literal("-"),
                                  Literal("+")])).leaveWhitespace()
                   + WordEnd(alphas + alphas.lower() + nums + "-+").leaveWhitespace())

s = sys.stdin.read().strip()

matches = []
for match, start, stop in chemicalFormula.scanString(s):
   matches.append(s[start:stop])
matches = list(set(matches))
matches.sort(key=lambda x: len(x), reverse=True)

print "'(" + ' '.join(["\"{}\"".format(m) for m in matches]) + ')'
