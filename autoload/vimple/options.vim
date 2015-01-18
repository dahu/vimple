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

    silent! options
    let content = getline(1, '$')
    close

    let long = ''
    for l in content
      if l =~ '^\s*\%(".*\)\?$'
        continue
      elseif l =~ '^\s*\d'
        continue
      elseif l =~ '^\w'
        let [long, desc] = split(l, '\t')
        let self.__options[long] = {}
        let self.__options[long] = {'long' : long, 'desc' : desc}
      elseif l =~ '^\t'
        let self.__options[long].desc .= ' ' . matchstr(l, '^\t\zs.*')
      else
        if l =~ 'set \w\+='
          let l = substitute(l, '^ \tset \(\w\+\)=', ' string \1 ', '')
        else
          let l = substitute(l, '^ \tset \(\w\+\)\t\(\w\+\)', '\=" bool " . (submatch(1) !~? "^no" ? submatch(1) : submatch(2)) . " " . (submatch(1) !~? "^no")', '')
        endif
        let [type, short, value] = matchlist(l, '^ \(\w\+\) \(\w\+\) \(.*\)')[1:3]
        let default = ''
        "TODO: Is there a better way to handle these two troublesome options?
        " toggling background messes with the colorscheme
        " scroll seems to need a valid window size not available at start (?)
        if index(['background', 'compatible', 'scroll', 'term', 'ttytype'], long) == -1
          exe 'set ' . short . '&vim'
          let default = escape(eval('&' . short), " \t\\\"\|")
          if type == 'bool'
            if value != 0
              exe 'set ' . short
            else
              exe 'set no' . short
            endif
          else
            exe 'set ' . short . '=' . value
          endif
        endif
        call extend(self.__options[long], {'type' : type, 'short' : short, 'value' : value, 'default' : default})
      endif
    endfor

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

  " to_s {{{2
  func op.to_s(...) dict
    let default = "%-15l %-2p %1t %v%f\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let opts = a:0 > 1 ? a:2.__options : self.__options
    let str = ''
    for o in sort(items(opts))
      let str .= vimple#format(
            \ format,
            \ { 'l': ['s', o[1]['long']],
            \   's': ['s', o[1]['short']],
            \   'd': ['s', o[1]['desc']],
            \   'p': ['s', join(map(filter(split(o[1]['scope']), 'index(["or", "local", "to"], v:val) == -1'), 'strpart(v:val, 0, 1)'), '')],
            \   't': ['s', strpart(o[1]['type'], 0, 1)],
            \   'f': ['s', o[1]['value'] == o[1]['default'] ? '' : ' [' . o[1]['default'] . ']'],
            \   'v': ['s', o[1]['value']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " print {{{2
  " only able to colour print the default to_s() output at this stage
  func op.print() dict
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
    return self.filter('v:val["long"] =~ "' . escape(a:name, '"') . '"')
  endfunc

  call op.update()
  return op
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
