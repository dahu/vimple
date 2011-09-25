function! Scriptnames(...)
  let l:sn = Redir('scriptnames')
  let l:pat = '.'
  if a:0
    let l:pat = a:1
  endif
  return join(filter(l:sn, 'v:val =~ "'.l:pat.'"'), "\n")
endfunction
