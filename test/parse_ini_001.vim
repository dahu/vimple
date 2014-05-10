call vimtest#StartTap()
call vimtap#Plan(1) " <== XXX  Keep plan number updated.  XXX

let ini_hash = parse#ini#from_file('ini_001.ini')
call parse#ini#to_file(ini_hash, 'ini_001_out.ini')

call Is(parse#ini#from_file('ini_001_out.ini'), ini_hash , 'round-trip')

call vimtest#Quit()
