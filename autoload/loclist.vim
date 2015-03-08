" location-list niceties (copied from autoload/loclist.vim)
" Barry Arthur, Mar 2015

function! loclist#bufnames()
  return uniq(sort(map(getloclist(0), 'bufname(v:val.bufnr)')))
endfunction

function! loclist#to_args(global)
  let global = !empty(a:global)
  let arg_cmd = global ? 'args ' : 'arglocal '
  exe arg_cmd . join(map(loclist#bufnames(), 'escape(v:val, " ")'), ' ')
endfunction

function! loclist#do(cmd)
  " create a new window so as not to interfere with user's arglist
  split
  call loclist#to_args(0)   " 0 == local not global
  exe 'argdo ' . a:cmd
  close
endfunction

