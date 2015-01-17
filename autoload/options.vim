let s:options = {'lock' : {}, 'sync' : {}}

let myops = s:options
function! options#is_locked(opt)
  let opt = a:opt
  if !has_key(s:options.lock, opt)
    let s:options.lock[opt] = {'locked' : -1}
  endif
  return s:options.lock[opt].locked
endfunction

function! s:lock(lock, opt, value, msg)
  let [lock, opt, value, msg] = [a:lock, a:opt, a:value, a:msg]
  let lock_str = lock ? 'lock' : 'unlock'
  let was_locked = options#is_locked(opt)
  call extend(s:options.lock[opt], {'locked' : lock, 'value' : value})
  call options#log#add(opt, lock_str, [[was_locked, 1], value], msg)
endfunction

function! options#lock(opt, value, msg)
  call s:lock(1, a:opt, a:value, a:msg)
endfunction

function! options#unlock(opt, msg)
  call s:lock(0, a:opt, eval('&'.a:opt), a:msg)
endfunction

function! options#check_locked()
  for opt in items(s:options.lock)
    if (opt[1].locked == 1) && (eval('&'.opt[0]) != opt[1].value)
      echohl Error
      echom 'Cannot change locked option ' . opt[0] . '. Reset to ' . opt[1].value
      echohl None
      exe 'let &' . opt[0] . " = '" . substitute(opt[1].value, "'", "''", "g") . "'"
    endif
  endfor
endfunction

function! options#sync(optlist)
  for opt in a:optlist
  endfor
endfunction



function! options#update()
  call options#check_locked()
endfunction

command! -nargs=+ Lock call options#lock(<f-args>)

augroup Options
  au!
  au CursorHold * call options#update()
augroup END

" echo options#is_locked('ts')
" call options#log#view()
