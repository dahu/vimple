function! variable#type_to_string(var)
  return ['Number', 'String', 'Funcref', 'List', 'Dictionary', 'Float'][type(a:var)]
endfunction
