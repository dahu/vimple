function! vimloo#class(name, ...) abort
  if a:0
    try
      let dict = deepcopy({a:1})
    catch /^Vim\%((\a\+)\)\=:E121/	" catch error E121
      echohl ErrorMsg
      echom 'VimLOO: Could not create "'.a:name.'" because "'.a:1.'" was not found.'
      echohl None
      return []
    endtry
  else
      let dict = deepcopy(g:vimloo#Object)
  endif
  "Update lineage
  "call dict.super(dict.class())
  "call dict.class(a:name)
  call dict.lineage(a:name)
  return dict
endfunction

" The first class
let g:vimloo#Object = {}
let g:vimloo#Object.private = {}
"let g:vimloo#Object.private.class = 'vimloo#Object'
"let g:vimloo#Object.private.super = 'vimloo#Object'
let g:vimloo#Object.private.lineage = ['vimloo#Object']

function! g:vimloo#Object.init(...) dict abort
  if self.class() == 'vimloo#Object'
    return 1
  endif
  return call({'g:'.self.super()}.init(), a:000, self) == 1
endfunction

function! g:vimloo#Object.class() dict abort
  return self.lineage()[-1]
endfunction

function! g:vimloo#Object.super() dict abort
  let lineage = self.lineage()
  if len(lineage) > 1
    return lineage[-2]
  endif
  return lineage[-1]
endfunction

function! g:vimloo#Object.accessor(name,...) dict abort
  if a:0 && type(a:1) == type(function('type'))
    let self[a:name] = a:1
    return 1
  elseif a:0 && type(a:1) == type('')
    let var_path = a:1
  else
    let var_path = 'private.'.a:name
  endif

  " Is this necessary? or even good?
  "if !exists(self[var_path])
  "  echohl Error
  "  echom 'Could not create the accessor "'.a:name.'()" because the associated property "'.var_path.'" does not exists.'
  "  echohl None
  "  return 0
  "endif

  let dict = {}
  let func_lines = [
        \ 'function! dict.accessor(...) dict abort',
        \ '  if a:0',
        \ '    let self.'.var_path.' = a:1',
        \ '  endif',
        \ '  return self.'.var_path,
        \ 'endfunction'
        \]
  exec join(func_lines, "\n")
  let self[a:name] = dict.accessor
  return 1
endfunction

function! g:vimloo#Object.lineage(...) dict abort
  if a:0
    call add(self.private.lineage, a:1)
  endif
  return self.private.lineage
endfunction

function! g:vimloo#Object.new(...) dict
  let obj = deepcopy(self)
  let init = call(obj.init, a:000, obj)
  if type(init) == type(0) && init == 1
    return obj
  endif
  echohl ErrorMsg
  echom 'There was a problem initializing "'.obj.class().'".'
  echohl None
  return {}
endfunction

function! vimloo#Object.is_a(class) dict
  return index(self.lineage(), a:class) > -1
endfunction

function! vimloo#Object.instance_of(class) dict
  return self.lineage()[-1] == a:class
endfunction

function! vimloo#Object.methods(class) dict
  return keys(filter(deepcopy(self), 'type(a:val) == type(function(''tr''))'))
endfunction

" String class
let vimloo#String = vimloo#class('vimloo#String')

function! vimloo#String.init(s) dict
  call {'g:'.self.super()}.init()
  let self.value = a:s
  return 1
endfunction

function! vimloo#String.split(c) dict
  return g:vimloo#List.new(split(self.value, a:c))
endfunction

function! vimloo#String.to_s() dict
  return self.value
endfunction

function! vimloo#String.sub(range) dict
  let obj = deepcopy(self)
  let obj.value = eval('obj.value['.a:range.']')
  return obj
endfunction

" List class
let vimloo#List = vimloo#class('vimloo#List')

function! vimloo#List.init(l) dict
  call {'g:'.self.super()}.init()
  let self.value = a:l
  return 1
endfunction

function! vimloo#List.join(c) dict
  return g:vimloo#String.new(join(self.value, a:c))
endfunction

function! vimloo#List.to_s() dict
  return string(self.value)
endfunction

let vimloo#List.sub = vimloo#String.sub

let s = vimloo#String.new('uno dos tres')
echo s.split(' ').sub(':-2').join(':').to_s()
let s2 = 'uno dos tres'
echo join(split(s2, ' ')[:-2], ':')
finish

let o = vimloo#Object.new()
echo o.lineage()
call o.accessor('test')
echo o.test(1)
echo o.test()
let c = vimloo#class('myself','none')

echom 'Sourced: '.expand('%:p')
