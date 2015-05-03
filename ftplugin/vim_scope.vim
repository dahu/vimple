function! Scope_vim()
  let scope = scope#inspect('^\s*fu\%[nction]!\?\s*\([a-zA-Z0-9_#.]\+\)', '^\s*endf\%[unction]')
  return ' ' . join(map(scope.stack, 'v:val.head_line_number . "," . v:val.tail_line_number . " " . v:val.head_string'), ' > ')
endfunction
