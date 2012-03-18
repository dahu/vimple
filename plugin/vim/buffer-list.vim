" BufferList object
" ARB
" version 0.8

" NOTE: Uses the Numerically sort comparator

function! BufferList()
  let bl = {}
  let bl.__buffers = {}
  let bl.current = 0
  let bl.alternate = 0
  let bl.__filter = ''

  " public interface

  func bl.update() dict abort
    let bufferlist = vimple#redir#redir('ls!')

    "let bufferlist = vimple#associate#associate(bufferlist,
          "\ [ '^\s*\(\d\+\)\(\s*[-u%#ah=+x ]*\)\s\+\"\(.\{-}\)\"\s\+line\s\+\(\d\+\)\s*$',
            "\ '\1,\2,\4,\3',
            "\ '' ],
          "\ [ 'add(v:val[0:2], join(v:val[3:-1], ","))',
            "\ '{"number": v:val[0],'
            "\.'"line": v:val[2],'
            "\.'"name": (v:val[3]      =~ ''\[.\{-}\]'' ? bufname(v:val[0]) : v:val[3]),'
            "\.'"listed": v:val[1]     !~ "u",'
            "\.'"current": v:val[1]    =~ "%",'
            "\.'"alternate": v:val[1]  =~ "#",'
            "\.'"active": v:val[1]     =~ "a",'
            "\.'"hidden": v:val[1]     =~ "h",'
            "\.'"modifiable": v:val[1] !~ "-",'
            "\.'"readonly": v:val[1]   =~ "=",'
            "\.'"modified": v:val[1]   =~ "+",'
            "\.'"read_error": v:val[1] =~ "x"}' ])

    " Reorder and clean up a bit the output.
    for i in range(0, len(bufferlist) - 1)
      let bufferlist[i] = substitute(bufferlist[i], '^\s*\(\d\+\)\(\s*[-u%#ah=+x ]*\)\s\+\"\(.\{-}\)\"\s\+line\s\+\(\d\+\)\s*$', '\1,\2,\4,\3','')
    endfor

    " Split on commas.
    call map(bufferlist, 'split(v:val, ",")')
    " Restore file names with comma(s)
    call map(bufferlist, 'add(v:val[0:2], join(v:val[3:-1], ","))')
    " Empty names give an empty string instead of "[No Name]".
    call map(bufferlist,
          \ '{"number": v:val[0],'
          \.'"line": v:val[2],'
          \.'"name": (v:val[3]      =~ ''\[.\{-}\]'' ? bufname(v:val[0]) : v:val[3]),'
          \.'"listed": v:val[1]     !~ "u",'
          \.'"current": v:val[1]    =~ "%",'
          \.'"alternate": v:val[1]  =~ "#",'
          \.'"active": v:val[1]     =~ "a",'
          \.'"hidden": v:val[1]     =~ "h",'
          \.'"modifiable": v:val[1] !~ "-",'
          \.'"readonly": v:val[1]   =~ "=",'
          \.'"modified": v:val[1]   =~ "+",'
          \.'"read_error": v:val[1] =~ "x"}')

    for bfr in map(copy(bufferlist), '{v:val["number"]: v:val}')
      call extend(self.__buffers, bfr)
    endfor
    if self.__filter != ''
      call filter(self.__buffers, self.__filter)
    endif

    let current_l = filter(copy(bufferlist), 'v:val["current"] == 1')
    let alternate_l = filter(copy(bufferlist), 'v:val["alternate"] == 1')
    let self.current = len(current_l) > 0 ?current_l[0].number : 0
    let self.alternate = len(alternate_l) > 0 ? alternate_l[0].number : 0
    return 1
  endfun

  " to_s([format[, filter]])
  " format: When absent or empty the default value ("%3b%f\"%n\" line %l\n")
  " will be used.
  " Use %b, %n, %f and %l to insert the buffer number, name, flags and cursor
  " line respectively . The last character will be replaced by d or s as
  " required by printf(), so you can include extra flags (e.g.: %3b).
  " filter: This argument will be used by filter() to remove items from the
  " list.
  func bl.to_s(...) dict
    " An empty format argument uses the default.
    let default = "%3b%f\"%n\" line %l\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    " Apply filter.
    let buffers = a:0 > 1 ? a:2.__buffers : self.__buffers

    let str = ''
    for key in sort(keys(buffers), 'Numerically')
      let str .= vimple#format#format(
            \ format,
            \ { 'b': ['d', buffers[key]['number']],
            \   'f': ['s', self.buffer_flags(buffers[key])],
            \   'n': ['s', buffers[key]['name']],
            \   'l': ['s', buffers[key]['line']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  func bl.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__buffers, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func bl.get_filter() dict
    return string(self.__filter)
  endfunc

  func bl.filter_add_or(filter) dict
    let self.__filter .= ' || ' . a:filter
  endfunc

  func bl.filter_add_and(filter) dict
    let self.__filter .= ' && ' . a:filter
  endfunc

  func bl.merge(bl) dict
    let bl = deepcopy(self)
    call extend(bl.__buffers, a:bl.__buffers, 'keep')
    call bl.filter_add_or(a:bl.__filter)
    return bl
  endfunc

  func bl.buffers(...) dict
    if !a:0
      " Return listed buffers.
      return self.filter('v:val.listed')
    endif
    if type(a:000[-1]) == type({})
      let orig = a:000[-1]
      let extra = 1
    else
      let orig = self
      let extra = 0
    endif
    if len(a:000) >= 1 + extra
      let args = a:000[1: -1 - extra]
    else
      let args = []
    endif
    unlet extra
    if a:1 =~ '^\%(non\?\|un\)'
      let arg = matchstr(a:1, '^\%(un\|non\)\zs.*')
      let bang = '!'
    else
      let arg = a:1
      let bang = ''
    endif
    if arg == 'hidden'
      let filter = 'v:val.hidden'
    elseif arg == 'active'
      let filter = 'v:val.active'
    elseif arg == 'modifiable'
      let filter = 'v:val.modifiable'
    elseif arg == 'readonly'
      let filter = 'v:val.readonly'
    elseif arg == 'modified'
      let filter = 'v:val.modified'
    elseif arg == 'read_error'
      let filter = 'v:val.read_error'
    elseif arg == 'unloaded'
      let filter = '!v:val.active && !v:val.hidden && v:val.listed'
    elseif arg == 'listed'
      let filter = 'v:val.listed'
    elseif arg == 'all'
      let filter = '1'
    else
      let filter = arg
    endif
    let bl = orig.filter(bang . '(' . filter . ')')
    if len(args) > 0
      let bl = call(bl.merge, [call(orig.buffers, args + [orig], orig)], bl)
    endif
    return bl
  endfunc

  func bl.and(filter) dict
    return call(self.buffers, [a:filter], self)
  endfunc

  func bl.to_l(...) dict
    return values(call(self.buffers, a:000, self).__buffers)
  endfunc

  func bl.to_d(...) dict
    return call(self.buffers, a:000, self).__buffers
  endfunc

  func bl.hidden(...) dict
    let filters = {
          \ 1: 'v:val.hidden',
          \ 2: '!v:val.active && v:val.listed',
          \ 3: '!v:val.listed',
          \ 4: '!v:val.active && v:val.listed && !v:val.hidden',
          \ 5: '!v:val.active || !v:val.listed'
          \ }
    let choice = a:0 ? a:1 : 1
    return self.filter_with_choice(choice, filters)
  endfunc

  func bl.active() dict
    return self.filter('v:val.active')
  endfunc

  func bl.modifiable(...) dict
    let filters = {
          \ 1: '!v:val.modifiable',
          \ 2: '!v:val.modifiable || v:val.readonly'
          \ }
    let choice = a:0 ? a:1 : 1
    return filter_with_choice(choice, filters)
  endfunc

  func bl.readonly(...) dict
    let filters = {
          \ 1: '!v:val.readonly',
          \ 2: '!v:val.modifiable || v:val.readonly'
          \ }
    let choice = a:0 ? a:1 : 1
    return filter_with_choice(choice, filters)
  endfunc

  func bl.modified() dict
    return self.filter('v:val.modified')
  endfunc

  func bl.read_error() dict
    return self.filter('v:val.read_error')
  endfunc

  func bl.unloaded() dict
    return self.filter('!v:val.active && !v:val.hidden && v:val.listed')
  endfunc

  " Private functions - don't need 'dict' modifier

  func bl.filter_with_choice(choice, filters, ...)
    if a:0
      return filter(deepcopy(a:1), a:filters[a:choice])
    else
      return self.filter(a:filters[a:choice])
    endif
  endfunc

  func bl.buffer_status(b)
    return a:b['active'] == 1 ? 'a' : a:b['hidden'] == 1 ? 'h' : '!'
  endfunc

  func bl.buffer_type(b)
    return a:b['current'] == 1 ? '%' : a:b['alternate'] == 1 ? '#' : ' '
  endfunc

  func bl.buffer_flags(b)
    return   (a:b['listed'] == 0 ? 'u' : ' ')
          \. (a:b['current'] == 1 ? '%' :
          \    (a:b['alternate'] == 1 ? '#' : ' '))
          \. (a:b['active'] == 1 ? 'a' :
          \    (a:b['hidden'] == 1 ? 'h' : ' '))
          \. (a:b['modifiable'] == 0 ? '-' :
          \    (a:b['readonly'] == 1 ? '=' : ' '))
          \. (a:b['modified'] == 1 ? '+' : ' ')
          \. (a:b['read_error'] == 1 ? 'x' : ' ')
  endfunc

  " constructor

  call bl.update()
  return bl
endfunction

let bl = BufferList()
"call bl.update()      " not necessary here, just showing it's callable
"echo bl.__buffers
"echo "Current buffer    : " . bl.current
"echo "Alternate buffer  : " . bl.alternate
"echo bl.__buffers[1]
"echo "Buffer 1 is hidden: " . bl.__buffers[1]['hidden']
"echo bl.to_s()
"echo bl.to_s('%c')
"echo bl.to_s('%b ==> %n | %c')
"echo bl.hidden()
"echo '==================='
"echo bl.hidden(2)
"echo '==================='
"echo bl.hidden(3)

" vim: et sw=2 ft=vim
