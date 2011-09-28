let g:vimloo#classes = {}

function! vimloo#new(...) abort
  if a:0 > 1
    let argsl = a:000[1:]
  else
    let argsl = []
  endif
  echo a:000
  echo argsl
  if a:0 && has_key(g:vimloo#classes, a:1)
    return call(g:vimloo#classes[a:1].new, argsl, g:vimloo#classes[a:1])
  else
    return call(g:vimloo#classes.Object.new, argsl, g:vimloo#classes.Object)
  endif
endfunction

function! vimloo#class(name, ...) abort
  if a:0
    if s:init(a:name, a:1)
      return
    endif
    "let dict = deepcopy(g:vimloo#classes[a:1])
    let dict = g:vimloo#classes[a:1]
  else
    "let dict = deepcopy(g:vimloo#classes.Object)
    let dict = g:vimloo#classes.Object
  endif
  let dict.private.super = dict.private.class
  let dict.private.class = a:name
  let g:vimloo#classes[a:name] = dict
  return dict
endfunction

function! s:init(class, super)
  if !has_key(g:vimloo#classes, a:super)
    try
      call call(a:1, [])
    catch /^Vim\%((\a\+)\)\=:E117/
      echohl Error
      echom 'Class "'.a:class.'" has no been found and "'.a:class.'" inherits from it.'
      echohl None
      return 0
    endtry
  endif
  return 1
endfunction


" The first class
let g:vimloo#classes.Object = {}
let g:vimloo#classes.Object.private = {}

let g:vimloo#classes.Object.private.class = 'Object'
let g:vimloo#classes.Object.private.super = 'Object'

function! g:vimloo#classes.Object.class(...) dict abort
  if a:0
    let self.private.class
    call vimloo#class(a:1, self)
  endif
  return self.private.class
endfunction

function! g:vimloo#classes.Object.super() dict abort
  return g:vimloo#classes[self.private.super]
endfunction

function! g:vimloo#classes.Object.accessor(name,...) dict abort
  if a:0 && type(a:1) == type(function('type'))
    let self[a:name] = a:1
    return 1
  elseif a:0 && type(a:1) == type('')
    let path = a:1
  else
    let path = 'private.'.a:name
    let save_reg = @a
    let dict = {}
    let func_lines = [
          \ 'function! dict.accessor(...) dict abort',
          \ '  if a:0',
          \ '    let self.'.path.' = a:1',
          \ '  endif',
          \ '  return self.'.path,
          \ 'endfunction'
          \]
    let @a = join(func_lines, "\<CR>")
    @a
    let self[a:name] = dict.accessor
    let @a = save_reg
  endif
endfunction

function! g:vimloo#classes.Object.lineage() dict abort
  let current = self
  let lineage = []
  while 1
    call insert(lineage, current.class())
    if current.class() == 'Object'
      break
    else
      let current = current.super()
    endif
  endwhile
  return lineage
endfunction

function! g:vimloo#classes.Object.new() dict abort
  return deepcopy(self)
endfunction


"let o = vimloo#new('Object')
"echo o.lineage()
"call o.accessor('test')
"echo o.test(1)
"echo o.test()

echom 'Sourced: '.expand('%:p')
