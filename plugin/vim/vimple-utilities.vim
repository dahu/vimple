"
" Utility commands and functions for vimple
"
" Authors:  Seth Milliken <seth_vim@araxia.net>
"           <your info here>
" Home:     git://github.com/dahu/vimple.git
" Date:     2011-01-19 21:40:25 PST
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
command! -nargs=* -complete=custom,ScriptnamesFileNameCompletion OpenFileFromScriptnames call s:OpenFileFromScriptnames()

if !hasmapto('<Plug>OpenFileFromScriptnames')
    map <silent><unique> <Leader>o <Plug>OpenFileFromScriptnames
endif

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

" }}}
" vim: fdm=marker fdl=0
