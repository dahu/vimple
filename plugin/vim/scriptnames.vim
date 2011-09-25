function! Scriptnames(...)
  let l:sn = Redir('scriptnames')
  let l:pat = '.'
  if a:0
    let l:pat = a:1
  endif
  return filter(l:sn, 'v:val =~ "'.l:pat.'"')
endfunction

function! Associate(lines, pattern, replacement, names)
  let lst = repeat([''], len(a:lines))
  for i in range(0, len(a:lines) - 1)
    let lst[i] = substitute(a:lines[i], a:pattern, a:replacement, '')
  endfor
  call map(lst, 'split(v:val, ",")')
  return map(lst, a:names)
endfunction

echo Associate(Scriptnames('vimple'),
      \ '^\s*\(\d\+\):\s*\(.*\)$',
      \ '\1,\2',
      \ '{"number": v:val[0], "name": v:val[1]}')

