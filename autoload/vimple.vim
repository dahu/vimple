""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim library provides objects for builtin ++:ex++ commands
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.9
" Description:	Vimple provides VimLOO (Object Oriented VimL) objects for
" 		Vim's write-only ++:ex++ commands, such as ++:ls++,
" 		++:scriptnames++ and ++:highlight++.
" Last Change:	2012-04-08
" License:	Vim License (see :help license)
" Location:	autoload/vimple.vim
" Website:	https://github.com/dahu/vimple
"
" See vimple.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimple
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimple_version = '0.9'

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

" Library Interface: {{{1
"let str = vimple#format(
"      \ format,
"      \ { 'b': ['d', 1],
"      \   'f': ['s', "abc"],
"      \   'n': ['s', "efg"],
"      \   'l': ['s', "hij"]},
"      \ default
"      \ )

function! vimple#format(format, args_d, default)
  let format = a:format == '' ? a:default : a:format
  let format = substitute(format, '\(%%\)*\zs%[-0-9#+ .]*c', a:default, 'g')

  let args = ''
  let items = map(split(substitute(format, '%%', '', 'g'), '\ze%'), 'matchstr(v:val, ''^%[-+#. 0-9]*.'')')
  call map(items, 'substitute(v:val, ''^%[-0-9#+ .]*\(.\)'', ''\1'', "g")')
  for item in items
    let arg_l = get(a:args_d, item, '')
    if type(arg_l) != type([])
      continue
    endif
    let args .= arg_l[0] == 's' ? string(arg_l[1]) : arg_l[1]
    let args .= args[-1] =~ ',' ? '' : ', '
  endfor
  let args = substitute(args, '^\s*,\s*\(.\{-}\),\s*$', '\1', '')

  let format = substitute(format, '\%(%%\)*%[-1-9#+ .]*\zs.', '\=get(a:args_d[submatch(0)], 0,submatch(0))', 'g')
  let printf_str ='printf("'.escape(format, '\"').'", '.args.')'

  return eval(printf_str)
endfunction

function! vimple#redir(command, ...)
  let split_pat = '\n'
  let str = ''
  if a:0 != 0
    let split_pat = a:1
  endif
  let lang = v:lang
  silent! language messages C
  redir => str
  silent exe a:command
  redir END
  silent! exec 'language messages ' . lang
  return split(str, split_pat)
endfunction

function! vimple#associate(lines, subs, maps)
  let lst = copy(a:lines)
  for i in range(0, len(lst) - 1)
    " echo lst[i]
    for s in a:subs
      " echo "  " . string(s)
      let lst[i] = substitute(lst[i], s[0], s[1], s[2])
      " echo "  -->" . string(lst[i])
    endfor
  endfor
  call filter(lst, 'v:val != ""')
  for m in a:maps
    " echo "\n" . m
    call map(lst, m)
    " echo "-->" . string(lst)
  endfor
  return lst
endfunction

function! vimple#join(data, pattern)
  let x = -1
  let lines = repeat([''], len(a:data))
  for line in a:data
    if line =~ a:pattern
      let lines[x] .= line
    else
      let x += 1
      let lines[x] = line
    endif
  endfor
  return filter(lines, 'v:val !~ "^$"')
endfunction

function! vimple#echoc(data)
  for sets in a:data
    exe "echohl " . sets[0]
    exe "echon " . string(sets[1])
  endfor
  echohl Normal
endfunction

function! s:vimple_highlight(name, attrs)
  if !hlexists(a:name)
    silent exe "hi ".a:name." ".a:attrs
  endif
endfunction

" Solarized inspired default colours...
" Doesn't override existing user-defined colours for these highlight terms.
" Shown with case here, but actually case-insensitive within Vim.
"
" TODO: Only vaguely considered at this stage. Based on the 16 colour
" solarized pallette
" the order of applying these to echoc is important
"
function! vimple#default_colorscheme()
  " Buffer List
  call s:vimple_highlight('vimple_BL_Number'          , 'ctermfg=4 ctermbg=8 guifg=#0087ff guibg=#1c1c1c')
  call s:vimple_highlight('vimple_BL_Line'            , 'ctermfg=10 ctermbg=8 guifg=#4e4e4e guibg=#1c1c1c')
  call s:vimple_highlight('vimple_BL_Name'            , 'ctermfg=12 ctermbg=8 guifg=#808080 guibg=#1c1c1c')
  call s:vimple_highlight('vimple_BL_Unlisted'        , 'ctermfg=10 ctermbg=8 guifg=#4e4e4e guibg=#1c1c1c')
  call s:vimple_highlight('vimple_BL_CurrentBuffer'   , 'ctermfg=14 ctermbg=0 guifg=#8a8a8a guibg=#262626')
  call s:vimple_highlight('vimple_BL_AlternateBuffer' , 'ctermfg=14 ctermbg=0 guifg=#8a8a8a guibg=#262626')
  " buffer active
  call s:vimple_highlight('vimple_BL_Active'          , 'ctermfg=12 ctermbg=0 guifg=#808080 guibg=#262626')
  call s:vimple_highlight('vimple_BL_Hidden'          , 'ctermfg=10 ctermbg=8 guifg=#4e4e4e guibg=#1c1c1c')
  " flags
  call s:vimple_highlight('vimple_BL_Current'         , 'ctermfg=5 guifg=#af005f')
  call s:vimple_highlight('vimple_BL_Alternate'       , 'ctermfg=13 guifg=#5f5faf')
  call s:vimple_highlight('vimple_BL_Modifiable'      , 'ctermfg=2 guifg=#5f8700')
  call s:vimple_highlight('vimple_BL_Readonly'        , 'ctermfg=6 guifg=#00afaf')
  call s:vimple_highlight('vimple_BL_Modified'        , 'ctermfg=9 guifg=#d75f00')
  call s:vimple_highlight('vimple_BL_ReadError'       , 'ctermfg=1 guifg=#af0000')

  " Scriptnames
  call s:vimple_highlight('vimple_SN_Number'          , 'ctermfg=4 ctermbg=8 guifg=#0087ff guibg=#1c1c1c')
  call s:vimple_highlight('vimple_SN_Term'            , 'ctermfg=12 ctermbg=8 guifg=#808080 guibg=#1c1c1c')

  " Options
  call s:vimple_highlight('vimple_OP_BoolEnabled'     , 'ctermfg=12 ctermbg=8 guifg=#808080 guibg=#262626')
  call s:vimple_highlight('vimple_OP_BoolDisabled'    , 'ctermfg=10 ctermbg=8 guifg=#4e4e4e guibg=#1c1c1c')
endfunction

function! vimple#tracer()
  let d = {}
  func d.t()
    return expand('<sfile>')
  endfunc
  echom d.t()
endfunction

" Buffer Line Filter {{{1
function! vimple#filter(lines, options)
  let obj = {}
  let obj.lines = a:lines
  let obj.options = a:options

  func obj.initialize() dict
    if has_key(self.options, 'new')
      enew
    endif
    if has_key(self.options, 'msg')
      let self.msg = self.options.msg
    else
      let self.msg = 'Filter: '
    endif
    return self
  endfunc

  func obj.filter() dict
    let old_hls = &hlsearch
    set hlsearch
    call self.incremental()
    let &hlsearch = old_hls
    return self
  endfunc

  func obj.incremental() dict
    let c = ''
    let self.partial = ''
    let &ul = &ul
    call self.update(0)
    while 1
      call self.update(1)
      let c = nr2char(getchar())
      if c == "\<cr>"
        break
      elseif c == "\<c-w>"
        if self.partial =~ '\k\+\s*$'
          let self.partial = substitute(self.partial, '\k\+\s*$', '', '')
        else
          let self.partial = substitute(self.partial, '.*\k\+\zs.*$', '', '')
        endif
      elseif c == "\<esc>"
        silent undo
        break
      elseif c == ''
        let self.partial = self.partial[:-2]
      else
        let self.partial .= c
      endif
    endwhile
  endfunc

  func obj.update(undojoin) dict
    if a:undojoin
      undojoin
    endif
    %delete
    let partial = substitute(substitute(self.partial, ' ', '.*', 'g'), '\.\*$', '', '')
    if partial =~ '\.\*\$$'
      let partial = substitute(partial, '\.\*\$$', '$', '')
    endif
    call append(0, filter(copy(self.lines), 'v:val =~ partial'))
    $delete
    if self.partial == ''
      nohlsearch
    else
      exe "silent! norm! /" . partial . "\<cr>"
    endif
    1
    redraw
    echo self.msg . self.partial
  endfunc

  return obj.initialize()
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" vim: set sw=2 sts=2 et fdm=marker:
