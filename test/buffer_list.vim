call vimtest#StartTap()
call vimtap#Plan(6) " <== XXX  Keep plan number updated.  XXX

" silent! call vimple#redir('set')
call Is(type(vimple#bl.buffers()), type({}), 'buffers() returns a dict')
call vimtap#Diag(vimple#bl.to_s())
call Ok(vimple#bl.to_s() =~ '^  1 %a\?\s\+".\{-}" line 1', 'Check to_s() output')

let blist = vimple#bl.to_l()
call Ok(len(blist) == 1, 'Check to_l() output.:'.string(blist).':')
call Ok(has_key(blist[0], 'number') == 1, 'Check to_l() content.:'.string(blist).':')
call Ok(blist[0]['number'] == 1, 'Check to_l() buffer number.:'.string(blist).':')

new
call vimple#bl.update()
call Ok(len(vimple#bl.to_l()) == 2, 'update() works')

call vimtest#Quit()

