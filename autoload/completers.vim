let completers#completers = [
      \  {'word': "\<c-x>\<c-a>", 'abbr': 'abbreviation'}
      \, {'word': "\<c-x>\<c-z>", 'abbr': 'datetime'}
      \, {'word': "\<c-x>\<c-k>", 'abbr': 'dictionary'}
      \]

function! completers#trigger(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start-1] =~ '\w'
      let start -= 1
    endwhile
    let b:completers_start = start
    return start
  else
    augroup AfterCompleters
      au!
      au CompleteDone * call completers#apply_completion()
    augroup END
    return map(deepcopy(g:completers#completers), 'extend(v:val, {"word" : a:base . get(v:val, "word")})')
  endif
endfunction

function! completers#apply_completion()
  augroup AfterCompleters
    au!
  augroup END
  let reg_un = @@
  exe 'normal! d' . (b:completers_start + 1) . '|'
  if col('.') == (col('$')-1) && col('.') != 1
    let @@ = ' ' . @@
  endif
  call feedkeys(@@)
  let @@ = reg_un
endfunction

function! completers#datetime(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '[a-zA-Z0-9-./]'
      let start -= 1
    endwhile
    return start
  else
    let now = localtime()
    let datetimes = []
    for ts in ['%c', '%Y %b %d %X', '%Y%m%d %T', '%Y-%m-%d', '%Y%m%d', '%H:%M']
      call add(datetimes, strftime(ts, now))
    endfor
    return filter(datetimes, 'v:val =~ "^" . a:base')
  endif
endfunction

function! completers#abbrevs(findstart, base)
  if exists('*CompleteAbbrevs')
    return CompleteAbbrevs(a:findstart, a:base)
  else
    echohl Error
    echom 'Requires https://github.com/dahu/Aboriginal'
    echohl NONE
  endif
endfunction

function! completers#init()
  inoremap <expr> <plug>vimple_completers_trigger complete#trigger('completers#trigger')
  if !hasmapto('<plug>vimple_completers_trigger', 'i')
    imap <unique><silent> jj <plug>vimple_completers_trigger
  endif
  inoremap <expr> <c-x><c-a> complete#trigger('completers#abbrevs')
  inoremap <expr> <c-x><c-z> complete#trigger('completers#datetime')
endfunction
