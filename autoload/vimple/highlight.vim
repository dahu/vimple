""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :highlight builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :highlight command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/highlight.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#highlight.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#highlight
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
" Highlight object

function! vimple#highlight#new()
  let hl = {}
  let hl.__data = {}
  let hl.__filter = ''

  func hl.update() dict abort
    let self.__data = vimple#associate(vimple#join(vimple#redir('highlight'), '^\s\+'),
          \ [['^\(\S\+\)\s*\S\+\s*\(.*\)$', '\1\t\2', '']],
          \ ['split(v:val, "\t", 2)',
          \  '{"term": v:val[0],'
          \.  '"attrs": substitute(v:val[1], "\\s\\+", " ", "g")}'])
    return self
  endfunc

  " takes two optional arguments:
  " 1 : format
  " 2 : data
  func hl.to_s(...) dict
    let default = "%t %a\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let data = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    let data = sort(data, 'vimple#comparators#termly')
    for i in range(0, len(data) - 1)
      let str .= vimple#format(
            \ format,
            \ { 't': ['s', data[i]['term']],
            \   'a': ['s', data[i]['attrs']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  func hl.to_l(...) dict
    return self.__data
  endfunc

  " only able to colour print the default to_s() output at this stage
  func hl.print() dict
    let str = self.to_s()
    let dta = map(split(str, "\n"), '[split(v:val, " ")[0], v:val . "\n"]')
    call vimple#echoc(dta)
  endfunc

  func hl.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func hl.filter_by_term(term) dict abort
    return self.filter('v:val["term"] =~ "' . escape(a:term, '"') . '"')
  endfunc

  func hl.sort()
    return sort(self.__data, vimple#comparators#termly)
  endfunc

  call hl.update()
  return hl
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
