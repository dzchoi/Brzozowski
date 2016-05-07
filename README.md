# Brzozowski
Brzozowski's algorithm in Haskell
  
######The algorithm is simple and beautiful:  
The derivative of a regular expression *L* at a symbol *c* is defined as:  
> D<sub>c</sub>(L) := {w | cw ∈ L}  
> That is, if *L* can match *c* as the first symbol, the derivative D<sub>c</sub>(L) is defined to be another regular expression that is supposed to match the remaining symbols beyond *c*.  

Using this definition we can test whether a regular expression *L* matches a string of symbols *s*(= *abc...z*) such as:
> *L* matches *s* if and only if ε ∈ D<sub>z</sub>...D<sub>c</sub>D<sub>b</sub>D<sub>a</sub>(L)  
> That is, get the next derivative at each symbol of *s* consecutively and check the last derivative matches an empty string.

######To run with Glasgow Haskell Compiler:  
`$ ghci Brzozowski.hs` and type main within the REPL  
or  
`$ ghc Brzozowski.hs; ./Brzozowski`  
