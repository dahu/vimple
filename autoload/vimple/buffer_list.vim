" BufferList object
" ARB
" version 0.8.1

" TODO: Use the Numerically sort comparator for print()
" TODO: Use one s:dict instead of recreating the whole thing. Easier to debug.
" TODO: Improve alignment of line numbers of print().

function! vimple#buffer_list#new()
  let bl = {}
  let bl.__buffers = {}
  let bl.current = 0
  let bl.alternate = 0
  let bl.__filter = ''

  " public interface {{{1

  " update {{{2
  func bl.update() dict abort
    let bufferlist = vimple#associate(vimple#redir('ls!'),
          \ [[ '^\s*\(\d\+\)\(\s*[-u%#ah=+x ]*\)\s\+\"\(.\{-}\)\"\s\+line\s\+\(\d\+\)\s*$',
            \ '\1,\2,\4,\3',
            \ '' ]],
          \ [ 'split(v:val, ",")',
            \ 'add(v:val[0:2], join(v:val[3:-1], ","))',
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
            \.'"read_error": v:val[1] =~ "x"}' ])

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

  " to_s([format[, filter]]) {{{2
  " format: When absent or empty the default value ("%3b%f\"%n\" line %l\n")
  " will be used.
  " Use %b, %n, %f and %l to insert the buffer number, name, flags and cursor
  " line respectively . The last character will be replaced by d or s as
  " required by printf(), so you can include extra flags (e.g.: %3b).
  func bl.to_s(...) dict
    " An empty format argument uses the default.
    let default = "%3b%f\"%n\" line %l\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    " Apply filter.
    let buffers = self.data()

    let str = ''
    for key in sort(keys(buffers), 'vimple#comparators#numerically')
      let str .= vimple#format(
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

  " to_l {{{2
  func bl.to_l(...) dict
    return values(call(self.buffers, a:000, self).__buffers)
  endfunc

  " to_d {{{2
  func bl.to_d(...) dict
    return call(self.buffers, a:000, self).__buffers
  endfunc

  " print {{{2
  " only able to colour print the default to_s() output at this stage
  func bl.print(...) dict
    let bang = a:0 ? a:1 : 0
    call self.update()
    "let str = self.to_s()
    " following code is from hl.print() and would not work as is here
    "let dta = map(split(str, "\n"), '[split(v:val, " ")[0], v:val . "\n"]')
    "call vimple#echoc(dta)
    let pairs = []
    let data = self.data()
    let max_length = max(map(deepcopy(values(self.data())), 'len(v:val.name)'))
    for buffer in sort(values(data), self.compare, self)
      if !bang && !buffer.listed
        continue
      endif
      call add(pairs, ['BL_Nnumber', printf('%3d',buffer.number)])
      if buffer.listed
        call add(pairs, ['Normal', ' '])
      else
        call add(pairs, ['BL_Unlisted', 'u'])
      endif
      if buffer.current
        call add(pairs, ['BL_Current', '%'])
      elseif buffer.alternate
        call add(pairs, ['BL_Alternate', '#'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if buffer.active
        call add(pairs, ['BL_Active', 'a'])
      elseif buffer.hidden
        call add(pairs, ['BL_Hidden', 'h'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if !buffer.modifiable
        call add(pairs, ['BL_Modifiable', '-'])
      elseif buffer.readonly
        call add(pairs, ['BL_Readonly', '='])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if buffer.read_error
        call add(pairs, ['BL_RearError', 'x'])
      elseif buffer.modified
        call add(pairs, ['BL_Modified', '+'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      call add(pairs, ['Normal', ' '])
      call add(pairs, [
            \ buffer.current ?
            \ 'BL_CurrentBuffer' :
            \ buffer.alternate ?
            \ 'BL_AlternateBuffer' :
            \ 'Normal',
            \ '"' . buffer.name . '"'])
      let spaces = len(buffer.name) >= 29 ? 1 : 29 - len(buffer.name)
      call add(pairs, ['Normal',
            \ repeat(' ', spaces)])
      call add(pairs, ['BL_Line',
            \ 'line ' . buffer.line . "\<NL>"
            \ ])
    endfor
    call vimple#echoc(pairs)
    " Remove the last <NL>. Why?
    let pairs[-1][1] = pairs[-1][-1][:-2]
    return pairs
  endfunc

  " compare {{{3
  func bl.compare(k1, k2) dict
    let k1 = a:k1.number * 1
    let k2 = a:k2.number * 1
    return k1 == k2 ? 0 : k1 > k2 ? 1 : -1
  endfunc

  " filter {{{2
  func bl.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__buffers, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  " get_filter {{{3
  func bl.get_filter() dict
    return string(self.__filter)
  endfunc

  " filter_add_or {{{3
  func bl.filter_add_or(filter) dict
    let self.__filter .= ' || ' . a:filter
  endfunc

  " filter_add_and {{{3
  func bl.filter_add_and(filter) dict
    let self.__filter .= ' && ' . a:filter
  endfunc

  " merge {{{3
  func bl.merge(bl) dict
    let bl = deepcopy(self)
    call extend(bl.__buffers, a:bl.__buffers, 'keep')
    call bl.filter_add_or(a:bl.__filter)
    return bl
  endfunc

  " and {{{3
  func bl.and(filter) dict
    return call(self.buffers, [a:filter], self)
  endfunc

  " hidden {{{3
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

  " active {{{3
  func bl.active() dict
    return self.filter('v:val.active')
  endfunc

  " modifiable {{{3
  func bl.modifiable(...) dict
    let filters = {
          \ 1: '!v:val.modifiable',
          \ 2: '!v:val.modifiable || v:val.readonly'
          \ }
    let choice = a:0 ? a:1 : 1
    return self.filter_with_choice(choice, filters)
  endfunc

  " readonly {{{3
  func bl.readonly(...) dict
    let filters = {
          \ 1: '!v:val.readonly',
          \ 2: '!v:val.modifiable || v:val.readonly'
          \ }
    let choice = a:0 ? a:1 : 1
    return self.filter_with_choice(choice, filters)
  endfunc

  " modified {{{3
  func bl.modified() dict
    return self.filter('v:val.modified')
  endfunc

  " read_error {{{3
  func bl.read_error() dict
    return self.filter('v:val.read_error')
  endfunc

  " unloaded {{{3
  func bl.unloaded() dict
    return self.filter('!v:val.active && !v:val.hidden && v:val.listed')
  endfunc

  " buffers - alias for data {{{2
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

  " data - alias for buffers {{{3
  func bl.data() dict
    return self.__buffers
  endfunc

  " Private functions - don't need 'dict' modifier {{{2

  " filter_with_choice {{{3
  func bl.filter_with_choice(choice, filters, ...)
    if a:0
      return filter(deepcopy(a:1), a:filters[a:choice])
    else
      return self.filter(a:filters[a:choice])
    endif
  endfunc

  " buffer_status {{{3
  func bl.buffer_status(b)
    return a:b['active'] == 1 ? 'a' : a:b['hidden'] == 1 ? 'h' : '!'
  endfunc

  " buffer_type {{{3
  func bl.buffer_type(b)
    return a:b['current'] == 1 ? '%' : a:b['alternate'] == 1 ? '#' : ' '
  endfunc

  " buffer_flags {{{3
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
  " }}}2

  " constructor

  call bl.update()
  return bl
endfunction

" vim: et sw=2 ft=vim fdm=marker
