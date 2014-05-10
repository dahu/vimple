call vimtest#StartTap()
call vimtap#Plan(2) " <== XXX  Keep plan number updated.  XXX

hi VimpleTestHi term=bold,reverse cterm=bold ctermbg=239 gui=bold guibg=#4e4e4e

call vimple#hl.update()
let result = vimple#hl.filter_by_term('VimpleTestHi').to_l()

call Is(len(result), 1, 'handle commas in highlights')
call Is(result[0]['attrs']
      \, 'term=bold,reverse cterm=bold ctermbg=239 gui=bold guibg=#4e4e4e'
      \, 'handle commas in highlights')

call vimtest#Quit()

