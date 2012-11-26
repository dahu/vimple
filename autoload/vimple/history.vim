""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :history builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :history command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/history.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#history.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#history
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

function! vimple#history#new()
  let hist = {}
  let hist.__commands = {}
  let hist.__filter = ''

  func hist.update() dict abort
    let self.__commands = vimple#associate(vimple#redir('history'),
          \ [['^\s*#.*', '', ''],
          \ ['[^0-9]*\(\%(\d\+\)\|#\)\s*\(.*\)$', '\1-=-=\2', '']],
          \ ['split(v:val, "-=-=")', '{"number": v:val[0], "command": v:val[1]}'])
    return self
  endfunc

  func hist.to_s(...) dict
    let default = "%3n %s\n"
    "let format = default
    let format = a:0 && a:1 != '' ? a:1 : default
    let commands = a:0 > 1 ? a:2.__commands : self.__commands
    let str = ''
    for i in range(0, len(commands) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'n': ['d', commands[i]['number']],
            \   's': ['s', commands[i]['command']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " only able to colour print the default to_s() output at this stage
  " Note: This is a LOT of dancing just to get coloured numbers ;)
  func hist.print() dict
    call self.update()
    call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  endfunc

  func hist.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__commands, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func hist.filter_by_name(name) dict abort
    return self.filter('v:val["command"] =~ "' . escape(a:name, '"') . '"')
  endfunc

  call hist.update()
  return hist
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
