load'~/code/aoc/aoc.ijs'
grid =: ];.2 aoc 2019 10

A =: (j.~/"1) 4 $. $. '#' = grid
>./ C =: (# @ ~. @: (1 {"1 *. @ -.&0))"1 -/~ A

S =: A {~ (i. >./) C
phi =: 2p1 | 1p1 + {:@*.@*&0j_1
A0 =: (</.~phi) (/:phi) (/:|) (A - S) -. 0
Z =: S + {.&> ; (a: -.~ }.&.>) &.> ^: a: < A0
100 100 #. +. 199 { Z
