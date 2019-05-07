import options

type TinyLex = object
  error: bool
  n: int
  s: string

template `isSomeIt`(a: Option): untyped {.dirty.} =
  let it {.inject.} = a
  it.isSome

template parseLoop(t: TinyLex, c, body): untyped =
  var c = t.next
  while c.isSome:
    body
    c = t.next

func next(t: var TinyLex): Option[char] {.inline.} =
  if t.n < t.s.len: result = some(t.s[t.n])
  inc t.n

func parseDouble(t: var TinyLex): Option[string] {.inline.} =
  var res = ""
  t.parseLoop c:
    case c.get:
    of '\\':
      if t.next.isSomeIt:
        let c = it.get
        case c:
        of '$', '`', '"', '\\':
          res.add c
        of '\n':
          discard
        else:
          res.add '\\'
          res.add c
      else:
        t.error = true
        return none string
    of '"':
      return some res
    else:
      res.add c.get

func parseSingle(t: var TinyLex): Option[string] {.inline.} =
  var res = ""
  t.parseLoop c:
    case c.get:
    of '\\':
      if t.next.isSomeIt:
        let c = it.get
        case c:
        of '\'', '\\':
          res.add c
        else:
          res.add '\\'
          res.add c
    of '\'':
      return some res
    else:
      res.add c.get

func parseWord(t: var TinyLex, c: char): Option[string] =
  var
    res = ""
    c = c
  while true:
    case c:
    of '"':
      if t.parseDouble.isSomeIt:
        res.add it.get
      else:
        t.error = true
        return none string
    of '\'':
      if t.parseSingle.isSomeIt:
        res.add it.get
      else:
        t.error = true
        return none string
    of '\\':
      if t.next.isSomeIt:
        if it.get != '\n': res.add it.get
      else:
        t.error = true
        return none string
    of ' ', '\t', '\n':
      break
    else:
      res.add c
    if t.next.isSomeIt:
      c = it.get
    else:
      break
  some res

func shlex*(s: string): tuple[error: bool, words: seq[string]] =
  var t = TinyLex(s: s)
  t.parseLoop c:
    case c.get:
    of ' ', '\t', '\n':
      discard
    of '#':
      var c = t.next
      while c.isSome and c.get != '\n': c = t.next
    else:
      if t.parseWord(c.get).isSomeIt:
        result.words.add it.get
  result.error = t.error

iterator shlex*(s: string): string =
  var t = TinyLex(s: s)
  t.parseLoop c:
    case c.get:
    of ' ', '\t', '\n':
      discard
    of '#':
      var c = t.next
      while c.isSome and c.get != '\n': c = t.next
    else:
      if t.parseWord(c.get).isSomeIt:
        yield it.get
