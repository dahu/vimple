" TagKind shows an overlay containing the kind of tag requested

" In the overlay window:
" <enter> jumps to the current-line tag name
" q closes the overlay without action

function! TagKind(kind)
  let tags = sort(map(filter(taglist('.'), 'v:val.kind == "' . a:kind . '"'), 'v:val.name'))
  call overlay#show(
        \  tags
        \, {
        \    '<enter>' : ':call TagKindAccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! TagKindAccept()
  let tag = overlay#select_line()
  exe 'tjump ' . tag
endfunction

nnoremap <leader>tc :call TagKind('c')<cr>
nnoremap <leader>tf :call TagKind('f')<cr>
