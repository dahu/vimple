function! vimple#associate#associate(lines, pattern, replacement, names)
  let lst = repeat([''], len(a:lines))
  for i in range(0, len(a:lines) - 1)
    let lst[i] = substitute(a:lines[i], a:pattern, a:replacement, '')
  endfor
  call map(lst, 'split(v:val, ",")')
  return map(lst, a:names)
endfunction
