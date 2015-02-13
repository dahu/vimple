" quickfix niceties
" Barry Arthur, Jan 2012

" original idea from:
" http://stackoverflow.com/questions/1830839/how-to-open-multiple-files-in-vim-after-vimgrep

function! quickfix#bufnames()
  return uniq(sort(map(getqflist(), 'bufname(v:val.bufnr)')))
endfunction

function! quickfix#to_args(global)
  let global = !empty(a:global)
  let arg_cmd = global ? 'args ' : 'arglocal '
  exe arg_cmd . join(map(quickfix#bufnames(), 'escape(v:val, " ")'), ' ')
endfunction

function! quickfix#do(cmd)
  " create a new window so as not to interfere with user's arglist
  split
  call quickfix#to_args(0)   " 0 == local not global
  exe 'argdo ' . a:cmd
  close
endfunction
