function! vimple#redir#redir(command)
  let l:str = ''
  redir => l:str
  silent exe a:command
  redir END
  return split(l:str, "\n")
endfunction
