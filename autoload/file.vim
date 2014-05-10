function! file#read(file)
  return filereadable(a:file) ? readfile(a:file) : []
endfunction
