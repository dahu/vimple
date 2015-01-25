function! StringScanner(first, last, command, ...)
  let args = []
  if a:0
    let args = a:000
  endif
  let ss = string#scanner(getline(a:first, a:last))
  let g:vimple#ss = call(eval('ss.' . a:command), args, ss)
  return g:vimple#ss
endfunction

command! -bar -range=% -nargs=+ StringScanner echo StringScanner(<line1>, <line2>, <f-args>)

function! Mkvimrc()
  let rtp = uniq(map(filter(map(getline(1, '$'),
        \ 'matchstr(v:val, "^\\s*\\d\\+:\\s\\+\\zs.*")'), 'v:val != ""'),
        \ 'fnameescape(substitute(v:val, "/\\(autoload\\|colors\\|compiler\\|doc\\|ftdetect\\|ftplugin\\|indent\\|keymap\\|lang\\|plugin\\|syntax\\).*", "", ""))'))

  if empty(rtp)
    echohl Error
    echom 'Mkvimrc: Buffer does not contain :scriptnames output'
    echohl None
    return
  endif
  let vimrc_lines = [
        \   "set nocompatible"
        \ , "let &rtp = join(" . string(map(rtp, 'fnameescape(v:val)')) . ", ',') . ',' . &rtp"
        \ , "filetype plugin indent on"
        \ , "syntax enable"
        \ ]
  let datetime = localtime()
  let vimrc_file = './vimrc-' . datetime
  call writefile(vimrc_lines, vimrc_file)
  return vimrc_file
endfunction

command! -nargs=0 -bar Mkvimrc echom Mkvimrc()

function! BufDo(cmds)
  let old_hidden = &hidden
  set hidden
  tabnew
  echom 'bufdo ' . a:cmds
  exe 'bufdo ' . a:cmds
  tabclose
  let &hidden = old_hidden
endfunction

function! BufTypeDo(args)
  let [type; commands] = split(a:args, ' ')
  let cmds = join(commands)
  call BufDo('if &ft ==? "' . escape(type, '"') . '" | exe "' . escape(cmds, '"') . '" | endif')
endfunction

function! BufMatchDo(args)
  let [pattern; commands] = split(a:args, ' ')
  let cmds = join(commands)
  call BufDo('if expand("%") =~? "' . escape(pattern, '"') . '" | exe "' . escape(cmds, '"') . '" | endif')
endfunction

command! -nargs=+ BufTypeDo call BufTypeDo(<q-args>)
command! -nargs=+ BufMatchDo call BufMatchDo(<q-args>)

function! QFbufs()
  return quickfix#bufnames()
endfunction

command! -nargs=? QFargs call quickfix#to_args(<q-args>)

command! -nargs=+ QFdo call quickfix#do(<q-args>)

command! -range -nargs=0 Filter call vimple#filter(getline(1,'$'), {}).filter()
nnoremap <plug>vimple_filter :Filter<cr>

if !hasmapto('<plug>vimple_filter')
  nmap <unique><silent> <leader>cf <plug>vimple_filter
endif

" Takes a range as well as optional start and end lines to extract from the
" file. If both ends of the range are given, the shorter of first:last vs
" start:end will be used to fill the range.
function! ReadIntoBuffer(file, ...) range
  let first = a:firstline
  let last = a:lastline
  let lines = readfile(a:file)
  let start = 0
  let end = len(lines)
  if a:0
    let start = a:1 - 1
    if a:0 > 1
      let end = a:2 - 1
    endif
  endif
  if start > len(lines)
    return
  endif
  let lines = lines[start : end]
  if len(lines) > (last-first)
    let lines = lines[0:(last-first-1)]
  endif
  call append(first, lines)
endfunction

command! -range -nargs=+ -complete=file ReadIntoBuffer <line1>,<line2>call ReadIntoBuffer(<f-args>)

function! View(cmd)
  let data = vimple#redir(a:cmd)
  call ShowInNewBuf(data)
  if index(g:vimple_auto_filter, 'view') != -1
    Filter
  endif
endfunction

if ! exists('g:vimple_auto_filter')
  let g:vimple_auto_filter = ['view', 'vfm']
endif

function! ShowInNewBuf(data)
  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, a:data)
endfunction

command! -nargs=+ -complete=command View call View(<q-args>)
command! -nargs=+ -complete=command ViewExpr call ShowInNewBuf(eval(<q-args>))

function! Collect(args)
  let [regvar; command] = split(a:args)
  let cmd = join(command, " ")
  let list = &list
  set nolist
  let buf = join(vimple#redir(cmd), "\n")
  if list
    set list
  endif
  if len(regvar) > 1
    exe 'let ' . regvar . '="' . escape(buf, '"') . '"'
  else
    call setreg(regvar, buf)
  endif
  return split(buf, '\n')
endfunction

function! GCollect(pattern)
  return map(Collect('_ g/' . a:pattern), 'substitute(v:val, "^\\s*\\d\\+\\s*", "", "")')
endfunction

function! GCCollect(pattern)
  return map(map(Collect('_ g/' . a:pattern), 'join(split(v:val, "^\\s*\\d\\+\\s*"))'),
        \ 'substitute(v:val, a:pattern, "", "")')
endfunction

function! VCollect(pattern)
  return map(Collect('_ v/' . a:pattern), 'substitute(v:val, "^\\s*\\d\\+\\s*", "", "")')
endfunction

function! VCCollect(pattern)
  return map(map(Collect('_ v/' . a:pattern), 'join(split(v:val, "^\\s*\\d\\+\\s*"))'),
        \ 'substitute(v:val, a:pattern, "", "")')
endfunction

command! -nargs=+ Collect call Collect(<q-args>)

function! SCall(script, function, args)
  let scripts = g:vimple#sn.update().filter_by_name(a:script).to_l()
  if len(scripts) == 0
    echo "SCall: no script matches " . a:script
    return
  elseif len(scripts) > 1
    echo "SCall: more than one script matches " . a:script
  endif
  let func = '<SNR>' . scripts[0]['number'] . '_' . a:function
  if exists('*' . func)
    return call(func, a:args)
  else
    echo "SCall: no function " . func . " in script " . a:script
    return
  endif
endfunction

command! -nargs=+ Silently exe join(map(split(<q-args>, '|'), '"silent! ".v:val'), '|')

" It seems that the {name} way of initiallising variables is SLOW in vim
" " Pre-initialise library objects
" let s:pairs = [
"       \ ['bl', 'ls'],
"       \ ['hl', 'highlight'],
"       \ ['sn', 'scriptnames'],
"       \ ['vn', 'version'],
"       \ ['ma', 'marks'],
"       \ ['ul', 'undolist'],
"       \ ['mp', 'map'],
"       \ ['op', 'options'],
"       \]
" if get(g:, 'vimple_init_vars', 1)
"   for [name, func] in s:pairs
"     if get(g:, 'vimple_init_'.name, 1)
"       let vimple#{name} = vimple#{func}#new()
"     endif
"   endfor
" endif

if get(g:, 'vimple_init_vars', 1)
  if get(g:, 'vimple_init_bl', 1)
    let vimple#bl = vimple#ls#new()
  endif
  if get(g:, 'vimple_init_hl', 1)
    let vimple#hl = vimple#highlight#new()
  endif
  if get(g:, 'vimple_init_sn', 1)
    let vimple#sn = vimple#scriptnames#new()
  endif
  if get(g:, 'vimple_init_vn', 1)
    let vimple#vn = vimple#version#new()
  endif
  if get(g:, 'vimple_init_ma', 1)
    let vimple#ma = vimple#marks#new()
  endif
  if get(g:, 'vimple_init_ul', 1)
    let vimple#ul = vimple#undolist#new()
  endif
  if get(g:, 'vimple_init_mp', 1)
    let vimple#mp = vimple#map#new()
  endif
  if get(g:, 'vimple_init_op', 0)
    let vimple#op = vimple#options#new()
  endif
endif

call vimple#default_colorscheme()

" disabled by default
" let vimple#au = vimple#autocmd#new()
