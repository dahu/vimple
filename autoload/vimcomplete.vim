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
   let l:complete = []
   for l:func in map(filter(split(l:funcs, "\n"), 'v:val !~ "\<SNR\>" && v:val =~ "^function '.a:base.'"'), 'substitute(v:val, "^function ", "", "")')
     let l:spos = match(l:func, '(')
     let l:epos = match(l:func, ')')
     " actual text inserted (in 'word')
     let l:word = strpart(l:func, 0, l:spos)
     " get arguments for preview windo (in 'info')
     let l:info = strpart(l:func, l:spos+1, l:epos - l:spos - 1)
     if l:info == ''
       let l:info = ' '
     endif
     " build completion list
     call add(l:complete, {'word' : l:word, 'abbr' : l:func, 'info' : l:info, 'kind' : 'f'})
   endfor
   return l:complete
  endif
endfunction
