function! string#scanner(str)
  let obj = {}
  let obj.string = a:str
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
