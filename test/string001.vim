call vimtest#StartTap()
call vimtap#Plan(7) " <== XXX  Keep plan number updated.  XXX

let s = 'this  is a string'
let S = string#scanner(s)

call Is(S.skip('\w\+')   , 4   , 'skips a word')
call Is(S.skip('\s\+')   , 6   , 'skips a space')
call Is(S.skip('\s\+')   , -1  , '"fail" if pattern to skip not found')
call Is(S.skip('\w\+')   , 8   , 'skips another word')
call Is(S.scan('\w\+')   , ''  , 'no word to scan here')
call Is(S.index          , 8   , 'index unchanged from unsuccessful scan')
call Is(S.skip('\d\+')   , -1  , 'no digits to skip')
call Isnt(S.skip('\s\+') , -1  , 'skip over whitespace')
call Is(S.scan('\w\+')   , 'a' , 'get next word')

let s = 'this  is a string'
let S = string#scanner(s)

call Is(S.skip('\_s\+')  , -1     , 'no leading whitespace to skip')
call Is(S.scan('\w\+')   , 'this' , 'scan "this"')
call Isnt(S.skip('\s\+') , -1     , 'skip whitespace')
call Is(S.scan('\w\+')   , 'is'   , 'scan "is"')
call Isnt(S.skip('\s\+') , -1     , 'skip whitespace')

let s = 'this is a string'
let S = string#scanner(s)

call Is(S.skip_until('string') , 10       , 'skips until a target')
call Is(S.scan('\w\+')         , 'string' , 'scan collects the pattern match')

call vimtest#Quit()
