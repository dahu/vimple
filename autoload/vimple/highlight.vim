" Highlight object
" ARB

function! vimple#highlight#new()
  let hl = {}
  let hl.__data = {}
  let hl.__filter = ''

  func hl.update() dict abort
    let self.__data = vimple#associate(vimple#join(vimple#redir('highlight'), '^\s\+'),
          \ [['^\(\S\+\)\s*\S\+\s*\(.*\)$', '\1,\2', '']],
          \ ['split(v:val, ",")',
          \  '{"term": v:val[0],'
          \.  '"attrs": substitute(v:val[1], "\\s\\+", " ", "g")}'])
    return self
  endfunc

  " takes two optional arguments:
  " 1 : format
  " 2 : data
  func hl.to_s(...) dict
    let default = "%t %a\n"
    let format = a:0 && a:1 != '' ? a:1 : default
    let data = a:0 > 1 ? a:2.__data : self.__data
    let str = ''
    let data = sort(data, 'vimple#comparators#termly')
    for i in range(0, len(data) - 1)
      let str .= vimple#format(
            \ format,
            \ { 't': ['s', data[i]['term']],
            \   'a': ['s', data[i]['attrs']]},
            \ default
            \ )
    endfor
    return str
  endfunc

  " only able to colour print the default to_s() output at this stage
  func hl.print() dict
    let str = self.to_s()
    let dta = map(split(str, "\n"), '[split(v:val, " ")[0], v:val . "\n"]')
    call vimple#echoc(dta)
  endfunc

  func hl.filter(filter) dict abort
    let dict = deepcopy(self)
    call filter(dict.__data, a:filter)
    let dict.__filter .= (dict.__filter == '' ? '' : ' && ').a:filter
    return dict
  endfunc

  func hl.filter_by_term(term) dict abort
    return self.filter('v:val["term"] =~ "' . escape(a:term, '"') . '"')
  endfunc

  func hl.sort()
    return sort(self.__data, vimple#comparators#termly)
  endfunc

  call hl.update()
  return hl
endfunction