function! string#scanner(str)
  let obj = {}
  if type(a:str) == type([])
    let obj.string = join(a:str, "\n")
  else
    let obj.string = a:str
  endif
  let obj.length = len(obj.string)
  let obj.index  = 0

  func obj.eos() dict
    return self.index >= self.length
  endfunc

  func obj.skip(pat) dict
    let pos = matchend(self.string, '\_^' . a:pat, self.index)
    if pos != -1
      let self.index = pos
    endif
    return pos
  endfunc

  func obj.skip_until(pat) dict
    let pos = matchend(self.string, '\_.\{-}\ze' . a:pat, self.index)
    if pos != -1
      let self.index = pos
    endif
    return pos
  endfunc

  func obj.scan(pat) dict
    " Use \_^ here to anchor the match at the start of the index.
    " Otherwise it finds the first match after index.
    let m = matchlist(self.string, '\_^' . a:pat, self.index)
    if ! empty(m)
      let self.index += len(m[0])
      let self.matches = m
      return m[0]
    endif
    return ""
  endfunc

  func obj.collect(pat) dict
    let matches = []
    while ! self.eos()
      if self.skip_until(a:pat) == -1
        break
      endif
      call add(matches, self.scan(a:pat))
    endwhile
    return matches
  endfunc

  func obj.split(sep, ...) dict
    let keepsep = 0
    if a:0
      let keepsep = a:1
    endif
    let pieces = []
    let old_index = 0
    while ! self.eos()
      if self.skip_until(a:sep) == -1
        call add(pieces, strpart(self.string, old_index))
        break
      endif
      let the_piece = strpart(self.string, old_index, (self.index - old_index))
      call add(pieces, the_piece)
      let the_sep = self.scan(a:sep)
      if keepsep && (the_sep != '')
        call add(pieces, the_sep)
      endif
      if old_index == self.index
        call add(pieces, strpart(self.string, old_index, 1))
        let self.index += 1
      endif
      let old_index = self.index
    endwhile
    return pieces
  endfunc

  return obj
endfunction

" A list of tokens with navigation methods & element access
function! string#tokens()
  let obj          = {}
  let obj.tokens   = []
  let obj.index    = 0
  let obj.cur_tok  = []
  let obj.next_tok = []

  "foo
  func obj.finalise()
    call add(self.tokens, ['_end_', '_end_', self.tokens[-1][-1]])
    let self.num_tokens = len(self.tokens)
    let self.next_tok = self.tokens[0]
    return self
  endfunc

  func obj.next()
    let self.cur_tok = self.next_tok
    if self.index < self.num_tokens
      let self.index += 1
    endif
    let self.next_tok = self.tokens[self.index]
    return self.cur_tok
  endfunc

  func obj.add(type, value, line)
    call add(self.tokens, [a:type, a:value, a:line])
  endfunc

  return obj
endfunction

function! string#lexer(string)
  let obj               = {}
  let obj.tokens        = string#tokens()
  let obj.string        = ''
  let obj.line_continuation_pattern = '\n\s*\\'
  let obj.pattern_order = [
        \  'whitespace', 'name'
        \, 'float_number', 'hex_number', 'oct_number', 'int_number'
        \, 'tq_string', 'dq_string', 'sq_string'
        \, 'operator', 'comment', 'unknown'
        \]
  let obj.newline_patterns = [
        \  'whitespace'
        \, 'tq_string', 'dq_string', 'sq_string'
        \, 'comment', 'unknown'
        \]
  let obj.patterns = {
        \  'whitespace'   : ['\s\+', '\n\%(\s*\\\s*\)\?']
        \, 'name'         : ['[ablgstw]:\w*', '[_a-zA-Z]\+']
        \, 'float_number' : ['\d\+\.\d\+\%([eE][+-]\?\d\+\)\?']
        \, 'hex_number'   : ['0x\x\+']
        \, 'oct_number'   : ['0\o\+']
        \, 'int_number'   : ['\d\+']
        \, 'tq_string'    : ['"""\_.\{-}"""']
        \, 'dq_string'    : ['"\%(\\\.\|[^\n]\)*"']
        \, 'sq_string'    : ['''\%(''''\|\_.\)\{-}''']
        \, 'operator'     : ['[\\\[\](){}<>:,./\\?=+!@#$%^&*`~|-]\+']
        \, 'comment'      : ['"[^\n]*\n']
        \, 'unknown'      : ['\S\+']
        \}

  func obj.new(str)
    let self.tokens = string#tokens()
    if type(a:str) == type([])
      let self.string = join(a:str, "\n")
    else
      let self.string = a:str
    endif
    let self.ss = string#scanner(self.string . "\n")
    call self.lex()
    let self.tokens = self.tokens.finalise()
    return self
  endfunc

  func obj.join_line_continuations(string)
    return substitute(a:string, self.line_continuation_pattern, '', 'g')
  endfunc

  func obj.lex()
    let lines = 1
    while self.ss.index < self.ss.length
      let matched = 0
      for type in self.pattern_order
        for pat in self.patterns[type]
          let value = self.ss.scan(pat)
          if value != ''
            let matched = 1
            let t_value = value
            if index(self.newline_patterns, type) != -1
              let value = self.join_line_continuations(value)
            endif
            call self.tokens.add(type, value, lines)
            if index(self.newline_patterns, type) != -1
              let lines += len(substitute(t_value, '[^\n]', '', 'g'))
            endif
            break
          endif
        endfor
        if matched
          break
        endif
      endfor
    endwhile
  endfunc

  return obj.new(a:string)
endfunction

function! string#trim(str)
  return matchstr(a:str, '^\_s*\zs.\{-}\ze\_s*$')
endfunction

function! string#to_string(obj)
  let obj = a:obj
  if type(obj) < 2
    return obj
  else
    return string(obj)
  endif
endfunction

function! string#eval(line)
  let line = string#trim(a:line)
  if line[0] =~ '[{[]'
    return eval(line)
  else
    return line
  endif
endfunction

" range(number) - ['A' .. 'A'+number]
" range(65, 90) - ['a' .. 'z']
" range('a', 'f') - ['a' .. 'f']
" range('A', 6) - ['A' .. 'F']
function! string#range(...)
  if ! a:0
    throw 'vimple string#range: not enough arguments'
  endif
  if a:0 > 2
    throw 'vimple string#range: too many arguments'
  endif
  if a:0 == 1
    return map(range(a:1), 'nr2char(char2nr("A")+v:val)')
  else
    if type(a:1) == type(0)
      let start = a:1
    else
      let start = char2nr(a:1)
    endif
    if type(a:2) == type(0)
      if type(a:1) == type(0)
        let end = a:2
      else
        let end = (start + a:2) - 1
      endif
    else
      let end = char2nr(a:2)
    endif
    return map(range(start, end), 'nr2char(v:val)')
  endif
endfunction
