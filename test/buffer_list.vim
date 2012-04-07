call vimtest#StartTap()
call vimtap#Plan(3)
"call vimtap#Diag('Test')
silent! call vimple#redir('set')
call vimtap#Ok(type(vimple#bl.buffers()) == type({}), 'buffers() returns a dict.')
call vimtap#Ok(vimple#bl.to_s() == "  1 %a   \"\" line 1\<NL>", 'Check to_s() output.')
new
call vimple#bl.update()
call vimtap#Ok(len(vimple#bl.to_l()) == 2, 'update() works')
call vimtest#Quit()

