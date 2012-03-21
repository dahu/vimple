" Scriptnames object
" ARB

function! vimple#scriptnames#new()
  let sn = {}
  let sn.__scripts = {}
  let sn.__filter = ''

  func sn.update() dict abort
    let self.__scripts = vimple#associate(vimple#redir('scriptnames'),
          \ [['^\s*\(\d\+\):\s*\(.*\)$',
          \ '\1,\2', '']],
          \ ['split(v:val, ",")', '{"number": v:val[0], "script": v:val[1]}'])
    return self
  endfunc

  func sn.to_s(...) dict
    let default = "%3n %s\n"
    "let format = default
    let format = a:0 && a:1 != '' ? a:1 : default
    let scripts = a:0 > 1 ? a:2.__scripts : self.__scripts
    let str = ''
    for i in range(0, len(scripts) - 1)
      let str .= vimple#format(
            \ format,
            \ { 'n': ['d', scripts[i]['number']],
            \   's': ['s', scripts[i]['script']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " only able to colour print the default to_s() output at this stage
  " Note: This is a LOT of dancing just to get coloured numbers ;)
  func sn.print() dict
    call self.update()
    call map(map(map(split(self.to_s(), '\n'), 'split(v:val, "\\d\\@<= ")'), '[["vimple_SN_Number", v:val[0]] , ["vimple_SN_Term", " : " . v:val[1] . "\n"]]'), 'vimple#echoc(v:val)')
  endfunc

  func sn.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__scripts, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func sn.filter_by_name(name) dict abort
    return self.filter('v:val["script"] =~ "' . escape(a:name, '"') . '"')
  endfunc

  call sn.update()
  return sn
endfunction
