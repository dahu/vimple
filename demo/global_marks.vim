" Wish you could jump to a global mark that's already open in another tabpage?

" Ensure that:
" set swb+=useopen,usetab

" In the overlay window:
" <enter> does a sbuffer to the current-line global-mark's filename
" q closes the overlay without action

function! GlobalMarks()
  let data = split(g:vimple#ma.update().global_marks().to_s(), "\n")
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call GlobalMarksAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! GlobalMarksAccept()
  let file = matchstr(overlay#select_line(), '\s\zs\S\+$')
  silent! exe 'sbuffer ' . file
endfunction

nnoremap gg' :call GlobalMarks()<cr>
