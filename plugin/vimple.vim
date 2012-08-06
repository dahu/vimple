function! View(cmd)
  let buf = vimple#redir(a:cmd)

  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, buf)
endfunction

command! -nargs=+ -complete=command View call View(<q-args>)

" Pre-initialise library objects
let vimple#bl = vimple#ls#new()
let vimple#hl = vimple#highlight#new()
let vimple#sn = vimple#scriptnames#new()

call vimple#default_colorscheme()
