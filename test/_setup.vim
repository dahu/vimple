let &rtp = expand('<sfile>:p:h:h') . ',' . &rtp . ',' . expand('<sfile>:p:h:h') . '/after'

runtime plugin/vimple.vim
runtime plugin/string.vim

function! Ok(test, desc)
  return vimtap#Ok(a:test, '"' . escape(a:test, '"') . '"', a:desc)
endfunction

function! Is(got, expected, desc)
  return vimtap#Is(a:got, a:expected, '"' . escape(a:got, '"') . '"', a:desc)
endfunction

function! Isnt(got, unexpected, desc)
  return vimtap#Isnt(a:got, a:unexpected, '"' . escape(a:got, '"') . '"', a:desc)
endfunction
