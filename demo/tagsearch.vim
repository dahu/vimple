" Are you bored with vanilla g] ?
" Did the improvement above :help g] excite you only briefly?
" Want a better experience?
" Overlay is here for you.

" In the overlay window:
" You're prompted with a filter pattern. Use <esc> to cancel.
" <enter> jumps to the current-line tag-search match
" q closes the overlay without action

function! TagSearch()
  let ident = expand('<cword>')
  let s:tags = taglist(ident)
  if empty(s:tags)
    echohl Warning
    echom 'Tag not found: ' . ident
    echohl None
    return
  endif
  let data = map(copy(s:tags), 'v:key . " " . v:val.name . "\t" . v:val.filename')
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call TagSearchAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! TagSearchAccept()
  let ident = matchstr(overlay#select_line(), '^\d\+')
  let fname = s:tags[ident].filename
  if bufnr(fname) == -1
    exec 'edit ' . fname
  else
    exec 'buffer ' . fname
  endif
  silent! exe s:tags[ident].cmd
endfunction

nnoremap g] :call TagSearch()<cr>
