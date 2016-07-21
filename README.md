# Brzozowski's Algorithm
### Brzozowski's algorithm in Haskell

The Brzozowski’s algorithm is one of the most beautiful and most concise algorithms for compiling and matching regular expressions. In the Brzozowski’s algorithm, the state that changes as reading and matching each input symbol against a regular expression is defined to be the regular expression itself. That is, while matching a symbol, the regular expression gets changed into another regular expression that is supposed to match the rest of input symbols expected to be matched.

### The algorithm is simple and beautiful.
The derivative of a regular expression *L* at a symbol *c* is defined as:  
> D<sub>c</sub>(L) := {w | cw ∈ L}  
> That is, if *L* can match *c* at the first symbol, the derivative D<sub>c</sub>(L) is defined to be another regular expression that is supposed to match the remaining symbols beyond *c*.  

Using this definition, we can test whether a regular expression *L* matches a string of symbols *s* (= *abc...z*) such as:
> *L* matches *s* if and only if ε ∈ D<sub>z</sub>...D<sub>c</sub>D<sub>b</sub>D<sub>a</sub>(L)  
> That is, get the next derivative at each symbol of *s* consecutively, and check the last derivative matches an empty string.

### To run with Glasgow Haskell Compiler:  
`$ ghci Brzozowski.hs` (and type `main` within the REPL)  
or  
`$ ghc Brzozowski.hs; ./Brzozowski`

### For example,  
`regexMatch (regex "(a|b)*abb") "abaabb"` will say `True`  
`regexMatch (regex "(a|b)*abb") "abaab"` will say `False`  
