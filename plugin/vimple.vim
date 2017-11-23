" Vimple maps and commands
" NOTE: These can be disabled by adding this line to your $MYVIMRC:
"   let g:init_vimple_maps_and_commands = 0

if ! exists('g:init_vimple_maps_and_commands')
  let g:init_vimple_maps_and_commands = 1
endif

if ! g:init_vimple_maps_and_commands
  finish
endif

if ! exists('g:vimple_override_file_complete')
  let g:vimple_override_file_complete = 0
endif
if ! exists('g:vimple_file_complete_short')
  let g:vimple_file_complete_short = 0
endif
if ! exists('g:vimple_override_line_complete')
  let g:vimple_override_line_complete = 0
endif

if g:vimple_override_file_complete
  if g:vimple_file_complete_short
    inoremap <expr> <c-x><c-f> complete#trigger('complete#short_files_in_path')
  else
    inoremap <expr> <c-x><c-f> complete#trigger('complete#files_in_path')
  endif
endif
if g:vimple_override_line_complete
  inoremap <expr> <c-x><c-l> complete#trigger('complete#foist')
endif


nnoremap <plug>vimple_tag_search :call TagSearch()<cr>

if !hasmapto('<plug>vimple_tag_search')
  nmap <unique><silent> g] <plug>vimple_tag_search
endif



nnoremap <plug>vimple_ident_search         :call IdentSearch(0)<cr>
nnoremap <plug>vimple_ident_search_forward :call IdentSearch(1)<cr>

if !hasmapto('<plug>vimple_ident_search')
  nmap <unique><silent> [I <plug>vimple_ident_search<bs>
endif

if !hasmapto('<plug>vimple_ident_search_forward')
  nmap <unique><silent> ]I <plug>vimple_ident_search_forward
endif



nnoremap <plug>vimple_spell_suggest :call SpellSuggest(expand('<cword>'))<cr>

if !hasmapto('<plug>vimple_spell_suggest')
  nmap <unique><silent> z= <plug>vimple_spell_suggest
endif



command! -nargs=* G call BufGrep(<q-args>)

command! -bar -range=% -nargs=+ StringScanner echo StringScanner(<line1>, <line2>, <f-args>)


command! -nargs=0 -bar Mkvimrc echom Mkvimrc()


command! -nargs=+ BufTypeDo call BufTypeDo(<q-args>)
command! -nargs=+ BufMatchDo call BufMatchDo(<q-args>)

command! -bar     QFargs      call quickfix#to_args(1)
command! -bar     QFargslocal call quickfix#to_args(0)
command! -bar     LLargs      call loclist#to_args(1)
command! -bar     LLargslocal call loclist#to_args(0)

command! -bar     QFbufs      echo quickfix#bufnames()
command! -bar     LLbufs      echo loclist#bufnames()

command! -nargs=+ QFdo        call quickfix#do(<q-args>)
command! -nargs=+ LLdo        call loclist#do(<q-args>)

command! -range -nargs=0 Filter call vimple#filter(getline(1,'$'), {}).filter()
nnoremap <plug>vimple_filter :Filter<cr>

if !hasmapto('<plug>vimple_filter')
  nmap <unique><silent> <leader>cf <plug>vimple_filter
endif


command! -range -nargs=+ -complete=file ReadIntoBuffer <line1>,<line2>call ReadIntoBuffer(<f-args>)


command! -bar -nargs=+ -complete=command View     call View(<q-args>)
command! -bar -nargs=+ -complete=command ViewFT   call ViewFT(<q-args>)
command! -bar -nargs=+ -complete=command ViewExpr call ShowInNewBuf(eval(<q-args>))
command! -bar -nargs=+ -complete=command ViewSys  call ShowInNewBuf(split(system(<q-args>), "\n"))


command! -nargs=+ Collect  call Collect(<q-args>)
command! -nargs=+ GCollect let GC = GCollect(<q-args>)


command! -nargs=+ Silently exe join(map(split(<q-args>, '|'), '"silent! ".v:val'), '|')

