""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :marks builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :marks command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/scriptnames.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#marks.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#marks
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

function! vimple#marks#new()
  let m = {}
  let m.__data = {}
  let m.__filter = ''

  func m.update() dict abort
    let self.__data = vimple#associate(vimple#redir('marks')[1:-1],
          \ [['^\s*', '', '']],
          \ ['split(v:val)',
          \  '{"mark"   : v:val[0],
          \    "line"   : v:val[1],
          \    "col"    : v:val[2],
          \    "text"   : substitute(join(v:val[3:-1], " "), "\n", "", ""),
          \  }'])

    return self
  endfunc

  func m.to_s(...) dict
    let default = "%2m %5l %4o %t\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let marks = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    for i in range(0, len(marks) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'm': ['s', marks[i]['mark']],
            \   'l': ['d', marks[i]['line']],
            \   'o': ['d', marks[i]['col']],
            \   't': ['s', marks[i]['text']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  func m.to_l() dict
    return self.__data
  endfunc

  " " only able to colour print the default to_s() output at this stage
  " " Note: This is a LOT of dancing just to get coloured numbers ;)
  " func m.print() dict
  "   call self.update()
  "   call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  " endfunc

  "TODO: This looks like a candidate for moving into the parent class... no?
  func m.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func m.lhs_is(lhs) dict abort
    return self.filter('v:val["lhs"] ==# "' . escape(a:lhs, '\"') . '"')
  endfunc

  func m.local_marks() dict abort
    return self.filter('v:val["mark"] =~# "[a-z]"')
  endfunc

  func m.global_marks() dict abort
    return self.filter('v:val["mark"] =~# "[A-Z]"')
  endfunc

  call m.update()
  return m
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:

