function! s:SID()
  return "<SNR>" . matchstr(expand('<sfile>'), '<SNR>\zs\d\+_\zeSID$')
endfun


function! ExtendedRegexObject(...)
  return call('regex#ExtendedRegex', a:000)
endfunction

" ERex is a global object with access to Vim's vars:
let ERex = ExtendedRegexObject()


function! TagSearch()
  let ident = expand('<cword>')
  if exists('s:tags')
    unlet s:tags
  endif
  let s:tags = taglist(ident)
  if empty(s:tags)
    echohl Warning
    echom 'Tag not found: ' . ident
    echohl None
    return
  endif
  let data = map(copy(s:tags), 'v:key . " " . v:val.name . "\t" . v:val.filename')
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call ' . s:SID() . 'tagsearchaccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! s:tagsearchaccept()
  let ident = matchstr(overlay#select_line(), '^\d\+')
  let fname = s:tags[ident].filename
  if bufnr(fname) == -1
    exec 'edit ' . fname
  else
    exec 'buffer ' . fname
  endif
  silent! exe s:tags[ident].cmd
endfunction

nnoremap <plug>vimple_tag_search :call TagSearch()<cr>

if !hasmapto('<plug>vimple_tag_search')
  nmap <unique><silent> g] <plug>vimple_tag_search
endif


function! IdentSearch(type)
  let type = a:type ? ']I' : '[I'
  try
    let data = vimple#redir('norm! ' . type)
  catch '^Vim\%((\a\+)\)\=:E389:'
    echohl Warning
    echom 'Could not find pattern'
    echohl None
    return
  endtry
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call ' . s:SID() . 'identsearchaccept(' . a:type . ')<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! s:identsearchaccept(type)
  let type = a:type ? ']' : '['
  let num = matchstr(overlay#select_line(), '\d\+')
  exe 'silent! norm! ' . num . type . "\t"
endfunction

nnoremap <plug>vimple_ident_search         :call IdentSearch(0)<cr>
nnoremap <plug>vimple_ident_search_forward :call IdentSearch(1)<cr>

if !hasmapto('<plug>vimple_ident_search')
  nmap <unique><silent> [I <plug>vimple_ident_search
endif

if !hasmapto('<plug>vimple_ident_search_forward')
  nmap <unique><silent> ]I <plug>vimple_ident_search_forward
endif



function! SpellSuggest(ident)
  call overlay#show(
        \  s:getsuggestions(a:ident)
        \, {
        \    '<enter>' : ':call ' . s:SID() . 'spellsuggestaccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 0, 'use_split' : 1})
endfunction

function! s:getsuggestions(ident)
  let spell = &spell
  if ! spell
    set spell
  endif
  let suggestions = list#lspread(spellsuggest(a:ident), 5)
  if ! spell
    set nospell
  endif
  return suggestions
endfunction

function! s:spellsuggestaccept()
  let line = getline('.')
  let idx = strlen(substitute(line[:col('.')], '[^\t]', '', 'g'))
  let word_list = split(line, '\t')
  call overlay#close()
  let [r1, r2] = [@@, @-]
  exe 'norm! ciw' . word_list[idx]
  let [@@, @-] = [r1, r2]
endfunction

nnoremap <plug>vimple_spell_suggest :call SpellSuggest(expand('<cword>'))<cr>

if !hasmapto('<plug>vimple_spell_suggest')
  nmap <unique><silent> z= <plug>vimple_spell_suggest
endif


function! BufGrep(pattern)
  let pattern = a:pattern
  let fc = pattern[0]
  let lc = pattern[-1]
  if fc !~ '[[:punct:]]'
    let fc = '/'
    let lc = '/'
  elseif fc != lc
    let lc = fc
    let pattern = pattern[1:]
  else
    let pattern = pattern[1:-2]
  endif
  let pattern = escape(pattern, fc)

  let data = vimple#redir('global ' . fc . pattern . lc . '#')
  if data[0] =~ 'Pattern not found:'
    echohl Warning
    echo data[0]
    echohl None
    return
  endif
  call overlay#show(
        \  data
        \, {
        \    '<enter>' : ':call ' . s:SID() . 'bufgrepaccept()<cr>'
        \  , 'q' : ':call overlay#close()<cr>'
        \  }
        \, {'filter'    : 1, 'use_split' : 1})
endfunction

function! s:bufgrepaccept()
  let num = matchstr(overlay#select_line(), '\d\+')
  exe 'silent! norm! ' . num . "G"
endfunction

command! -nargs=* G call BufGrep(<q-args>)

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
  " call ShowInNewBuf(data)
  call overlay#show(data, {'q' : ':call overlay#close()<cr>'}, {'use_split' : 1, 'filter' : index(g:vimple_auto_filter, 'view') != -1})
  " if index(g:vimple_auto_filter, 'view') != -1
  "   Filter
  " endif
endfunction

if ! exists('g:vimple_auto_filter')
  let g:vimple_auto_filter = ['view', 'vfm']
endif

function! ShowInNewBuf(data)
  call overlay#show(a:data, {}, {'use_split' : 1, 'filter' : 0})
  " new
  " setlocal buftype=nofile
  " setlocal bufhidden=wipe
  " setlocal noswapfile
  " call setline(1, a:data)
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
