runsandbox
========

```.sh
$ cabal sandbox init
$ cabal install hoge

# run program using hoge
$ runhaskell Main.hs

Main.hs:5:18:
    Could not find module Hoge
    Use -v to see a list of the files searched for.

$ runsandbox Main.hs
OK!
```
