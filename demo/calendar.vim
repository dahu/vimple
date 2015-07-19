" Interactive Calendar overlay demo
" NOTE: Depends on system 'cal' tool.
" In the overlay window:
" <enter> inserts the date as YYYY-MM-DD from the day under the cursor.
" <left> moves back one month
" <right> moves forward one month
" <pageup> moves back one year
" <pagedown> moves forward one year
" q closes the overlay without action

" functions {{{1

function! GetCalendar(month, year) "{{{2
  let calendar = split(substitute(substitute(substitute(system('cal ' . a:month . ' ' . a:year), '\n', '\n ', 'g'), '_ _', '*', ''), '\s\+\_$', '', 'g'), "\n")
  return calendar
endfunction

function! Calendar(month, year) "{{{2
  call overlay#show(
        \  GetCalendar(a:month, a:year)
        \, {
        \    '<enter>'    : ':call CalendarAccept()<cr>'
        \  , '<right>'    : ':call CalendarUpdate("m", 1)<cr>'
        \  , '<left>'     : ':call CalendarUpdate("m", -1)<cr>'
        \  , '<PageDown>' : ':call CalendarUpdate("y", 1)<cr>'
        \  , '<PageUp>'   : ':call CalendarUpdate("y", -1)<cr>'
        \  , 'q'          : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1, 'month' : a:month, 'year' : a:year})
  syntax match Today '\*\d\+'
  highlight def link Today TODO
endfunction

function! CalendarUpdate(time, amount) "{{{2
  if a:time == 'm'
    let b:options.month += a:amount
  else
    let b:options.year += a:amount
  endif
  call overlay#update(GetCalendar(b:options.month, b:options.year))
endfunction

function! CalendarAccept() "{{{2
  let day = expand('<cword>')
  let date = b:options.year . '-' . printf('%02d', b:options.month) . '-' . printf('%02d', day)
  call overlay#close()
  if exists('g:insertlessly_cleanup_trailing_ws')
    let insertlessly_cleanup_trailing_ws   = g:insertlessly_cleanup_trailing_ws
    let insertlessly_cleanup_all_ws        = g:insertlessly_cleanup_all_ws
    let g:insertlessly_cleanup_trailing_ws = 0
    let g:insertlessly_cleanup_all_ws      = 0
  endif
  if exists('b:cal_mode')
    let cal_mode = b:cal_mode
    unlet b:cal_mode
  else
    let cal_mode = 'i'
  endif
  if cal_mode ==# 'I'
    exe 'norm! a' . date . ' '
    startinsert
    call feedkeys("\<c-o>l")
  elseif cal_mode ==# 'i'
    exe 'norm! i' . date
  elseif cal_mode ==# 'a'
    exe 'norm! a' . date
  elseif cal_mode ==# 'c'
    exe 'norm! ciW' . date
  endif
  if exists('g:insertlessly_cleanup_trailing_ws')
    let g:insertlessly_cleanup_trailing_ws = insertlessly_cleanup_trailing_ws
    let g:insertlessly_cleanup_all_ws      = insertlessly_cleanup_all_ws
  endif
  let b:date = date
  return date
endfunction

function! CalendarToday() "{{{2
  return Calendar(strftime('%m'), strftime('%Y'))
endfunction

" maps {{{1

inoremap <F2>         <esc>:let b:cal_mode='I'<cr>:call CalendarToday()<cr>
nnoremap <leader>dda       :let b:cal_mode='a'<cr>:call CalendarToday()<cr>
nnoremap <leader>ddi       :let b:cal_mode='i'<cr>:call CalendarToday()<cr>
nnoremap <leader>ddc       :let b:cal_mode='c'<cr>:call CalendarToday()<cr>

" vim: fen fdm=marker
