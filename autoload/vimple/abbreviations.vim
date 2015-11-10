""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :abbreviations builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :abbreviations command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/abbreviations.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#abbreviations.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#abbreviations
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
" abbreviations object

function! vimple#abbreviations#new()
  let ab = {}
  let ab.__data = {}
  let ab.__filter = ''

  func ab.update() dict abort
    let self.__data = vimple#associate(vimple#join(vimple#redir('iabbrev'), '^\s\+'),
          \ [['^\S\+\s*\(\S\+\)\s*\(.*\)$', '\1\t\2', '']],
          \ ['split(v:val, "\t", 2)',
          \  '{"abbr": v:val[0],'
          \.  '"type": "i",'
          \.  '"expansion": substitute(v:val[1], "\\s\\+", " ", "g")}'])
    return self
  endfunc

  " takes two optional arguments:
  " 1 : format
  " 2 : data
  func ab.to_s(...) dict
    let default = "%t %a %e\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let data = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    let data = sort(data, 'vimple#comparators#abbrly')
    for i in range(0, len(data) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'a': ['s', data[i]['abbr']],
            \   't': ['s', data[i]['type']],
            \   'e': ['s', data[i]['expansion']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  func ab.to_l(...) dict
    return self.__data
  endfunc

  " only able to colour print the default to_s() output at this stage
  func ab.print() dict
    let str = self.to_s()
    let dta = map(split(str, "\n"), '[split(v:val, " ")[0], v:val . "\n"]')
    call vimple#echoc(dta)
  endfunc

  func ab.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func ab.filter_by_abbr(abbr) dict abort
    return self.filter('v:val["abbr"] =~ "' . escape(a:abbr, '"') . '"')
  endfunc

  func ab.sort()
    return sort(self.__data, vimple#comparators#abbrly)
  endfunc

  call ab.update()
  return ab
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
