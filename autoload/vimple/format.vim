"let str = vimple#format#format(
"      \ format,
"      \ { 'b': ['d', 1],
"      \   'f': ['s', "abc"],
"      \   'n': ['s', "efg"],
"      \   'l': ['s', "hij"]},
"      \ default
"      \ )

func vimple#format#format(format, args_d, default)
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

