""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :map builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :map command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/scriptnames.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#map.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#map
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard
" uncomment after plugin development
"if exists("g:loaded_lib_vimple")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
"let g:loaded_lib_vimple = 1

" TODO: Use the Numerically sort comparator for print()

function! vimple#map#new()
  let m = {}
  let m.__data = {}
  let m.__filter = ''

  func m.update() dict abort
    let self.__data = vimple#associate(vimple#redir('map') + vimple#redir('map!'),
          \ [['',
          \ '', '']],
          \ ['[matchstr(v:val, ''^.''),
          \    matchstr(v:val, ''^.\s\+\zs\S\+''),
          \    matchstr(v:val, ''^.\s\+\S\+\s\+\zs[*& ]\ze[@ ]\S''),
          \    matchstr(v:val, ''^.\s\+\S\+\s\+[*& ]\zs[@ ]\ze\S''),
          \    matchstr(v:val, ''^.\s\+\S\+\s\+[*& ][@ ]\zs\S.*'')
          \  ]',
          \  '{"normal"   : v:val[0] =~ "[n ]",
          \    "visual"   : v:val[0] =~ "[vx ]",
          \    "select"   : v:val[0] =~ "[vs ]",
          \    "operator" : v:val[0] =~ "[o ]",
          \    "insert"   : v:val[0] =~ "[i!]",
          \    "lang"     : v:val[0] =~ "l",
          \    "command"  : v:val[0] =~ "[c!]",
          \    "lhs"  : v:val[1],
          \    "remappable"  : v:val[2] != "*",
          \    "script_remappable"  : v:val[2] == "&",
          \    "buffer"  : v:val[3] == "@",
          \    "rhs"  : v:val[4]
          \  }'])
    return self
  endfunc

  func m.to_s(...) dict
    let default = "%3n %s\n"
    "let format = default
    let format = a:0 && a:1 != '' ? a:1 : default
    let scripts = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    for i in range(0, len(scripts) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'n': ['d', scripts[i]['number']],
            \   's': ['s', scripts[i]['script']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " only able to colour print the default to_s() output at this stage
  " Note: This is a LOT of dancing just to get coloured numbers ;)
  func m.print() dict
    call self.update()
    call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  endfunc

  func m.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func m.lhs_is(lhs) dict abort
    return self.filter('v:val["lhs"] ==# "' . escape(a:lhs, '\"') . '"')
  endfunc

  call m.update()
  return m
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:

