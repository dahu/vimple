" Are you bored with vanilla [I ?
" Did the improvement above :help [i excite you only briefly?
" Want a better experience?
" Overlay is here for you.

" In the overlay window:
" You're prompted with a filter pattern. Use <esc> to cancel.
" <enter> jumps to the current-line ident-search match
" q closes the overlay without action

function! IdentSearch()
  try
    let data = vimple#redir('norm! [I')
  catch '^Vim\%((\a\+)\)\=:E389:'
    echohl Warning
    echom 'Could not find pattern'
    echohl None
    return
  endtry
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call IdentSearchAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! IdentSearchAccept()
  let num = matchstr(overlay#select_line(), '\d\+')
  exe 'silent! norm! ' . num . "[\t"
endfunction

nnoremap [I :call IdentSearch()<cr>
