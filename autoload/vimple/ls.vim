""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :ls builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :ls command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/ls.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#ls.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#ls
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard
" uncomment after plugin development
"if exists("g:loaded_lib_vimple")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
"let g:loaded_lib_vimple = 1

" TODO: Use the Numerically sort comparator for print()
" TODO: Use one s:dict instead of recreating the whole thing. Easier to debug.
" TODO: Improve alignment of line numbers of print().

function! vimple#ls#new()
  let bl = {}
  let bl.__buffers = {}
  let bl.current = 0
  let bl.alternate = 0
  let bl.__filter = ''

  " public interface {{{1

  func bl._filename(bufnum, fallback)
    let bname = bufname(a:bufnum)
    if bname =~ '^\s*$'
      let bname = a:fallback
    endif
    echo '####' . bname . '####
    return bname
  endfunc

  " update {{{2
  func bl.update() dict abort
    let bufferlist = vimple#associate(vimple#redir('ls!'),
          \ [[ '^\s*\(\d\+\)\(\s*[-u%#ah=+x ]*\)\s\+\"\(.*\)\"\s\+\(\S\+\%(\s\+\S\+\)*\)\s\+\(\d\+\)\%(\s\+.*\)\?$',
            \ '\1,\2,\4,\5,\3',
            \ '' ]],
          \ [ 'split(v:val, ",")',
            \ 'add(v:val[0:3], join(v:val[4:-1], ","))',
            \ '{"number": v:val[0],'
            \.'"line_text": v:val[2],'
            \.'"line": v:val[3],'
            \.'"name": (v:val[4]      =~ ''\[.\{-}\]'' ? (bufname(v:val[0] + 0) ? bufname(v:val[0] + 0) : v:val[4]) : v:val[4]),'
            \.'"listed": v:val[1]     !~ "u",'
            \.'"current": v:val[1]    =~ "%",'
            \.'"alternate": v:val[1]  =~ "#",'
            \.'"active": v:val[1]     =~ "a",'
            \.'"hidden": v:val[1]     =~ "h",'
            \.'"modifiable": v:val[1] !~ "-",'
            \.'"readonly": v:val[1]   =~ "=",'
            \.'"modified": v:val[1]   =~ "+",'
            \.'"read_error": v:val[1] =~ "x"}' ])

    let self.__buffers = {}
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
    return self
  endfun

  " to_s([format]) {{{2
  " format: When absent or empty the default value ("%3b%f\"%n\" line %l\n")
  " will be used.
  " Use %b, %n, %f and %l to insert the buffer number, name, flags and cursor
  " line respectively . The last character will be replaced by d or s as
  " required by printf(), so you can include extra flags (e.g.: %3b).
  func bl.to_s(...) dict
    " An empty format argument uses the default.
    let default = "%3b%f\"%n\" %t %l\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    " Apply filter.
    let buffers = self.data()

    let str = ''
    for key in sort(keys(buffers), 'vimple#comparators#numerically')
      let str .= vimple#format(
            \ format,
            \ { 'b': ['d', buffers[key]['number']],
            \   'f': ['s', self.buffer_flags(buffers[key])],
            \   't': ['s', buffers[key]['line_text']],
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
      call add(pairs, ['vimple_BL_Nnumber', printf('%3d',buffer.number)])
      if buffer.listed
        call add(pairs, ['Normal', ' '])
      else
        call add(pairs, ['vimple_BL_Unlisted', 'u'])
      endif
      if buffer.current
        call add(pairs, ['vimple_BL_Current', '%'])
      elseif buffer.alternate
        call add(pairs, ['vimple_BL_Alternate', '#'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if buffer.active
        call add(pairs, ['vimple_BL_Active', 'a'])
      elseif buffer.hidden
        call add(pairs, ['vimple_BL_Hidden', 'h'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if !buffer.modifiable
        call add(pairs, ['vimple_BL_Modifiable', '-'])
      elseif buffer.readonly
        call add(pairs, ['vimple_BL_Readonly', '='])
      else
        call add(pairs, ['Normal', ' '])
      endif
      if buffer.read_error
        call add(pairs, ['vimple_BL_RearError', 'x'])
      elseif buffer.modified
        call add(pairs, ['vimple_BL_Modified', '+'])
      else
        call add(pairs, ['Normal', ' '])
      endif
      call add(pairs, ['Normal', ' '])
      call add(pairs, [
            \ buffer.current ?
            \ 'vimple_BL_CurrentBuffer' :
            \ buffer.alternate ?
            \ 'vimple_BL_AlternateBuffer' :
            \ 'Normal',
            \ '"' . buffer.name . '"'])
      let spaces = len(buffer.name) >= 29 ? 1 : 29 - len(buffer.name)
      call add(pairs, ['Normal',
            \ repeat(' ', spaces)])
      call add(pairs, ['vimple_BL_Line',
            \ buffer.line_text . ' '])
      call add(pairs, ['vimple_BL_Line',
            \ buffer.line . "\<NL>"
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
    let bl = self.filter(bang . '(' . filter . ')')
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

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
