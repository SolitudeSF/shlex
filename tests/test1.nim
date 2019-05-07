import unittest
import ../src/shlex

test "general":
  check shlex("foo$baz") == (false, @["foo$baz"])
  check shlex("foo baz") == (false, @["foo", "baz"])
  check shlex("foo\"bar\"baz") == (false, @["foobarbaz"])
  check shlex("foo \"bar\"baz") == (false, @["foo", "barbaz"])
  check shlex("   foo \nbar") == (false, @["foo", "bar"])
  check shlex("foo\\\nbar") == (false, @["foobar"])
  check shlex("\"foo\\\nbar\"") == (false, @["foobar"])
  check shlex("'baz\\$b'") == (false, @["baz\\$b"])
  check shlex("'baz\\\''") == (false, @["baz\'"])

test "comments":
  check shlex("foo #bar\nbaz").words == @["foo", "baz"]
  check shlex("foo #bar").words == @["foo"]
  check shlex("foo#bar").words == @["foo#bar"]
  check shlex("foo\"#bar").words.len == 0

test "empty":
  check shlex("\\").words.len == 0
  check shlex("\"\\").words.len == 0
  check shlex("'\\").words.len == 0
  check shlex("\"").words.len == 0
  check shlex("'").words.len == 0
