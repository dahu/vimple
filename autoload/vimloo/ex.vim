" Ex output class
let vimloo#ex#Output = vimloo#class('vimloo#ex#Output')

let vimloo#ex#Output.private.filter = ''

function! vimloo#ex#Output.init(cmd) dict abort
  call {self.super()}.init()
  call self.accessor('command')
  call self.command(a:cmd)
  return 1
endfunction

function! vimloo#ex#Output.fetch() dict abort
  redir => output
  silent exec self.command()
  redir END
  return split(output,'\n')
endfunction

function! vimloo#ex#Output.update() dict abort
  let self.lines = self.fetch()
  if self.private.filter != ''
    call filter(self.lines, self.private.filter)
  endif
  return 1
endfunction

function! vimloo#ex#Output.filter(filter, ...) dict abort
  let bunch = a:0 ? a:1 : self.lines
  let main_filter = self.private.filter
  call filter(bunch, a:filter)
  let self.private.filter .= (main_filter == '' ? '' : ' && ') . a:filter
  return a:0 ? bunch : self
endfunction

finish
silent! unlet e
echo vimloo#ex#Output
debug let e = vimloo#ex#Output.new('scriptnames')
echo e.command()
echo e.fetch()
echom 'Sourced: '.expand('%:p')
