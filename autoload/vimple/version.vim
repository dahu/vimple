""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :version builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :version command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/version.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#version.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#version
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

function! vimple#version#new()
  let vn = {}
  let vn.__info = {}
  let vn.__filter = ''

  " update {{{2
  func vn.update() dict abort
    let i = self.__info
    let info = vimple#associate(vimple#redir('version'), [], [])

    let [i['version'], i['major'], i['minor'], i['build_name'], i['compiled']] =
          \ split(
          \   substitute(info[0]
          \   , '^N\?VIM.\{-}\(\(\d\+\)\.\(\d\+\)\).\{-}'
          \       . '(\(.\{-}\)\%(,\s\+\S\+\s\+\(.\{-}\)\)\?)'
          \   , '\1\n\2\n\3\n\4\n\5', '')
          \ , "\n", 1)
    let i['patches'] = substitute(info[1], '^.*:\s\+\(.*\)', '\1', '')
    let i['compiled_by'] = info[2]
    let i['build_version'] = substitute(info[3], '^\(.\{-}\)\..*', '\1', '')
    let i['features'] = {}
    for line in range(4, len(info))
      if (info[line] =~ '^\s*$') || (info[line] =~ '^\s\+.*:\s')
        break
      endif
      call map(split(info[line], '\s\+'),
            \ 'extend(i["features"], {strpart(v:val, 1) : (v:val =~ "^+" ? 1 : 0)})')
    endfor
    return self
  endfunc

  " to_l {{{2
  func vn.to_l(...) dict
    return self.__info
  endfunc

  " " to_s {{{2
  " func vn.to_s(...) dict
  "   let default = "%3n %s\n"
  "   "let format = default
  "   let format = a:0 && a:1 != '' ? a:1 : default
  "   let scripts = a:0 > 1 ? a:2.__info : self.__info
  "   let str = ''
  "   for i in range(0, len(scripts) - 1)
  "     let str .= vimple#format(
  "           \ format,
  "           \ { 'n': ['d', scripts[i]['number']],
  "           \   's': ['s', scripts[i]['script']]},
  "           \ default
  "           \ )
  "   endfor
  "   return str
  " endfunc

  " " print {{{2
  " " only able to colour print the default to_s() output at this stage
  " " Note: This is a LOT of dancing just to get coloured numbers ;)
  " func vn.print() dict
  "   call self.update()
  "   call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  " endfunc

  " filter {{{2
  func vn.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__info["features"], a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  " filter_by_name {{{2
  func vn.filter_by_name(name) dict abort
    return self.filter('v:key =~ "' . escape(a:name, '"') . '"')
  endfunc

  call vn.update()
  return vn
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
