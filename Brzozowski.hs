-- regular expression matching using Brzozowski's algorithm

data Regex a = Nil --epsilon; zero-width match pattern that matches the empty string.
	     | End --zero-width non-match
	     | Lit a --a literal symbol in the input alphabet
	     | Cat (Regex a) (Regex a) --cat-node
	     | Alt (Regex a) (Regex a) --or-node
	     | Clo (Regex a) --star-node; Kleene closure
	     deriving (Eq, Show)



regex :: String -> Regex Char
--A simple but effective parser for regular expressions
--Epsilon can be represented by "()" or vacancy for the last alternation branch such as "a|b|".
--The "*" and "|" not preceded by any character or unmatched parentheses will lead to a
--non-exhaustive pattern exception.
--The regular expression is automatically augmented with terminating End, which helps to make
--the otherwise non-important accepting states as important.(?)
--regex cs | (r, "") <- regexCat0 cs = Cat r End
regex cs | (r, "") <- regexCat0 cs = r
    --Unmatched parantheses for lone ')' is caught here.

regexCat0 :: String -> (Regex Char, String)
regexCat0 "" = (Nil, "")
    --This Nil needs to be further checked for its validity in the outside of regexCat0
regexCat0 cs @(')':_) = (Nil, cs)
regexCat0 ('(':cs) | (r, cs) <- regexPar0 cs = regexCat1 r cs
regexCat0 (c:cs) | c /= '*', c /= '|' = regexCat1 (Lit c) cs

regexCat1 :: Regex Char -> String -> (Regex Char, String)
regexCat1 r "" = (r, "")
regexCat1 r cs @(')':_) = (r, cs)
regexCat1 r ('(':cs) | (s, cs) <- regexPar0 cs = regexCat2 r s cs
regexCat1 r ('|':cs) | (s, cs) <- regexCat0 cs = (Alt r s, cs)
    --We could compare the old cs with the resulting cs from regexCat0 and have the match to fail
    --if equal, but then the last definition of regexCat1 will be matched and '|' will be treated
    --as a normal character.
    --The first pattern of alternation goes to the left branch of the alternation syntax tree and
    --the rest, to the right branch. Going to the left-oriented syntax tree for this case, however,
    --would need to define another function to read up to '|' like regexPar0.
regexCat1 r ('*':cs) = regexCat1 (Clo r) cs
regexCat1 r (c:cs) = regexCat2 r (Lit c) cs

regexCat2 :: Regex Char -> Regex Char -> String -> (Regex Char, String)
regexCat2 r s "" = (Cat r s, "")
regexCat2 r s cs @(')':_) = (Cat r s, cs)
regexCat2 r s ('(':cs) | r <- Cat r s, (s, cs) <- regexPar0 cs = regexCat2 r s cs
regexCat2 r s ('|':cs) | r <- Cat r s, (s, cs) <- regexCat0 cs = (Alt r s, cs)
regexCat2 r s ('*':cs) = regexCat2 r (Clo s) cs
regexCat2 r s (c:cs) = regexCat2 (Cat r s) (Lit c) cs

regexPar0 :: String -> (Regex Char, String)
regexPar0 cs | (r, ')':cs) <- regexCat0 cs = (r, cs)
    --Unmatched parantheses for lone '(' is caught here.
    --We doesn't ban a Nil from regexCat0 here so that "()" may represent Nil.



nullable :: Regex a -> Bool
nullable Nil = True
nullable (Clo _) = True
nullable (Cat r s) = (nullable r) && (nullable s)
nullable (Alt r s) = (nullable r) || (nullable s)
nullable _ = False --on End or Lit

delta :: Regex a -> Regex a
--d(r) = Nil if r can match the empty string; End, otherwise.
delta r = if nullable r then Nil else End

derivative :: Eq a => Regex a -> a -> Regex a
--D[r,x]: Brzozowski's derivative of a regular expression.
--The derivative of a regular expression with respect to a character computes a new regular
--expression that will match the remaining characters that the old expression would match further,
--after it had just matched the character.
derivative (Lit c) x = if x == c then Nil else End
derivative (Cat r s) x =
    --D(rs,x) = D(r,x)s | d(r)D(s,x)
    alt (cat (derivative r x) s) (cat (delta r) (derivative s x))

derivative (Alt r s) x =
    --D(r|s,x) = D(r,x)|D(s,x)
    alt (derivative r x) (derivative s x)

derivative s @(Clo r) x =
    --D(r*,x) = D(r,x)r*
    cat (derivative r x) s

derivative _ _ = End
    --D(Nil,x) = D(End,x) = End

--all the derivatives of "a*" are the same.
--but, "a*a*" explodes.

cat :: Regex a -> Regex a -> Regex a
cat Nil r = r
cat r Nil = r
cat End _ = End
cat _ End = End
cat r s = Cat r s

alt :: Regex a -> Regex a -> Regex a
alt Nil Nil = Nil
--alt Nil (Alt Nil r) = r
--alt r (Alt Nil r) = Alt r s
--alt Nil r = Zer r
alt End r = r
alt r End = r
--alt r s | r == s = r
alt r s = Alt r s

clo :: Regex a -> Regex a
clo Nil = Nil
clo End = Nil
--clo r @(Clo r) = r
clo r = (Clo r)



regexMatch :: Eq a => Regex a -> [a] -> Bool
--regexMatch Nil cs = null cs
--regexMatch Nil [] = True
regexMatch r [] = nullable r
    --If the string to match is empty and the current pattern matches empty, then the match
    --succeeds.
regexMatch r (c:cs) = regexMatch (derivative r c) cs
    --If the string to match is non-empty, the new pattern is the derivative of the current
    --pattern with respect to the first character of the current string, and the new string to
    --match is the remainder of the current string.



-- sample regular expression from Dragon Book
main = do
    print $ regexMatch (regex "(a|b)*abb") "abaabb" -- must be True
    print $ regexMatch (regex "(a|b)*abb") "abaab"  -- must be False
