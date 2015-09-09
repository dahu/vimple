" list#flat([elem, ...]) {{{1
"
" Flatten the arguments into a single list.
"
" given: a = ['a', 'b']
"        b = [1, 2]
" list#flat(a,b)      : ['a', 'b', 1,  2]
"
function! list#flat(...)
  let fl = []
  let list = a:000
  if a:0 == 1
    let list = list[0]
  endif
  for el in list
    if type(el) == type([])
      call extend(fl, list#flat(el))
    else
      call extend(fl, [el])
    endif
    unlet el
  endfor
  return fl
endfunction

function! list#split(list, match)
  let ret = []
  let r = []
  for e in a:list
    if e =~ a:match
      call add(ret, r)
      let r = []
    else
      call add(r, e)
    endif
  endfor
  call add(ret, r)
  return ret
endfunction

" list#zip(list_a, list_b, method) {{{1
"
" Join each element of list_a with the corresponding element of list_b
" Use the third argument, method, to dictate how the elements should be
" combined:
" given: a = [a, b]
"        b = [1, 2]
" 0 = flattened list  : [a, 1, b, 2]
" 1 = list groups     : [[a, 1], [b, 2]]
" x = join separator x : [ax1, bx2]
"
" NOTE: If one list is longer than the other, the tail of that list is added
" to the result.
function! list#zip(a, b, ...)
  let method = 1
  if a:0
    let method = a:1
  endif
  let i = 0
  let r = []
  let l_a = len(a:a)
  let l_b = len(a:b)
  let n = min([len(a:a), len(a:b)])
  while i < n
    if method == "0"
      call add(r, a:a[i])
      call add(r, a:b[i])
    elseif method == "1"
      call add(r, [a:a[i], a:b[i]])
    else
      call add(r, join([a:a[i], a:b[i]], method))
    endif
    let i+= 1
  endwhile
  if l_a == l_b
    return r
  elseif l_a > l_b
    exe "return r + a:a[" . n . ":]"
  else
    exe "return r + a:b[" . n . ":]"
  endif
endfunction "}}}1

" list#inject(list, init, funcref)
function! list#inject(list, init, funcref)
  if ! exists('*' . a:funcref)
    throw 'vimple: list#inject(): Funcref ' . a:funcref . ' does not exist!'
    return a:init
  elseif empty(a:list)
    return a:init
  else
    let i  = a:list[0]
    let r  = a:list[1:-1]
    let v = call(a:funcref, [a:init, i])
    return list#inject(r, v, a:funcref)
  endif
endf

" partition list into count-element sublists
function! list#partition(list, count)
  let lst = deepcopy(a:list)
  let len = len(lst)
  let cnt = a:count
  let newlists = []
  if cnt <= 0
    throw 'vimple: list#partition: count must be positive'
  endif
  if cnt >= len
    return lst
  endif
  for idx in range(0, len - 1, cnt)
    if cnt > len(lst)
      let cnt = len(lst)
    endif
    call add(newlists, remove(lst, 0, (cnt - 1)))
  endfor
  return newlists
endfunc

" partition list into cols sublists and join with colsep=\t
" list#lspread(list, cols, colsep="\t")
" returns a list
function! list#lspread(list, cols, ...)
  let colsep = "\t"
  if a:0
    let colsep = a:1
  endif
  return map(list#partition(a:list, a:cols), 'join(v:val, "' . escape(colsep, '"') . '")')
endfunction

" partition list into cols sublists and join with col and row seps
" list#spread(list, cols, colsep, rowsep)
" returns a string
function! list#spread(list, cols, ...)
  let colsep = "\t"
  let rowsep = "\n"
  if a:0
    if a:0 == 2
      let colsep = a:1
      let rowsep = a:2
    else
      let colsep = a:1
    endif
  endif
  return join(list#lspread(a:list, a:cols, colsep), rowsep)
endfunction

" " map expr over each element of each sublist of list
" function! list#lmap(list, expr)
"   return map(a:list, 'map(v:val, ''' . a:expr . ''')')
" endfunction

function! list#shuffle(a)
  let b = deepcopy(a:a)
  let n = 0
  let length = len(b)
  while n < length
    let tmp = b[n]
    let dst = rng#rand() % length
    let b[n] = b[dst]
    let b[dst] = tmp
    let n += 1
  endwhile
  return b
endfunction

" list#paste(a, b, join, sep)
" Emulate the unix paste command
" Arguments:
"   a    - each of 'a' and 'b' are lists, or
"   b    -   strings containing 'sep' (default='\n') delimited elements
"   join - separator (default=' ') to use when joining each respective line of
"          a and b
"   sep  - separator (default='\n') to use when splitting a and b (if strings)
" e.g.
" ------v yank following into register a - "a3yy
" one
" two
" three
" ------v yank following into register b - "b3yy
" satu
" dua
" tiga
" call append('.', Paste(@a, @b))
function! list#paste(a, b, ...)
  let join = (a:0 >= 1) ? a:1 : ' '
  let sep = (a:0 == 2) ? a:2 : '\n'
  if type(a:a) == 1
    let a = split(a:a, sep)
    let b = split(a:b, sep)
  else
    let a = a:a
    let b = a:b
  end
  return list#zip(a, b, join)
endfunction

" list#lrotate(array)
" Perform a Left Rotate on array
function! list#lrotate(a)
  return extend(a:a[1:-1], [a:a[0]])
endfunction

" list#rrotate(array)
" Perform a Right Rotate on array
function! list#rrotate(a)
  return extend([a:a[-1]], a:a[0:-2])
endfunction
