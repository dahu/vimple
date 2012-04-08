call vimtest#StartTap()
call vimtap#Plan(6) " <== XXX  Keep plan number updated.  XXX
"call vimtap#Diag('Test')
silent! call vimple#redir('set')
call vimtap#Ok(type(vimple#bl.buffers()) == type({}), 'buffers() returns a dict.')
call vimtap#Ok(vimple#bl.to_s() =~ '^  1 %a\?\s\+"" line 1', 'Check to_s() output.:'.vimple#bl.to_s().':')
let blist = vimple#bl.to_l()
call vimtap#Ok(len(blist) == 1, 'Check to_l() output.:'.string(blist).':')
call vimtap#Ok(has_key(blist[0], 'number') == 1, 'Check to_l() content.:'.string(blist).':')
call vimtap#Ok(blist[0]['number'] == 1, 'Check to_l() buffer number.:'.string(blist).':')
new
call vimple#bl.update()
call vimtap#Ok(len(vimple#bl.to_l()) == 2, 'update() works')
call vimtest#Quit()

