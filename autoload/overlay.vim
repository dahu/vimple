function! overlay#controller(...)
  if a:0
    for [key, act] in items(a:1)
      exe 'nnoremap <buffer> ' . key . ' ' . act
    endfor
  endif
endfunction

let s:overlay_count = 1

function! overlay#show(list, actions, ...)
  let s:altbuf = bufnr('#')

  let options = {
        \ 'filter'    : 1,
        \ 'use_split' : 0,
        \ 'auto_act'  : 0,
        \ 'name'      : '__overlay__'
        \ }
  if a:0
    if type(a:1) == type({})
      call extend(options, a:1)
    endif
  endif

  if options.name == '__overlay__'
    let options.name .= s:overlay_count . '__'
    let s:overlay_count += 1
  endif

  if options.use_split
    hide noautocmd split
  endif
  hide noautocmd enew
  let b:overlay_use_split = options.use_split
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal foldmethod=manual
  setlocal foldcolumn=0
  setlocal nospell
  setlocal modifiable
  setlocal noreadonly
  exe 'file ' . options.name

  let old_is = &incsearch
  set incsearch
  let old_hls = &hlsearch
  set hlsearch
  call append(0, a:list)
  $
  delete _
  " redraw
  1
  if options.filter
    if exists(':Filter')
      Filter
    else
      call feedkeys('/')
    endif
  endif
  call overlay#controller(a:actions)
  if options.auto_act
    if line('$') == 1
      call feedkeys("\<enter>")
    endif
  endif
endfunction

function! overlay#close()
  if b:overlay_use_split
    let scratch_buf = bufnr('')
    wincmd q
    exe 'bwipe ' . scratch_buf
  else
    buffer #
    bwipe #
    if buflisted(s:altbuf)
      exe 'buffer ' . s:altbuf
      silent! buffer #
    endif
  endif
endfunction

function! overlay#select_line()
  let line = getline('.')
  call overlay#close()
  return line
endfunction

function! overlay#select_buffer()
  let lines = getline(1,'$')
  call overlay#close()
  return lines
endfunction

function! overlay#command(cmd, actions, options)
  call overlay#show(vimple#redir(a:cmd), a:actions, a:options)
endfunction
