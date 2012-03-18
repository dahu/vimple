"function! vimple#associate#associate(lines, pattern, replacement, names)
function! vimple#associate#associate(lines, subs, maps)
  "let lst = repeat([''], len(a:lines))
  let lst = copy(a:lines)
  for s in a:subs
    for i in range(0, len(lst) - 1)
      let lst[i] = substitute(lst[i], s[0], s[1], '')
    endfor
  endfor
  call map(lst, 'split(v:val, ",")')
  for m in a:maps
    call map(lst, m)
  endfor
  return lst
endfunction
