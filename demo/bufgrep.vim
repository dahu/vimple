" Wanna grep your buffer and be able to jump to one of the matches quickly?

" In the overlay window:
" You're prompted with a filter pattern. Use <esc> to cancel.
" <enter> jumps to the current-line match
" q closes the overlay without action

function! BufGrep(pattern)
  let data = vimple#redir('global /' . escape(a:pattern, '/') )
  if data[0] =~ 'Pattern not found:'
    echohl Warning
    echo data[0]
    echohl None
    return
  endif
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call BufGrepAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! BufGrepAccept()
  let num = matchstr(overlay#select_line(), '\d\+')
  exe 'silent! norm! ' . num . "G"
endfunction

nnoremap <leader>bg :call BufGrep(input('/'))<cr>
command -bar -nargs=* G call BufGrep(<q-args>)
