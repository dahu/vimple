function! vimcomplete#Complete(findstart, base)
  "findstart = 1 when we need to get the text length
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
    "findstart = 0 when we need to return the list of completions
  else
   redir => l:funcs
   silent! function
   redir END
   let l:funclist = map(filter(split(l:funcs, "\n"), 'v:val !~ "\<SNR\>" && v:val =~ "^function '.a:base.'"'), 'substitute(v:val, "^function ", "", "")')
   return l:funclist
  endif
endfunction
