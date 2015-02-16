syn match VJL_X        /^.\s*0\s\+/  conceal contained
syn match VJL_L        /^l \d\+\s\+/ conceal contained
syn match VJL_F        /^f \d\+\s\+/ conceal contained

syn match VJL_TextLine /^l.*/        contains=VJL_L
syn match VJL_FileLine /^f.*/        contains=VJL_F
syn match VJL_CurrLine /^.\s*0.*/    contains=VJL_X

hi link VJL_CurrLine Constant
hi link VJL_TextLine String
hi link VJL_FileLine Comment
