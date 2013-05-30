function! View(cmd)
  let buf = vimple#redir(a:cmd)

  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, buf)
endfunction

command! -nargs=+ -complete=command View call View(<q-args>)

function! Collect(args)
  let [regvar; command] = split(a:args)
  let cmd = join(command, " ")
  let list = &list
  set nolist
  let buf = join(vimple#redir(cmd), "\n")
  if list
    set list
  endif
  if len(regvar) > 1
    exe 'let ' . regvar . '="' . escape(buf, '"') . '"'
  else
    call setreg(regvar, buf)
  endif
endfunction

command! -nargs=+ Collect call Collect(<q-args>)

command! -nargs=+ Silently exe join(map(split(<q-args>, '|'), '"silent! ".v:val'), '|')

" Pre-initialise library objects
let vimple#bl = vimple#ls#new()
let vimple#hl = vimple#highlight#new()
let vimple#sn = vimple#scriptnames#new()
let vimple#vn = vimple#version#new()
let vimple#ma = vimple#marks#new()
let vimple#ul = vimple#undolist#new()

call vimple#default_colorscheme()
