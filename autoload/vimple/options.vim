""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for options
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's options
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/options.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#options.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#options
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

function! vimple#options#new()
  let op = {}
  let op.__options = {}
  let op.__filter = ''

  " update {{{2
  func op.update() dict abort
    let self.__options = {}
    silent! tabnew
    silent! options
    silent! g/^\(".*\)\?\s*$/d
    silent! g/^\s*\d/d
    silent! %s/^ \tset \(\w\+\)\t\(\w\+\)/\=" bool " . (submatch(1) !~? '^no' ? submatch(1) : submatch(2)) . " " . (submatch(1) !~? '^no')
    silent! %s/^ \tset \(\w\+\)=/ string \1 /

    let long = ''
    for l in getline(1, '$')
      if l =~ '^\w'
        let [long, desc] = split(l, '\t')
        let self.__options[long] = {}
        let self.__options[long] = {'long' : long, 'desc' : desc}
      elseif l =~ '^\t'
        let self.__options[long].desc .= ' ' . matchstr(l, '^\t\zs.*')
      else
        let [type, short, value] = matchlist(l, '^ \(\w\+\) \(\w\+\) \(.*\)')[1:3]
        call extend(self.__options[long], {'type' : type, 'short' : short, 'value' : value})
      endif
    endfor

    tabclose

    for o in items(self.__options)
      call extend(o[1], {'scope' : (o[1].desc =~ '(.\{-}local.\{-})' ? matchstr(o[1].desc, '(\zs.\{-}\ze)') : 'global')})
      call extend(self.__options, {o[1].short : o[1]})
    endfor

    return self
  endfunc

  " to_d {{{2
  func op.to_d(...) dict
    return self.__options
  endfunc

  " to_l {{{2
  func op.to_l(...) dict
    return map(items(self.__options), '[v:val[0], v:val[1].value]')
  endfunc

  " TODO: What format should to_s() show?
  " to_s {{{2
  func op.to_s(...) dict
    return "Not implemented yet"
  endfunc

  " print {{{2
  " only able to colour print the default to_s() output at this stage
  " Note: This is a LOT of dancing just to get coloured numbers ;)
  func op.print() dict
    call self.update()
    call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  endfunc

  " filter {{{2
  func op.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__options, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  " filter_by_name {{{2
  func op.filter_by_name(name) dict abort
    return self.filter('v:val["script"] =~ "' . escape(a:name, '"') . '"')
  endfunc

  call op.update()
  return op
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
