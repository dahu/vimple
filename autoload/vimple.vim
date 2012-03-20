"let str = vimple#format(
"      \ format,
"      \ { 'b': ['d', 1],
"      \   'f': ['s', "abc"],
"      \   'n': ['s', "efg"],
"      \   'l': ['s', "hij"]},
"      \ default
"      \ )

function! vimple#format(format, args_d, default)
  let format = a:format == '' ? a:default : a:format
  let format = substitute(format, '\(%%\)*\zs%[-0-9#+ .]*c', a:default, 'g')

  let args = ''
  let items = map(split(substitute(format, '%%', '', 'g'), '\ze%'), 'matchstr(v:val, ''^%[-+#. 0-9]*.'')')
  call map(items, 'substitute(v:val, ''^%[-0-9#+ .]*\(.\)'', ''\1'', "g")')
  for item in items
    let arg_l = get(a:args_d, item, '')
    if type(arg_l) != type([])
      continue
    endif
    let args .= arg_l[0] == 's' ? string(arg_l[1]) : arg_l[1]
    let args .= args[-1] =~ ',' ? '' : ', '
  endfor
  let args = substitute(args, '^\s*,\s*\(.\{-}\),\s*$', '\1', '')

  let format = substitute(format, '\%(%%\)*%[-1-9#+ .]*\zs.', '\=get(a:args_d[submatch(0)], 0,submatch(0))', 'g')
  let printf_str ='printf("'.escape(format, '\"').'", '.args.')'

  return eval(printf_str)
endfunction

function! vimple#redir(command, ...)
  let split_pat = '\n'
  let str = ''
  if a:0 != 0
    let split_pat = a:1
  endif
  redir => str
  silent exe a:command
  redir END
  return split(str, split_pat)
endfunction

function! vimple#associate(lines, subs, maps)
  let lst = copy(a:lines)
  for i in range(0, len(lst) - 1)
    for s in a:subs
      let lst[i] = substitute(lst[i], s[0], s[1], s[2])
    endfor
  endfor
  for m in a:maps
    call map(lst, m)
  endfor
  return lst
endfunction

function! vimple#join(data, pattern)
  let x = -1
  let lines = repeat([''], len(a:data))
  for line in a:data
    if line =~ a:pattern
      let lines[x] .= line
    else
      let x += 1
      let lines[x] = line
    endif
  endfor
  return filter(lines, 'v:val !~ "^$"')
endfunction

function! vimple#echoc(data)
  for sets in a:data
    exe "echohl " . sets[0]
    exe "echon " . string(sets[1])
  endfor
endfunction

function! s:vimple_highlight(name, attrs)
  try
    silent exe "hi ".a:name
  catch /^Vim\%((\a\+)\)\=:E411/
    silent exe "hi ".a:name." ".a:attrs
  endtry
endfunction

" Solarized inspired default colours...
" Doesn't override existing user-defined colours for these highlight terms.
" Shown with case here, but actually case-insensitive within Vim.
function! vimple#default_colorscheme()
  call s:vimple_highlight('BL_Number'     , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Line'       , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Name'       , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Listed'     , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Current'    , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Alternate'  , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Active'     , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Hidden'     , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Modifiable' , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Readonly'   , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_Modified'   , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
  call s:vimple_highlight('BL_ReadError'  , 'ctermfg=blue ctermbg=green guifg=blue guibg=green')
endfunction

call vimple#default_colorscheme()
