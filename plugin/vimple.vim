function! View(cmd)
  let buf = vimple#redir(a:cmd)

  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call append(0, buf)
endfunction

command! -nargs=+ -complete=command View call View('<args>')
