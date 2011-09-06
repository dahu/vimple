"
" Utility commands and functions for vimple
"
" Maintainers:  Seth Milliken <seth_vim@araxia.net>
"               <your info here>
" Home:         git://github.com/dahu/vimple.git
" Date:         2011-01-21 21:27:44 PST
"
" Todo List " {{{
" TODO: allow configuration of new buffer orientation
" TODO: localize private functions to script
" TODO: expose external commands as <Plug>s
" TODO: define default mappings for commands
" TODO: help documentation

" }}}


" Redirect Message Output " {{{
"
" Execute a command redirecting its messages to a new buffer.
"
" TODO: use 'verbosefile'
"
" External Definitions: see fold contents " {{{

if !exists(":GrepPreviousMessageOutput")
    command! -nargs=? -complete=command GrepPreviousMessageOutput :call s:GrepPreviousMessageOutput(<f-args>)
endif
if !exists(":RedirectMessageOutput")
    command! -nargs=* -complete=command RedirectMessageOutput :call s:RedirectMessageOutput(<f-args>)
endif
if !exists(":RedirectedMessageOutputGrep")
    command! -nargs=* -complete=command RedirectedMessageOutputGrep :call s:GrepRedirectedMessageOutput(<f-args>)
endif

" }}}

"
" TODO: take a function for postprocessing of redir buffer
"
map <buffer> K <Esc>:w<CR>:so %<CR>:Redir 

command! -nargs=? -complete=command Redir  :call RedirectMessageOutputFromCommand(<f-args>)
function! RedirectMessageOutputFromCommand(command) " {{{
    let quoted_command = "\"" . a:command . "\""
    echo "Redirecting output of: " . quoted_command
    let l:command_output = ""
    redir =>> l:command_output
        silent execute a:command
    redir END
    if l:command_output != ""
        vert new | set bt=nofile | set ft=vim | call setline("$", split(l:command_output, "\n")) | call append(0, ["Output from " .quoted_command . ":", ""])
        let &undolevels = &undolevels
    else
        echo "Command had no output: ". quoted_command
    endif
endfunction

" }}}
function! s:GrepMessages(...) " {{{
    let l:matchstring = get(a:000, 0, "$")
    let l:command_output = ""
    let l:command_to_grep = s:ValidHistoryLine(0)
    echo "Grepping output of: " . l:command_to_grep
    redir =>> l:command_output
        silent execute l:command_to_grep
    redir END
    if l:command_output != ""
        vert new | set bt=nofile | call setline("$", split(l:command_output, "\n")) | call append(0, ["Output from \"" . a:command . "\":"])
        let &undolevels = &undolevels
        silent execute "v/" . l:matchstring . "/d"
    else
        echo "Command had no output: ". l:command_to_grep
    endif
endfunction

" }}}
function! s:GrepRedirectedMessageOutput(matchstring, ...) " {{{
    call histadd("cmd", join(a:000, " "))
    call s:GrepMessages(a:matchstring)
endfunction

" }}}
function! s:RedirectMessageOutput(...) " {{{
    call s:GrepRedirectedMessageOutput("$", join(a:000, " "))
endfunction

" }}}
function! s:ValidHistoryLine(attempt) " {{{
    let l:index = a:attempt
    if !exists("s:full_blacklist")
        let s:full_blacklist = s:BlackList()
    endif
    if l:index == 0
        let l:index = 1
    end
    let l:command_candidate = histget("cmd", -l:index)
    if match(l:command_candidate, s:full_blacklist) > -1
        return s:ValidHistoryLine(l:index + 1)
    endif
    unlet s:full_blacklist
    return l:command_candidate
endfunction

" }}}
function! s:BlackList() " {{{
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

" }}}
function! s:DefaultBlackList() " {{{
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

" }}}
" Blacklist Testing " {{{
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

" }}} Redirect Message Output

" LineMutator Objects " {{{

" StatusToggler v4 " {{{
" Change the state of a status indicator on a line.
"
" NewStatusToggler(toggleset)
" .toggleset    comma-separated list of the states through which to rotate
"               passing a single value will create a status setter
" .toggle()     toggle state of status indicator on current line
" .begin        contains a pattern required to precede a status indicator
" .trail        contains a pattern required to follow a status indicator
" .status_indicator() everything found between .begin and .trail on current line
"
" Example:
" let b:status = NewStatusToggler("o", "x", "-")
" > - this is the line
" call b:status.toggle()
" > o this is the line
" call b:status.toggle()
" > x this is the line
" call b:status.toggle()
" > - this is the line
"
" StatusToggler TODO " {{{
" - TODO: incorporate debug methods
" - TODO: inherit from a richer base class
" }}}
function! NewStatusToggler(...) " {{{
    let statustoggler = {}
    let statustoggler.toggleset = copy(a:000)
    let statustoggler.begin = "^\\s*\\zs"
    let statustoggler.trail = "\\s"
    let statustoggler.custom_line = 0
    fu! statustoggler.line()
      if self.custom_line > 0
        return self.custom_line
      else
        return line(".")
      end
    endfu
    fu! statustoggler.getline()
        return getline(self.line())
    endfu
    fu! statustoggler.toggle(...) dict
        if len(a:000) > 0
          let self.custom_line = a:000[0]
        end
        if self._nexttoggle()
          call self._setstatus(self.toggleset[0], self.toggleset[1])
        end
    endfu
    fu! statustoggler.debug(output)
        if &verbose > 0
            echo printf("%s: %s", expand("<sfile>"), a:output)
        endif
    endfu
    fu! statustoggler._setstatus(from,to)
        let escapechars = '[]'
        let from = escape(a:from, escapechars)
        let to = escape(a:to, escapechars)
        call self.debug(printf("match: \'%s\' with %s", match(self.getline(), self.begin . from . self.trail), self.begin . from . self.trail))
        if match(self.getline(), self.begin . from . self.trail) > -1
            call setline(self.line(), substitute(self.getline(), self.begin . from, to, ''))
        endif
    endfu
    fu! statustoggler.status_indicator()
        let togglepattern = substitute(self.toggleset[0], ".", "[^\\\\\\\\s]", "g")
        call self.debug(printf("togglepattern: %s", togglepattern))
        let indicator = matchstr(self.getline(), self.begin . togglepattern)
        call self.debug(printf("line: %s, begin: %s, pattern: %s", self.getline(), self.begin, togglepattern))
        return indicator
    endfu
    fu! statustoggler._nexttoggle()
        let indicator = self.status_indicator()
        if len(self.toggleset) == 1
           call self._setstatus(indicator, self.toggleset[0])
           return 0
        end
        let matchpos = match(self.toggleset, indicator)
        if matchpos == -1
            echo "No toggle match."
        elseif matchpos > 0
            call self._rotate_toggleset(matchpos)
        end
        return 1
    endfu
    fu! statustoggler._rotate_toggleset(matchpos)
        let swap = remove(self.toggleset, 0, a:matchpos - 1)
        call extend(self.toggleset, swap)
    endfu

    fu! statustoggler.decorate(...)
        if len(a:000) > 0
          let self.custom_line = a:000[0]
        end
        " prevent multiple-decoration
        let l:enclosing_project = "" " detect this
        if l:enclosing_project != "" | let l:enclosing_project .= ": " | end
        let l:itemnostatus = substitute(self.getline(), '^\s*\(.\) ', '', '')
        let l:result = printf("%s [%s] %s%s", self.status_indicator(), timestamp#text('short'), l:enclosing_project, l:itemnostatus)
        call setline(self.line(), l:result)
    endfu

    return copy(statustoggler)
endfunction

" }}}
" }}}

"}}} LineMutator Objects

" Internal Maintenance " {{{
function! s:RemoveScriptSymbol(symbol)
    exec "let l:symbol_existence = exists(\":" . a:symbol . "\") \| if l:symbol_existence == 2 \| delcommand " . a:symbol . " \| endif"
    exec "if exists(\"*" . a:symbol . "\") \| delfunction " . a:symbol . " \| endif"
    " TODO: try to unmap maps, too?
endfunction

" }}}
" Debug " {{{

" let s:debug_mode = 1
if !exists("s:debug_mode")
    if exists("g:loaded_vimple_utilities") || &cp
       finish
    endif

    let g:loaded_vimple_utilities = 1
else
    echo "Debug mode enabled."
    call s:RemoveScriptSymbol("OpenFileFromScriptnames")
    call s:RemoveScriptSymbol("OpenFileFromScriptnames")
    call s:RemoveScriptSymbol("<SID>OpenFileFromScriptnames")
    unlet s:debug_mode
endif

python << BLOCKCOMMENT
""" Work in progress...

noremap <unique> <script> <Plug>OpenFileFromScriptnames <SID>OpenFileFromScriptnames

noremap <SID>OpenFileFromScriptnames :call OpenFileFromScriptnames()<CR>

"""
BLOCKCOMMENT

" }}}


" EXPERIMENTAL: " {{{
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

" vim: fdm=marker fdl=0 cms=\ "\ %s
