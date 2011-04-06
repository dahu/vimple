if exists('g:loaded_vimpreviewtag') || &cp
  finish
endif
let g:loaded_vimpreviewtag = 1

au! CursorHold  * nested if &ft == 'vim' | call PreviewWord(0) | endif
au! CursorHoldI * nested if &ft == 'vim' | call PreviewWord(1) | endif
"noremap <leader>l :call PreviewWord(0)<CR>

let &tags =  &tags . ',' . glob(expand('<sfile>:p:h')."/../../tags/*.tags")
func! PreviewWord(insert)
  if &previewwindow                     " don't do this in the preview window
    return
  endif

  let col    = col('.') - a:insert
  let line   = getline('.')
  let start  = col - 1
  let ignore = 'synIDattr(synID(line("."), (start + 1), 0), "name") =~?  ''string\|comment'''
  " Get word under the cursor if any, not the same as <cword>
  let w      = substitute(line, '^.\{-}\(\w\+\%'.(col+1).'c\w*\).\{-}$','\1','')
  " Find out if we are writing a function's arguments. (It could search
  " other lines...)
  let has_fn = searchpairpos('\w\zs\s*(','',')','cnWb','synIDattr(synID(line("."), col, 0), "name") =~? ''string\|comment''',line('.'))[1]

  " See if w should be changed
  if w == '' || (w =~ '\W' && w =~ '\w') || eval(ignore) || has_fn > 0
    " Monitor parens balance
    let paren_bal = 0
    let end    = 0
    let skip   = 0

    " Start looking
    while start > 0
      if eval(ignore)
        " Inside a comment or string, pass
        let start -= 1
        continue
      endif

      let char = line[start - 1]

      if char =~ '\w' && end == 0
        " Set the end of the word
        let end = start - 1
      elseif char =~ '\W'
        " This is not a word, reset end
        let end = 0
      endif

      if char =~ '\W' && skip && paren_bal <= 0
        " Stop skipping chars
        let skip = 0
      endif

      " Balance parens
      if char == ')'
        " Don't get the word from an already closed function
        let skip =  1
        let paren_bal += 1
      elseif char == '('
        let paren_bal -= 1
      endif

      let start -= 1

      if char =~ '\w' && line[start - 1] =~ '\W' && !skip && paren_bal <= 0 && (has_fn <= 0 || has_fn > start)
        " Char is a word-char, the next is not, we aren't skipping anymore,
        " parens' balance is ok and, if we are writing arguments, the start of
        " the word is before the open paren. So, stop looking.
        break
      endif
    endwhile
    let w = line[start : end]
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
