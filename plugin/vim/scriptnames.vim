" Scriptnames object
" ARB

" NOTE: Uses vimple#redir, vimple#associate and vimple#format

function! Scriptnames()
  let sn = {}
  let sn.scripts = {}

  func sn.filter(...)
    let l:sn = vimple#redir#redir('scriptnames')
    let l:pat = '.'
    if a:0
      let l:pat = a:1
    endif
    let self.scripts = vimple#associate#associate(filter(l:sn, 'v:val =~ "'.l:pat.'"'),
          \ '^\s*\(\d\+\):\s*\(.*\)$',
          \ '\1,\2',
          \ '{"number": v:val[0], "script": v:val[1]}')
    " TODO: add an arg that controls splatting the list out to a dict keyed on
    " list index (as required by BufferList but not required by Scriptnames)
    return self
  endfunc

  func sn.to_s(...) dict
    let default = "%3n %s\n"
    let format = default
    let scripts = self.scripts
    let str = ''
    for i in range(0, len(scripts) - 1)
      let str .= vimple#format#format(
            \ format,
            \ { 'n': ['d', scripts[i]['number']],
            \   's': ['s', scripts[i]['script']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  return sn.filter()
endfunction

let sn = Scriptnames()
"echo sn.filter('vimple').scripts
"echo sn.filter('vimpeg')
"echo sn.filter('vimple').to_s()
