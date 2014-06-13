function! args#merge_dict(initial, ...)
  let dict = a:initial
  for arg in a:000
    if type(arg) == type({})
      call extend(dict, arg)
    elseif type(arg) == type('')
      if exists(arg)
        call extend(dict, eval(arg))
      endif
    elseif type(arg) == type([])
      if ! empty(arg[0])
        if has_key(arg[0][arg[1]], arg[2])
          call extend(dict, get(arg[0][arg[1]], arg[2]))
        endif
      endif
    else
      echohl Warning
      echom  'args#merge_dict: Unhandled type: ' . type(arg)
      echohl None
    endif
    unlet arg
  endfor
  return dict
endfunction

function! args#merge_string(initial, ...)
  let str = a:initial
  for arg in a:000
    if type(arg) == type('')
      if exists(arg)
        let str = eval(arg)
      endif
    elseif type(arg) == type([])
      if ! empty(arg[0])
        if has_key(arg[0][arg[1]], arg[2])
          let str = get(arg[0][arg[1]], arg[2])
        endif
      endif
    else
      echohl Warning
      echom  'args#merge_string: Unhandled type: ' . type(arg)
      echohl None
    endif
    unlet arg
  endfor
  return str
endfunction

function! args#merge(initial, ...)
  let initial = a:initial
  let type = type(initial)
  if type == type({})
    return call('args#merge_dict', [initial] + a:000)
  elseif type == type('')
    return call('args#merge_string', [initial] + a:000)
  else
    echohl Warning
    echom  'args#merge: Unhandled type: ' . type
    echohl None
  end
endfunction

if expand('%:p') == expand('<sfile>:p')
  " TEST string merge

  func! args#test_merge_2(...)
    return args#merge(
          \  'override me'
          \, 'g:default'
          \, 'g:default_2'
          \, [a:000, 0, 'my_default']
          \)
  endfunc

  let default = 'default'
  silent! unlet default_2
  echo 'default' == args#test_merge_2()

  let default_2 = 'default 2'
  echo 'default 2' == args#test_merge_2()

  echo 'my default' == args#test_merge_2({'my_default' : 'my default'})

  " TEST dict merge

  let default_styles = {
        \  'one'   : 1
        \, 'two'   : 2
        \, 'three' : 3
        \}

  func! args#test_merge_1(...)
    return args#merge(
          \  {}
          \, g:default_styles
          \, 'g:default_styles_2'
          \, [a:000, 0, 'my_styles']
          \)
  endfunc

  silent! unlet g:default_styles_2
  echo default_styles == args#test_merge_1()
  echo default_styles != args#test_merge_1({'my_styles': {'one' : 4}})
  echo {'one' : 4, 'two' : 2, 'three' : 3} == args#test_merge_1({'my_styles' : {'one' : 4}})
  let g:default_styles_2 = {'one' : 5}
  echo {'one' : 5, 'two' : 2, 'three' : 3} == args#test_merge_1()
endif
