function! vimple#associate#associate(lines, subs, maps)
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
