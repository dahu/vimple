call vimtest#StartTap()
call vimtap#Plan(2) " <== XXX  Keep plan number updated.  XXX
"call vimtap#Diag('Test')
redir => test
set filetype?
redir END
let result = vimple#redir('set filetype?')
call vimtap#Ok(split(test, '\n') == result,
      \ 'Check #redir() :'
      \ . string(split(test, '\n'))
      \ . ' == '
      \ . string(result)
      \ . ':')
unlet test
unlet result

let test = '   12.35'
let result = vimple#format('%8.2l', {'l': ['f', '12.3456']}, '')
call vimtap#Ok(test == result,
      \ 'Check #format() :'
      \ . test
      \ . ' == '
      \ . result
      \ . ':')
unlet test
unlet result

call vimtest#Quit()

