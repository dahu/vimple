" Better navigation of :oldfiles

" In the overlay window:
" <enter> loads the file under the cursor
" q closes the overlay without action

function! GetSuggestions(ident)
  let spell = &spell
  if ! spell
    set spell
  endif
  let suggestions = list#lspread(spellsuggest(a:ident), 5)
  if ! spell
    set nospell
  endif
  return suggestions
endfunction

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
  let line = matchstr(getline('.'), '^\d\+')
  call overlay#close()
  exe 'edit ' . expand('#<' . line)
endfunction

command! -nargs=0 Oldfiles call Oldfiles()
