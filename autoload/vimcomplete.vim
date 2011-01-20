function! vimcomplete#Complete(findstart, base)
  "findstart = 1 when we need to get the text length
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a\|[:#]'
      let start -= 1
    endwhile
    return start
    "findstart = 0 when we need to return the list of completions
  else
   redir => l:funcs
   silent! function
   redir END
   let l:complete = []
   if a:base =~ "^[bglsw]:"
     let type = strpart(a:base, 0, 1)
     let base = strpart(a:base, 2)
     exe "let vars = keys(".type.":)"
     for key in filter(vars, 'v:val =~ "^'.base.'"')
       call add(l:complete, {'word' : type . ':' . key, 'abbr' : key, 'kind' : 'v'})
     endfor
   else
     " global variables
     for key in filter(keys(g:), 'v:val =~ "^'.a:base.'"')
       call add(l:complete, {'word' : 'g:' . key, 'abbr' : key, 'kind' : 'v'})
     endfor

     " non-builtin functions
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
   endif
   return l:complete
 endif
endfunction

finish

" global vars and functions with partial
let NERDT
" library function
let fuf#o
" all global vars and functions
let 
" explicit vars
let g:
let b:
let l:
let s:
let w:

