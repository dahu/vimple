" Jump to a help-tag entry in the current help file

" In the overlay window:
" You're prompted with a filter pattern. Use <esc> to cancel.
" <enter> jumps to the tag beneath the cursor
" q closes the overlay without action

" functions {{{1

function! HelpTOC() "{{{2
  call overlay#show(
        \  list#lspread(map(filter(string#scanner(getline(1, '$')).collect('\*\S\+\*'), 'v:val =~ "[a-z]"'), 'strpart(v:val, 1, len(v:val)-2)'), 3)
        \, {
        \    '<enter>' : ':exe "tag " . HelpTOCAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1, 'setlocal tabstop=50' :-0})
endfunction

function! HelpTOCAccept()
  let line      = getline('.')
  let idx       = strlen(substitute(line[:col('.')], '[^\t]', '', 'g'))
  let word_list = split(line, '\t')
  call overlay#close()
  return word_list[idx]
endfunction

" maps {{{1

nnoremap <leader>t :call HelpTOC()<cr>

" vim: fen fdm=marker
