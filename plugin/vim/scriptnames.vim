
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
          \ '{"number": v:val[0], "name": v:val[1]}')
    return self
  endfunc

  func sn.to_s(...)
    let args_d = {
          \ 'n': "buffers[key]['number']",
          \ 's': "buffers[key]['name']"}
    "let str = To_s(self.scripts, args_d, format_s)
    return self.scripts
  endfunc

  return sn
endfunction

let sn = Scriptnames()
echo sn.filter('vimple').to_s()
