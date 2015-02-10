function! complete#files_in_path(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\f'
      let start -= 1
    endwhile
    return start
  else
    let res = map(globpath(&path, a:base . '*', 0, 1)
          \, 'substitute(v:val, "^\.\/", "", "")')
    return res
  endif
endfunction

let s:old_cfu = ''

function! complete#reset()
  let &completefunc = s:old_cfu
  let s:old_cfu = ''
  augroup CompleteTrigger
    au!
  augroup END
endfunction

function! complete#trigger(func)
  if s:old_cfu == ''
    let s:old_cfu = &completefunc
  endif
  let &completefunc = a:func
  augroup CompleteTrigger
    au!
    au CursorMovedI * call complete#reset()
  augroup END
  return "\<c-x>\<c-u>"
endfunction

if ! exists('g:vimple_override_file_complete')
  let g:vimple_override_file_complete = 0
endif

if g:vimple_override_file_complete
  inoremap <expr> <c-x><c-f> complete#trigger('complete#files_in_path')
endif
