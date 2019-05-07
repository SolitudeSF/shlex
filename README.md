# shlex
Split a string into words according to POSIX shell syntax

Library provides a function, that return a sequence of words and a boolean, that shows if the input contained errors,
and an iterator that just returns words.

# Installation
`nimble install shlex`

# Example
```nim
import shlex

doAssert shlex("foo\nbar").words == @["foo", "bar"]

for word in shlex("I love \"Nim👑\""):
  echo word
```
