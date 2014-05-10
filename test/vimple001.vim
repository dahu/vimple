call vimtest#StartTap()
call vimtap#Plan(2) " <== XXX  Keep plan number updated.  XXX

redir => test
set filetype?
redir END
let result = vimple#redir('set filetype?')
call Is(result, split(test, '\n'), '#redir()')
unlet test
unlet result

let test = '   12.35'
let result = vimple#format('%8.2l', {'l': ['f', '12.3456']}, '')
call Is(result, test, '#format()')
unlet test
unlet result

call vimtest#Quit()
