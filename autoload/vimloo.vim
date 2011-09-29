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
  echo lineage
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


finish
let o = vimloo#Object.new()
echo o.lineage()
call o.accessor('test')
echo o.test(1)
echo o.test()
let c = vimloo#class('myself','none')

echom 'Sourced: '.expand('%:p')
