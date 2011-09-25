function! Scriptnames(...)
  let l:sn = Redir('scriptnames')
  let l:pat = '.'
  if a:0
    let l:pat = a:1
  endif
  return join(filter(l:sn, 'v:val =~ "'.l:pat.'"'), "\n")
  "    "
endfunction

function! Associate(lines, pattern, replacement, names)
  let lst = []
  for i in range(0, len(a:lines) - 1)
    let lst[i] = substitute(a:lines[i], a:pattern, a:replacement, '')
  endfor
endfunction

echo Associate(Scriptnames('vimple'),
      \ "^\s*\(\d\+\):\s*\(.*\)",
      \ '\1,\2',
      \ ['number', 'name'])

