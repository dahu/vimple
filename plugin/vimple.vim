function! View(cmd)
  let buf = vimple#redir(a:cmd)

  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, buf)
endfunction

command! -nargs=+ -complete=command View call View(<q-args>)

function! Collect(reg, cmd)
  let list = &list
  set nolist
  let buf = join(vimple#redir(a:cmd), "\n")
  if list
    set list
  endif
  call setreg(a:reg, buf)
endfunction

command! -nargs=+ -register Collect call Collect(<q-reg>, <q-args>)

" Pre-initialise library objects
let vimple#bl = vimple#ls#new()
let vimple#hl = vimple#highlight#new()
let vimple#sn = vimple#scriptnames#new()
let vimple#vn = vimple#version#new()

call vimple#default_colorscheme()
