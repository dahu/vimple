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
    " let pos = match(self.string, a:pat, self.index)
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
      call add(pieces, strpart(self.string, old_index, (self.index - old_index)))
      let the_sep = self.scan(a:sep)
      if keepsep
        call add(pieces, the_sep)
      endif
      let old_index = self.index
    endwhile
    return pieces
  endfunc

  return obj
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
