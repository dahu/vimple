" Better navigation of :oldfiles

" In the overlay window:
" <enter> loads the file under the cursor
" q closes the overlay without action

function! Oldfiles()
  call overlay#show(
        \  vimple#redir('oldfiles')
        \, {
        \    '<enter>' : ':call OldfilesAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! OldfilesAccept()
  let old_file_number = matchstr(overlay#select_line(), '^\d\+')
  exe 'edit #<' . old_file_number
endfunction

command! -nargs=0 Oldfiles call Oldfiles()
