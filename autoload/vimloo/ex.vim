" Ex output class
let e = vimloo#class('vimloo#ex#ExOutput')

function! e.new(cmd) dict abort
  let dict = deepcopy(self)
  let dict.private.cmd = a:cmd
  call dict.accessor('cmd')
  return dict
endfunction

function! e.fetch() dict abort
  redir => output
  silent exec self.cmd()
  redir END
  return split(output,'\n')
endfunction

" Ex output class
let e = vimloo#class('ExOutput')

function! e.new(cmd) dict abort
  let dict = deepcopy(self)
  let dict.private.cmd = a:cmd
  call dict.accessor('cmd')
  return dict
endfunction

function! e.fetch() dict abort
  redir => output
  silent exec self.cmd()
  redir END
  return split(output,'\n')
endfunction

" Ex output class
let e = vimloo#class('ExOutput')

function! e.new(cmd) dict abort
  let dict = deepcopy(self)
  let dict.private.cmd = a:cmd
  call dict.accessor('cmd')
  return dict
endfunction

function! e.fetch() dict abort
  redir => output
  silent exec self.cmd()
  redir END
  return split(output,'\n')
endfunction

echom 'Sourced: '.expand('%:p')
