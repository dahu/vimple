 " TODO rename vfm variables.

function! overlay#controller(...)
  nnoremap <buffer> q :call overlay#close()<cr>
  nnoremap <buffer> cv :v//d<cr>
  if a:0
    for [key, act] in items(a:1)
      exe 'nnoremap <buffer> ' . key . ' ' . act
    endfor
  endif
endfunction

function! overlay#show_list(list, ...)
  let s:altbuf = bufnr('#')

  let options = {
        \ 'filter': 1,
        \ 'use_split': 0,
        \ }
  if a:0
    if type(a:1) == type({})
      call extend(options, a:1)
    endif
  endif

  if options.use_split
    hide noautocmd split
  endif
  hide noautocmd enew
  let b:overlay_use_split = options.use_split
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  let old_is = &incsearch
  set incsearch
  let old_hls = &hlsearch
  set hlsearch
  call append(0, a:list)
  $
  delete _
  redraw
  1
  if options.filter
    if exists(':Filter')
      Filter
    else
      call feedkeys('/')
    endif
  endif
  if g:vfm_auto_act_on_single_filter_result
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


