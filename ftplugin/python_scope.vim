function! Scope_python()
  let class_scope  = scope#inspect('^\s*class\s\+\([a-zA-Z0-9_.]\+\)', '\ze\n\(\s*class\|\S\)')
  let method_scope = scope#inspect('^\s*def\s\+\([a-zA-Z0-9_.]\+\)', '.\(\n\(\n\|\S\)\)\@=')
  return ' ' . join(map(class_scope.stack, 'v:val.head_line_number . "," . v:val.tail_line_number . " " . v:val.head_string'), ' :: ')
        \. ' >> ' . join(map(method_scope.stack, 'v:val.head_line_number . "," . v:val.tail_line_number . " " . v:val.head_string'), ' > ')
endfunction
