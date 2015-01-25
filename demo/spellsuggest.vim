" Are you bored with vanilla z= ?

" In the overlay window:
" <enter> replaces current word with word under cursor
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

function! SpellSuggest(ident)
  call overlay#show(
        \  GetSuggestions(a:ident)
        \, {
        \    '<enter>' : ':call SpellSuggestAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

nnoremap z= :call SpellSuggest(expand('<cword>'))<cr>

function! SpellSuggestAccept()
  let reg_save = @/
  let idx = strlen(substitute(getline('.')[:col('.')], "[^\t]", "", "g"))
  let word_list = split(getline('.'), '\t')
  let word = word_list[idx]
  call overlay#close()
  execute 'normal! ciw' . word
  let @/ = reg_save
endfunction
