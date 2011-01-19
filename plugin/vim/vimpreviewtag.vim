au! CursorHold  *.vim nested call PreviewWord(0)
au! CursorHoldI *.vim nested call PreviewWord(1)

let &tags =  &tags . ',' . glob(expand('<sfile>:p:h')."/../../tags/*.tags")
func! PreviewWord(insert)
  if &previewwindow                     " don't do this in the preview window
    return
  endif

  if a:insert && getline('.')[col('.')-2] =~ '\w'
    " Find word for insert mode
    let start = searchpos('\w\+','cnb',line('.'))[1]
    let w     = getline('.')[ start - 1 : col('.') - 2 ]
  else
    " Find word for normal mode
    let w = expand("<cword>")             " get the word under cursor
  endif

  if w =~ '\a'                  " if the word contains a letter

    " Delete any existing highlight before showing another tag
    silent! wincmd P                    " jump to preview window
    if &previewwindow                   " if we really get there...
      match none                        " delete existing highlight
      wincmd p                  " back to old window
    endif

    " Try displaying a matching tag for the word under the cursor
    try
      exe "ptag " . w
    catch
      return
    endtry

    silent! wincmd P                    " jump to preview window
    if &previewwindow           " if we really get there...
      if has("folding")
        silent! .foldopen               " don't want a closed fold
      endif
      call search("$", "b")             " to end of previous line
      let w = substitute(w, '\\', '\\\\', "")
      call search('\<\V' . w . '\>')    " position cursor on match
      " Add a match highlight to the word at this position
      hi previewWord term=bold ctermbg=green guibg=green
      exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
      wincmd p                  " back to old window
    endif
  endif
endfun
