""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple Sort Comparators
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple sort comparators
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/comparators.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#comparators.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#comparators
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

function! vimple#comparators#numerically(i1, i2)
  let i1 = str2nr(a:i1)
  let i2 = str2nr(a:i2)
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

function! vimple#comparators#abbrly(i1, i2)
  let i1 = a:i1['abbr']
  let i2 = a:i2['abbr']
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

function! vimple#comparators#termly(i1, i2)
  let i1 = a:i1['term']
  let i2 = a:i2['term']
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

function! vimple#comparators#rhsly(i1, i2)
  let i1 = matchstr(a:i1['rhs'], '\c^.*\zs<plug>.*')
  let i2 = matchstr(a:i2['rhs'], '\c^.*\zs<plug>.*')
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

function! vimple#comparators#lhsly(i1, i2)
  let i1 = a:i1['lhs']
  let i2 = a:i2['lhs']
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
