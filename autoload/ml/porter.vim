" Porter stemmer in VimL.
"
" Taken from:
" http://burakkanber.com/blog/machine-learning-full-text-search-in-javascript-relevance-scoring/
" Which referenced:
"  Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
"  no. 3, pp 130-137,
"
" see also http://www.tartarus.org/~martin/PorterStemmer

let s:step2list = {
      \  "ational" : "ate"
      \, "tional"  : "tion"
      \, "enci"    : "ence"
      \, "anci"    : "ance"
      \, "izer"    : "ize"
      \, "bli"     : "ble"
      \, "alli"    : "al"
      \, "entli"   : "ent"
      \, "eli"     : "e"
      \, "ousli"   : "ous"
      \, "ization" : "ize"
      \, "ation"   : "ate"
      \, "ator"    : "ate"
      \, "alism"   : "al"
      \, "iveness" : "ive"
      \, "fulness" : "ful"
      \, "ousness" : "ous"
      \, "aliti"   : "al"
      \, "iviti"   : "ive"
      \, "biliti"  : "ble"
      \, "logi"    : "log"
      \}

let s:step3list = {
      \  "icate" : "ic"
      \, "ative" : ""
      \, "alize" : "al"
      \, "iciti" : "ic"
      \, "ical"  : "ic"
      \, "ful"   : ""
      \, "ness"  : ""
      \}

let s:c = "[^aeiou]"          " consonant
let s:v = "[aeiouy]"          " vowel
let s:C = s:c . "[^aeiouy]*"    " consonant sequence
let s:V = s:v . "[aeiou]*"      " vowel sequence

let s:mgr0 = '^\(' . s:C . '\)\?' . s:V . s:C                        " [C]VC... is m>0
let s:meq1 = '^\(' . s:C . '\)\?' . s:V . s:C . '\(' . s:V . '\)\?$' " [C]VC[V] is m=1
let s:mgr1 = '^\(' . s:C . '\)\?' . s:V . s:C . s:V . s:C            " [C]VCVC... is m>1
let s:s_v  = '^\(' . s:C . '\)\?' . s:v                              " vowel in stem

function! s:p(s)
  return
  echom string(a:s)
endfunction

function! ml#porter#stemmer(w)
  let w = a:w

  if len(w) < 3
    return w
  endif

  let firstch = w[0]
  if firstch == 'y'
    let w = 'Y' . w[1:]
  endif

  " Step 1a
  let re  = '^\(.\{-}\)\(ss\|i\)es$'
  let re2 = '^\(.\{-}\)\([^s]\)s$'

  if w =~ re
    let w = substitute(w, re, '\1\2', '')
  elseif w =~ re2
    let w = substitute(w, re2, '\1\2', '')
  endif

  call s:p(w)

  " Step 1b
  let re  = '^\(.\{-}\)eed$'
  let re2 = '^\(.\{-}\)\(ed\|ing\)$'

  if w =~ re
    let fp = matchlist(w, re)
    let re = s:mgr0
    if fp[1] =~ re
      let re = '.$'
      let w = substitute(w, re, '', '')
    endif
  elseif w =~ re2
    let fp = matchlist(w, re2)
    let stem = fp[1]
    let re2 = s:s_v
    if stem =~ re2
      let w = stem
      let re2 = '\(at\|bl\|iz\)$'
      let re3 = '\([^aeiouylsz]\)\1$'
      let re4 = '^' . s:C . s:v . '[^aeiouwxy]$'
      if w =~ re2
        let w = w . 'e'
      elseif w =~ re3
        let re = '.$'
        let w = substitute(w, re, '', '')
      elseif w =~ re4
        let w = w . 'e'
      endif
    endif
  endif

  " Step 1c
  let re = '^\(.\{-}\)y$'
  if w =~ re
    let fp = matchlist(w, re)
    let stem = fp[1]
    let re = s:s_v
    if stem =~ re
      let w = stem . 'i'
    endif
  endif

  " Step 2
  let re = '^\(.\{-}\)\(ational\|tional\|enci\|anci\|izer\|bli\|alli\|entli\|eli\|ousli\|ization\|ation\|ator\|alism\|iveness\|fulness\|ousness\|aliti\|iviti\|biliti\|logi\)$'
  if w =~ re
    let fp = matchlist(w, re)
    let stem = fp[1]
    let suffix = fp[2]
    let re = s:mgr0
    if stem =~ re
      let w = stem . s:step2list[suffix]
    endif
  endif

  " Step 3
  let re = '^\(.\{-}\)\(icate\|ative\|alize\|iciti\|ical\|ful\|ness\)$'
  if w =~ re
    let fp = matchlist(w, re)
    let stem = fp[1]
    let suffix = fp[2]
    let re = s:mgr0
    if stem =~ re
      let w = stem . s:step3list[suffix]
    endif
  endif

  " Step 4
  let re  = '^\(.\{-}\)\(al\|ance\|ence\|er\|ic\|able\|ible\|ant\|ement\|ment\|ent\|ou\|ism\|ate\|iti\|ous\|ive\|ize\)$'
  let re2 = '^\(.\{-}\)\(s\|t\)\(ion\)$'
  if w =~ re
    let fp = matchlist(w, re)
    let stem = fp[1]
    let re = s:mgr1
    if stem =~ re
      let w = stem
    endif
  elseif w =~ re2
    let fp = matchlist(w, re2)
    let stem = fp[1] . fp[2]
    let re2 = s:mgr1
    if stem =~ re2
      let w = stem
    endif
  endif

  " Step 5
  let re = '^\(.\{-}\)e$'
  if w =~ re
    let fp = matchlist(w, re)
    let stem = fp[1]
    let re  = s:mgr1
    let re2 = s:meq1
    let re3 = '^' . s:C . s:v . '[^aeiouwxy]$'
    if (stem =~ re || stem =~ re2) && stem !~ re3
      let w = stem
    endif
  endif

  let re  = 'll$'
  let re2 = s:mgr1
  if w =~ re && w =~ re2
    let re = '.$'
    let w = substitute(w, re, '', '')
  endif

  " and turn initial Y back to y

  if firstch == 'y'
    let w = 'y' . w[1:]
  endif

  return w
endfunction
