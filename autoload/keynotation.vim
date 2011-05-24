"
" Enter vim key-notation in a sparkup-y way.
"
if exists('g:keynotation_invoke')
    exec "imap " . g:keynotation_invoke . " <Esc>:call keynotation#parse()<CR>"
end

let g:keynotation_sentinel_list = [";", ">"]
function! keynotation#parse() " {{{
    exe "set undolevels=" . &undolevels
    let original_position = getpos(".")
    let scan = keynotation#scan_for_notation()
    let parsed_notation = keynotation#parse_raw_notation(scan['output'])
    let sentinel = scan['sentinel']
    let modifier = 0
    if sentinel == ">"
        let sentinel = ""
        let modifier = 1
    end
    let start_column = '\%' . (original_position[2] - len(scan['output']) + modifier) . "c"
    let new_line = substitute(getline("."), start_column . sentinel . scan['output'], parsed_notation, "")
    let g:debugout = start_column . sentinel . scan['output']
    call setline(line("."), new_line)
    let new_position = original_position
    let new_position[2] = strridx(new_line, parsed_notation) + len(parsed_notation)
    call setpos(".", new_position)
endfunction

"}}}
function! keynotation#scan_for_notation() " {{{
    let current_position = col(".")

    for sentinel in g:keynotation_sentinel_list
        let sentinel_position = strridx(getline("."), sentinel, current_position)
        if sentinel_position > -1
            break
        end
    endfor
    if sentinel_position == -1
        return { 'sentinel': '', 'output': '' }
    else
        return { 'sentinel': sentinel, 'output': strpart(getline("."), sentinel_position + 1, current_position - sentinel_position) }
    end
endfunction

"}}}

function! keynotation#tree(input) " {{{
    let s:obj = {}

    fun s:obj.elements() dict
        return self['elements']
    endfun

    fun s:obj.state() dict
        return self['state']
    endfun

    fun s:obj.position() dict
        return self['position']
    endfun

    fun s:obj.value() dict
        try
            let result = self['elements'][self['position']]
        catch /E684/
            let result = ''
        endtry
        return result
    endfun

    fun s:obj.peek() dict
        try
            let result = self['elements'][self['position'] + 1]
        catch /E684/
            let result = ''
        endtry
        return result
    endfun

    fun s:obj.shift() dict
        let self['position'] += 1
        return self['position'] < len(self['elements'])
    endfun

    fun s:obj.lookup(token) dict
        let token = a:token
        let lookup_table = {
                    \ 1: {
                    \ ' '  :   [ "<Space>"    , 1 ],
                    \ 'a'  :   [ "<A-"        , 0 ],
                    \ 'c'  :   [ "<C-"        , 0 ],
                    \ 'd'  :   [ "<D-"        , 0 ],
                    \ 'e'  :   [ "<Esc>"      , 1 ],
                    \ 'en' :   [ "<End>"      , 1 ],
                    \ 'h'  :   [ "<Left>"     , 1 ],
                    \ 'ho' :   [ "<Home>"     , 1 ],
                    \ 'j'  :   [ "<Down>"     , 1 ],
                    \ 'k'  :   [ "<Up>"       , 1 ],
                    \ 'l'  :   [ "<Right>"    , 1 ],
                    \ 'le' :   [ "<Leader>"   , 1 ],
                    \ 'lt' :   [ "<lt>"       , 1 ],
                    \ 'm'  :   [ "<M-"        , 0 ],
                    \ 'pd' :   [ "<PageDown>" , 1 ],
                    \ 'pu' :   [ "<PageUp>"   , 1 ],
                    \ 'r'  :   [ "<CR>"       , 1 ],
                    \ 's'  :   [ "<S-"        , 0 ],
                    \ 'sp' :   [ "<Space>"    , 1 ],
                    \ 't'  :   [ "<Tab>"      , 1 ],
                    \ },
                    \ 0: {
                    \ 'a'  :   [ "A-"        , 0 ],
                    \ 'c'  :   [ "C-"        , 0 ],
                    \ 'd'  :   [ "D-"        , 0 ],
                    \ 'h'  :   [ "h"         , 1 ],
                    \ 'l'  :   [ "l"         , 1 ],
                    \ 'm'  :   [ "M-"        , 0 ],
                    \ 'pd' :   [ "PageDown"  , 1 ],
                    \ 'pu' :   [ "PageUp"    , 1 ],
                    \ 'r'  :   [ "r"         , 1 ],
                    \ 's'  :   [ "S-"        , 0 ],
                    \ }
                    \ }
        try
            let result = lookup_table[token[0]][token[1]]
        catch 
            let result = ''
        endtry
        return result
    endfun

    fun s:obj.resolve(token) dict
        let token = a:token
        let result = ''
        if self.beginning()
            let lookup = self.lookup(token)
            if lookup[0] == ''
                let newtoken = [token[0], join([token[1], self.peek()], "")]
                let newlookup = self.lookup(newtoken)
                if newlookup[0] == ''
                    let result .= "<"
                    let result .= toupper(newtoken[1])
                else
                    let result .= newlookup[0]
                    call self.shift()
                endif
            else
                let result .= lookup[0]
                let self['state'] = lookup[1]
            end
        else
            let lookup = self.lookup(token)
            if lookup[0] == ''
                let newtoken = [0, join([token[1], self.peek()], "")]
                let newlookup = self.lookup(newtoken)
                if newlookup[0] == ''
                    let result .= tolower(newtoken[1])
                else
                    let result .= newlookup[0]
                    call self.shift()
                endif
                call self.out()
                let result .= ">"
            else
                let result .= lookup[0]
                let self['state'] = lookup[1]
                if lookup[1]
                    let result .= ">"
                end
            end
        end
        return result
    endfun

    fun s:obj.push(value) dict
        let self['output'] = extend(self['output'], [a:value])
    endfun

    fun s:obj.parse() dict
        let token = [self['state'], self.value()]
        let result = self.resolve(token)
        call self.push(result)
    endfun

    fun s:obj.in() dict
        let self['state'] = 0
    endfun

    fun s:obj.out() dict
        let self['state'] = 1
    endfun

    fun s:obj.beginning() dict
        return self['state']
    endfun

    fun s:obj.result() dict
        return join(self['output'],"")
    endfun

    " constructor
    fun s:obj.New(input) dict
        let newobj = copy(self)
        let raw_input = tolower(a:input)
        let newobj['elements'] = split(raw_input, '\zs')
        let newobj['state'] = 1
        let newobj['position'] = -1
        let newobj['output'] = []
        return newobj
    endfun

    return s:obj.New(a:input)
endfunction

" }}}

function! keynotation#parse_raw_notation(input) " {{{
    let tree = keynotation#tree(a:input)
    while tree.shift()
        call tree.parse()
    endwhile
    return tree.result()
endfunction

" }}}
