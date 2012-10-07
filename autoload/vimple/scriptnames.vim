""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :scriptnames builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :scriptnames command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/scriptnames.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#scriptnames.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#scriptnames
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

function! vimple#scriptnames#new()
  let sn = {}
  let sn.__scripts = {}
  let sn.__filter = ''

  " update {{{2
  func sn.update() dict abort
    let self.__scripts = vimple#associate(vimple#redir('scriptnames'),
          \ [['^\s*\(\d\+\):\s*\(.*\)$',
          \ '\1,\2', '']],
          \ ['split(v:val, ",")', '{"number": v:val[0], "script": v:val[1]}'])
    return self
  endfunc

  " to_l {{{2
  func sn.to_l(...) dict
    return self.__scripts
  endfunc

  " to_s {{{2
  func sn.to_s(...) dict
    let default = "%3n %s\n"
    "let format = default
    let format = a:0 && a:1 != '' ? a:1 : default
    let scripts = a:0 > 1 ? a:2.__scripts : self.__scripts
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

  " print {{{2
  " only able to colour print the default to_s() output at this stage
  " Note: This is a LOT of dancing just to get coloured numbers ;)
  func sn.print() dict
    call self.update()
    call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  endfunc

  " filter {{{2
  func sn.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__scripts, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  " filter_by_name {{{2
  func sn.filter_by_name(name) dict abort
    return self.filter('v:val["script"] =~ "' . escape(a:name, '"') . '"')
  endfunc

  call sn.update()
  return sn
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
