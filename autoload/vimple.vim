"let str = vimple#format#format(
"      \ format,
"      \ { 'b': ['d', 1],
"      \   'f': ['s', "abc"],
"      \   'n': ['s', "efg"],
"      \   'l': ['s', "hij"]},
"      \ default
"      \ )

func vimple#format(format, args_d, default)
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
endfunc

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

