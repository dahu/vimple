" Wanna choose from a list of abbreviations?

" In the overlay window:
" <enter> inserts the currently selected abbreviation expansion
" q closes the overlay without action

" functions {{{1

function! Abbreviations() "{{{2
  call overlay#show(
        \  map(g:vimple#ab.update().to_l(), 'v:val["expansion"]')
        \, {
        \    '<enter>' : ':call AbbreviationsAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! AbbreviationsAccept() "{{{2
  let line = overlay#select_line()
  exe 'norm! a' . line . " \<esc>l"
  startinsert
endfunction

" maps {{{1

inoremap _<s-space> <esc>:call Abbreviations()<cr>

" vim: fen fdm=marker
