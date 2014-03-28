function! View(cmd)
  let data = vimple#redir(a:cmd)
  call ShowInNewBuf(data)
endfunction

function! ShowInNewBuf(data)
  new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, a:data)
endfunction

command! -nargs=+ -complete=command View call View(<q-args>)

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
endif

call vimple#default_colorscheme()

" disabled by default
" let vimple#au = vimple#autocmd#new()
