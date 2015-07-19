" Are you bored with vanilla z= ?

" In the overlay window:
" <enter> replaces current word with word under cursor
" q closes the overlay without action

" functions {{{1

function! GetSuggestions(ident) "{{{2
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

function! SpellSuggest(ident) "{{{2
  call overlay#show(
        \  GetSuggestions(a:ident)
        \, {
        \    '<enter>' : ':call SpellSuggestAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! SpellSuggestAccept() "{{{2
  let line = getline('.')
  let idx = strlen(substitute(line[:col('.')], '[^\t]', '', 'g'))
  let word_list = split(line, '\t')
  call overlay#close()
  let [r1, r2] = [@@, @-]
  exe 'norm! ciw' . word_list[idx]
  let [@@, @-] = [r1, r2]
endfunction

" maps {{{1

nnoremap z= :call SpellSuggest(expand('<cword>'))<cr>

" vim: fen fdm=marker
