""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimple wrapper for :undolist builtin
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Vimple object for Vim's builtin :undolist command.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple/scriptnames.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple#undolist.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple#undolist
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

function! vimple#undolist#get_undolist()
  let bnum = bufnr('%')
  let bname = bufname('%')
  let ulist = vimple#undolist#new()
  if len(ulist.to_l()) != 0
    return [ulist.sort_by_age().to_l()[-1]['age'], bnum, bname]
  else
    return [99999999999, bnum, bname]
  endif
endfunction

function! vimple#undolist#most_recently_used()
  let orig_pos = getpos('.')
  let orig_pos[0] = bufnr('%')

  let uls = []
  bufdo call add(uls, vimple#undolist#get_undolist())
  call sort(uls)

  exe 'buffer ' . orig_pos[0]
  let orig_pos[0] = 0
  call setpos('.', orig_pos)
  return reverse(uls)
endfunction

function! vimple#undolist#print_mru()
  let mru = vimple#undolist#most_recently_used()
  let str = ''
  for buf in mru
    let str .= printf("%3d %s\n", buf[1], buf[2])
  endfor
  return str
endfunction

nnoremap <Plug>VimpleMRU :echo vimple#undolist#print_mru() . "\n"<cr>:buffer<space>
if !hasmapto('<Plug>VimpleMRU')
  nmap <leader>gu <Plug>VimpleMRU
endif

function! vimple#undolist#normalise_time(t, now)
  let t = a:t
  let now = a:now
  if t =~? '^\d\+ '
    let now -= matchstr(t, '^\d*')
    let time = strftime('%Y/%m/%d %H:%M:%S', now)
  elseif t !~ '\/'
    let time = strftime('%Y/%m/%d ', now) . t
  elseif t !~ '\/.*\/'
    let time = strftime('%Y/', now) . t
  else
    let time = t
  endif
  return time
endfunction

function! vimple#undolist#julian_date(t)
  let [year, mon, day] = matchlist(a:t, '^\(\d\{4}\)/\(\d\d\)/\(\d\d\)')[1:3]
  let y = year + 4800 - (mon <= 2)
  let m = mon + (mon <= 2 ? 9 : -3)
  let jul = day + (153 * m + 2) / 5 + (1461 * y / 4) - 32083
  return jul - (y / 100) + (y / 400) + 38
endfunction

" in UTC
function! vimple#undolist#time_to_seconds(t, now)
  let t = vimple#undolist#normalise_time(a:t, a:now)
  let jd = vimple#undolist#julian_date(t)
  let jd_linux = vimple#undolist#julian_date('1970/01/01 00:00:00')
  let [hour, min, sec] = matchlist(t, ' \(\d\d\):\(\d\d\):\(\d\d\)')[1:3]
  return (jd - jd_linux) * 86400 + hour * 3600 + min * 60 + sec
endfunction
.
function! vimple#undolist#new()
  let m = {}
  let m.__data = {}
  let m.__filter = ''

  func m.update() dict abort
    let now = localtime()
    let self.__data = vimple#associate(vimple#redir('undolist')[1:-1],
          \ [
          \   ['^\s*', '', ''],
          \   ['\s\s\+', '__', 'g']
          \ ],
          \ ['split(v:val, "__")',
          \  '{"number"  : v:val[0],
          \    "changes" : v:val[1],
          \    "when"    : vimple#undolist#normalise_time(v:val[2], ' .now. '),
          \    "age"     : vimple#undolist#time_to_seconds(v:val[2], ' .now. '),
          \    "saved"   : len(v:val) == 4 ? v:val[3] : 0
          \  }'])

    return self
  endfunc

  func m.to_s(...) dict
    let default = "%4n %4h %4s %w\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let data = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    for i in range(0, len(data) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'n': ['d', data[i]['number']],
            \   'h': ['d', data[i]['changes']],
            \   'w': ['s', data[i]['when']],
            \   'a': ['d', data[i]['age']],
            \   's': ['d', data[i]['saved']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  func m.agely(a, b) dict
    return a:a['age'] - a:b['age']
  endfunc

  func m.sort_by_age() dict
    let Fn_age = self.agely
    call sort(self.__data, Fn_age, self)
    return self
  endfunc

  func m.to_l() dict
    return self.__data
  endfunc

  "TODO: This looks like a candidate for moving into the parent class... no?
  func m.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  call m.update()
  return m
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
