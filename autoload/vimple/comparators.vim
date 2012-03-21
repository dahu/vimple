" Sort Comparators

function! vimple#comparators#numerically(i1, i2)
  let i1 = str2nr(a:i1)
  let i2 = str2nr(a:i2)
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction

function! vimple#comparators#termly(i1, i2)
  let i1 = a:i1['term']
  let i2 = a:i2['term']
  return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction
