function! parse#ini#from_file(file)
  let file = a:file
  if ! filereadable(file)
    throw "E484: Can't open file " . file
  endif
  return parse#ini#from_string(join(readfile(file), "\n"))
endfunction

function! parse#ini#from_string(string)
  let scanner = string#scanner(a:string)
  let data = {}
  let current_section = data

  while ! scanner.eos()
    call scanner.skip('\_s\+')
    if scanner.scan(';') != ""
      call scanner.skip_until('[\r\n]\+')
    elseif scanner.scan('\[\([^\]]\+\)\]') != ""
      let section_name = scanner.matches[1]
      let data[section_name] = {}
      let current_section = data[section_name]
    elseif scanner.scan('\([^=]\+\)\s*=\s*\(\%([\r\n]\@!.\)*\)') != ""
      let current_section[string#trim(scanner.matches[1])]
            \ = string#eval((scanner.matches[2]))
    endif
  endwhile

  return data
endfunction

function! parse#ini#to_file(hash, file)
  call writefile(split(parse#ini#to_string(a:hash), "\n"), a:file)
endfunction

function! parse#ini#to_string(hash)
  let hash = a:hash
  let head = ''
  let body = ''
  if type(hash) != type({})
    throw 'Expected Dictionary but given ' . variable#type_to_string(hash)
  endif
  for [section, values] in items(hash)
    if type(values) == type({})
      let body .= '[' . section . "]\n"
      for [name, val] in items(values)
        let body .= name . ' = ' . string#to_string(val) . "\n"
        unlet val
      endfor
    elseif type(values) == type([])
      " what now?!
    else
        let head .= section . ' = ' . string#to_string(values) . "\n"
    endif
    unlet values
  endfor
  return head . body
endfunction

