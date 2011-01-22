"
" Utility commands and functions for vimple
"
" Maintainers:  Seth Milliken <seth_vim@araxia.net>
"               <your info here>
" Home:         git://github.com/dahu/vimple.git
" Date:         2011-01-21 21:27:44 PST
"

" Todo List {{{
" TODO: localize private functions to script
" TODO: expose external commands as <Plug>s
" TODO: define default mappings for commands
" TODO: help documentation

" }}}
" Internal Maintenance {{{
function! s:RemoveScriptSymbol(symbol)
    exec "let l:symbol_existence = exists(\":" . a:symbol . "\") \| if l:symbol_existence == 2 \| delcommand " . a:symbol . " \| endif"
    exec "if exists(\"*" . a:symbol . "\") \| delfunction " . a:symbol . " \| endif"
    " TODO: try to unmap maps, too?
endfunction

" }}}
" Debug {{{

" let s:debug_mode = 1
if !exists("s:debug_mode")
    if exists("loaded_vimple_utilities") || &cp
       finish
    endif

    let loaded_vimple_utilities = 1
else
    echo "Debug mode enabled."
    call s:RemoveScriptSymbol("OpenFileFromScriptnames")
    unlet s:debug_mode
endif

python << BLOCKCOMMENT
""" Work in progress...

noremap <unique> <script> <Plug>OpenFileFromScriptnames <SID>OpenFileFromScriptnames

noremap <SID>OpenFileFromScriptnames :call OpenFileFromScriptnames()<CR>

"""
BLOCKCOMMENT

" }}}
" External Definitions {{{
"
" OpenFileFromScriptnames
"
command! -nargs=* -complete=custom,ScriptnamesFileNameCompletion OpenFileFromScriptnames call OpenFileFromScriptnames()

if !hasmapto('<Plug>OpenFileFromScriptnames')
    map <silent><unique> <Leader>o <Plug>OpenFileFromScriptnames
endif
noremap <unique><script> <Plug>OpenFileFromScriptnames :OpenFileFromScriptnames<CR>

"
" RedirectMessageOutput
"
command! -nargs=? GrepMessages call GrepMessages(<f-args>)
command! -nargs=* RedirectMessageOutput call RedirectMessageOutput(<f-args>)
command! -nargs=* GrepRedirectedMessageOutput call GrepRedirectedMessageOutput(<f-args>)

exec "map <buffer> <unique> <D-j>m :GrepMessages "
exec "map <buffer> <unique> <D-j>r :RedirectMessageOutput "
exec "map <buffer> <unique> <D-j>g :GrepRedirectedMessageOutput "

" }}}
" Implementations {{{

" OpenFileFromScriptnames {{{
"
" Prompt for a file to open using all of the files in :scriptnames as
" completion options.
"
function! OpenFileFromScriptnames()
   let l:incoming = input("Open script file: ", "", "custom,ScriptnamesFileNameCompletion")
   echo l:incoming
   if l:incoming != ""
       let l:dictionary = ScriptnamesToPathDictionary()
       let l:file_to_edit = l:dictionary[l:incoming]
       " TODO: allow for different methods of opening: split, vsplit, in current
       " window, first tab, last tab, adjacent tab, in a house, with a mouse, etc.
       exec ":tabe " . l:file_to_edit
   endif
   if exists("s:scriptnames_dictionary")
       unlet s:scriptnames_dictionary
   endif
endfunction

"
" Completion function glue
"
" n.b. we join here because we want to use custom instead of customlist
" completion so that vim does the filtering for us. 
" see :help :command-completion-custom
function! ScriptnamesFileNameCompletion(A,L,P)
    return join(keys(ScriptnamesToPathDictionary()), "\n")
endfunction

"
" Dictionary of scripts from :scriptnames as { filename: filepath }
" 
" unlet s:scriptnames_dictionary when you are done with the dictionary to allow its
" regeneration.
" TODO: option to filter out $VIMRUNTIME files?
function! ScriptnamesToPathDictionary()
    " From :help scriptnames-dictionary
    if !exists("s:scriptnames_dictionary")
        let l:scriptnames_output = ''
        redir => l:scriptnames_output
            silent scriptnames
        redir END
        let l:scripts = {}
        for l:line in split(scriptnames_output, "\n")
          if l:line =~ '\S'
            let l:path = substitute(l:line, '.\+:\s*', '', '')
            let l:name = substitute(l:path, '.*/', '', '')
            let l:scripts[l:name] = l:path
          endif
        endfor
        unlet l:scriptnames_output
        let s:scriptnames_dictionary = l:scripts
    endif
    return s:scriptnames_dictionary
endfunction

" }}}
" Redirect Output {{{
function! GrepMessages(...)
    let l:matchstring = get(a:000, 0, "$")
    let l:command_output = ""
    let l:command_to_grep = ValidHistoryLine(0)
    echo "Grepping output of: " . l:command_to_grep
    redir =>> l:command_output
"        echo l:command_to_grep
        silent execute l:command_to_grep
    redir END
    if l:command_output != ""
        vert new | set bt=nofile | call setline("$", split(l:command_output, "\n"))
        let &undolevels = &undolevels
        silent execute "v/" . l:matchstring . "/d"
    else
        echo "Command had no output: ". l:command_to_grep
    endif
endfunction

function! GrepRedirectedMessageOutput(matchstring, ...)
    call histadd("cmd", join(a:000, " "))
    call GrepMessages(a:matchstring)
endfunction

function! RedirectMessageOutput(...)
    call GrepRedirectedMessageOutput("$", join(a:000, " "))
endfunction

function! ValidHistoryLine(attempt)
    let l:index = a:attempt
    if !exists("s:full_blacklist")
        let s:full_blacklist = s:BlackList()
    endif
    if l:index == 0
        let l:index = 1
    end
    let l:command_candidate = histget("cmd", -l:index)
    if match(l:command_candidate, s:full_blacklist) > -1
        return ValidHistoryLine(l:index + 1)
    endif
    unlet s:full_blacklist
    return l:command_candidate
endfunction

function! s:BlackList()
    let l:full_blacklist = s:DefaultBlackList()
    if exists("g:extra_blacklist")
        if type(g:extra_blacklist) == type([])
            let l:full_blacklist = extend(g:extra_blacklist, l:full_blacklist)
        else
            echohl WarningMsg | echo "g:extra_blacklist" . " must be a List." | echohl None
        endif
    endif
    return join(l:full_blacklist, "\\|")
endfunction

function! s:DefaultBlackList()
    let l:blacklist =   [
                        \ 'GrepRedirectedMessageOutput',
                        \ 'ValidHistoryLine',
                        \ 'RedirectMessageOutput',
                        \ 'GrepMessages',
                        \ '^so[urce]\{,4}',
                        \ '^w[rite]\{,4}',
                        \ '^h[elp]\{,3}',
                        \ ]
    return l:blacklist
endfunction

python << COMMENT
"""
unlet g:extra_blacklist
let g:extra_blacklist = [
                        \ ':e',
                        \ '^w',
                        \ ]
"""
COMMENT

" }}}
" EXPERIMENTAL: {{{
" should try runVimTests before going any further with this
" <http://www.vim.org/scripts/script.php?script_id=2565>
let g:current_tests =   [
                        \ 'Boo',
                        \ 'Foo',
                        \ 'Test1',
                        \ 'Test2',
                        \ ]
function! VimpleTestRunner()
    for current_test in g:current_tests
        echo "Running " . current_test . "..."
        call s:ResetTest()
        let Fn = function("s:" . current_test)
        call Fn()
    endfor
endfunction

function! s:Boo()
    echo "Boo"
endfunction

function! s:Foo()
    echo "foo"
endfunction

function! s:Test1()
    let g:extra_blacklist = [
                            \ 'scriptnames',
                            \ ]
    call histadd("cmd", "set")
    call histadd("cmd", "scriptnames")
    call GrepMessages("Options")
endfunction

function! s:Test2()
    let g:extra_blacklist = 2
    call histadd("cmd", "set")
    call GrepMessages("Options")
endfunction

function! s:ResetTest()
    if exists("g:extra_blacklist")
        unlet g:extra_blacklist
    endif
endfunction


" }}}

" }}}
" vim: fdm=marker fdl=0
