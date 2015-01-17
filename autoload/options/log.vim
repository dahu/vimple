function! options#log#clear()
  let s:options_log = []
endfunction

function! options#log#add(opt, op, values, msg)
  let vt = type(a:values)
  let values = (((vt == type([])) || (vt == type({}))) ? a:values : [a:values])
  call add(s:options_log, [localtime(), a:opt, a:op, values, a:msg])
endfunction

function! options#log#view(...)
  if !empty(s:options_log)
    echohl Title
    echo 'Options Log:'
    echohl None
    for log in s:options_log
      echo printf("%s\t%s\t%s\t%s\t%s\n", strftime("%d%H%M", log[0]), log[1], log[2], string(log[3]), log[4])
    endfor
  endif
endfunction

if ! has_key(s:, 'options_log')
  call options#log#clear()
endif
