" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

function! regex#ExtendedRegex(...)
  let erex = {}
  let erex.lookup_function = ''
  let erex.lookup_dict = {}

  func erex.default_lookup(name) dict
    return eval(a:name)
  endfunc

  "TODO: revisit this with eval() solution
  func erex.lookup(name) dict
    if empty(self.lookup_function)
      return call(self.default_lookup, [a:name], self)
    else
      "TODO: this 'self' dict arg needs to be the object's self...
      return call(self.lookup_function, [a:name], self.lookup_dict)
    endif
  endfunc

  func erex.expand_composition_atom(ext_reg) dict
    let ext_reg = a:ext_reg
    let composition_atom = '\\%{\s*\([^,} \t]\+\)\%(\s*,\s*\(\d\+\)\%(\s*,\s*\(.\{-}\)\)\?\)\?\s*}'
    let remaining = match(ext_reg, composition_atom)
    while remaining != -1
      let [_, name, cnt, sep ;__] = matchlist(ext_reg, composition_atom)
      let cnt = cnt ? cnt : 1
      let sep = escape(escape(sep, '.*[]$^'), '\\')
      let pattern = escape(self.lookup(name), '\\' )
      let ext_reg = substitute(ext_reg, composition_atom, join(repeat([pattern], cnt), sep), '')
      let remaining = match(ext_reg, composition_atom)
    endwhile
    return ext_reg
  endfunc

  func erex.expand(ext_reg) dict
    return self.expand_composition_atom(a:ext_reg)
  endfunc

  func erex.parse_multiline_regex(ext_reg) dict
    return substitute(substitute(substitute(a:ext_reg, '#\s\+\S\+', '', 'g'), '\\\@<! ', '', 'g'), '\(\\\\\)\@<=\zs\s\+', '', 'g')
  endfunc

  " common public API

  func erex.register_lookup(callback) dict
    let self.lookup_function = a:callback
  endfunc

  func erex.register_lookup_dict(dict) dict
    let self.lookup_dict = a:dict
  endfunc

  func erex.parse(ext_reg) dict
    return self.expand(self.parse_multiline_regex(a:ext_reg))
  endfunc

  if a:0
    call erex.register_lookup(a:1)
    if a:0 > 1
      call erex.register_lookup_dict(a:2)
    endif
  endif

  return erex
endfunction

"reset &cpo back to users setting
let &cpo = s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
