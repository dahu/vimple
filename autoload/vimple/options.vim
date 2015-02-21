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
  if exists('g:vimple#op')
    return deepcopy(g:vimple#op).update()
  endif
  let op = {}
  let op.__options = {}
  let op.__filter = ''
  let op.__update_with_map = 0

  " update {{{2
  func op.update() dict abort
    if self.__update_with_map
      call map(self.__options, 'extend(v:val, {"value": eval("&".v:key)}, "force")')
      " Preserve filter.
      if !empty(self.__filter)
        call filter(self.__options, self.__filter)
      endif
      return self
    endif

    silent! options
    let content = getline(1, '$')
    close
    bwipe option-window

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
        let [type, short] = matchlist(l, '^ \(\w\+\) \(\w\+\)')[1:2]
        call extend(self.__options[long], {'type' : type, 'short' : short, 'value': eval('&'.long)})
      endif
    endfor

    for o in items(self.__options)
      call extend(o[1], {'scope' : (o[1].desc =~ '(.\{-}local.\{-})' ? matchstr(o[1].desc, '(\zs.\{-}\ze)') : 'global')})
      call extend(self.__options, {o[1].short : o[1]})
    endfor

    " Preserve filter.
    if !empty(self.__filter)
      call filter(self.__options, self.__filter)
    endif
    let self.__update_with_map = 1
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
    let default = "%-15l %-2p %1t %v\n"
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
            \   'v': ['s', o[1]['value']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " changed {{{2
  func op.changed() dict
    return self.filter('v:val.value !=# eval("&".v:key)')
  endfunc

  " short {{{2
  func op.short() dict
    return self.filter('v:val.short ==# v:key')
  endfunc

  " long {{{2
  func op.long() dict
    return self.filter('v:val.long ==# v:key')
  endfunc

  " print {{{2
  " only able to colour print the default to_s() output at this stage
  func op.print() dict
    "let str = self.to_s()
    " following code is from hl.print() and would not work as is here
    "let dta = map(split(str, "\n"), '[split(v:val, " ")[0], v:val . "\n"]')
    "call vimple#echoc(dta)
    let pairs = []
    let changed = self.changed()
    let max_name = max(map(values(map(copy(self.__options), 'v:val.long." ".v:val.short.""')), 'len(v:val)'))
    for key in sort(keys(self.long().__options))
      let option = self.__options[key]
      call add(pairs, ['vimple_BL_Number', option.long])
      call add(pairs, ['Normal', ' ('])
      call add(pairs, ['vimple_BL_Hidden', option.short])
      call add(pairs, ['Normal', ')' . repeat(' ', max_name - len(option.short) - len(option.long))])
      let len = len(option.value)
      if len < &columns
        call add(pairs, ['Normal', option.value . "\<NL>"])
      else
        let screen_len = &columns - max_name - 6
        let i = 0
        while i <= len
           let j = i + screen_len
           call add(pairs, ['Normal', repeat(' ',  i == 0 ? 0 : max_name + 3) . option.value[i : j] . "\<NL>"])
           let i = j + 1
        endwhile
      endif
      if has_key(changed.__options, key)
        let len = len(eval('&'.key))
        if len < &columns
          call add(pairs, ['vimple_BL_Alternate', repeat(' ',  max_name + 3) . eval('&'.key) . "\<NL>"])
        else
          let screen_len = &columns - max_name - 6
          let i = 0
          while i <= len
            let j = i + screen_len
            call add(pairs, ['vimple_BL_Alternate', repeat(' ',  max_name + 3) . eval('&'.key)[i : j] . "\<NL>"])
            let i = j + 1
          endwhile
        endif
      endif
    endfor
    call vimple#echoc(pairs)
    " Remove the last <NL>. Why?
    let pairs[-1][1] = pairs[-1][-1][:-2]
    return pairs
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
