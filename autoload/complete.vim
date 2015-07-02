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

" Example Completers
"-------------------
"
function! complete#short_files_in_path(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\f'
      let start -= 1
    endwhile
    return start
  else
    let res = map(globpath(&path, a:base . '*', 0, 1)
          \, 'fnamemodify(v:val, ":t")')
    return res
  endif
endfunction

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

function! complete#foist(findstart, base)
  if a:findstart
    return 0
  else
    let base = matchstr(a:base, '^\s*\zs.*\ze\s*$')
    let all_buf_lines = []
    let curbuf = bufnr('%')
    silent bufdo call extend(all_buf_lines, getline(1, '$'))
    exe "buffer " . curbuf
    return filter(all_buf_lines, 'stridx(v:val, base) > -1')
  endif
endfunction
