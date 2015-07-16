" Jump to an entry in the current help file's TOC

" In the overlay window:
" <enter> jumps to the first (hopefully only) tag on the current line
" q closes the overlay without action

" functions {{{1

function! GetTOC() "{{{2
  let toc = string#scanner(string#scanner(getline(1, '$')).scan('.\{-}\n====')).collect('\n\s*\zs\d\+.\{-}\n\@=')
  return toc
endfunction

function! HelpTOC() "{{{2
  call overlay#show(
        \  GetTOC()
        \, {
        \    '<enter>' : ':call TOCAccept()<cr>:exe "tag " . g:toc_tag<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! TOCAccept() "{{{2
  let g:toc_tag = string#scanner(getline('.')).collect('|.\{-}|')[0][1:-2]
  call overlay#close()
endfunction

" maps {{{1

nnoremap <leader>t :call HelpTOC()<cr>

" vim: fen fdm=marker
