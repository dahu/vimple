" Scriptnames object
" ARB

" NOTE: Uses the Redir, Associate and To_s library functions

function! Scriptnames()
  let sn = {}
  let sn.scripts = {}

  func sn.filter(...)
    let l:sn = Redir('scriptnames')
    let l:pat = '.'
    if a:0
      let l:pat = a:1
    endif
    let self.scripts = Associate(filter(l:sn, 'v:val =~ "'.l:pat.'"'),
          \ '^\s*\(\d\+\):\s*\(.*\)$',
          \ '\1,\2',
          \ '{"number": v:val[0], "script": v:val[1]}')
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

  return sn
endfunction

let sn = Scriptnames()
"echo sn.filter('vimple').scripts
"echo sn.filter('vimpeg')
echo sn.filter('vimple').to_s()
