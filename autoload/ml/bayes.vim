function! s:as_category(category)
  return toupper(substitute(a:category, '_', ' ', 'g'))
endfunction

function! s:sort_numerically(a, b)
  return (a:a[1] - a:b[1]) > 0
endfunction

" function! s:beyes_base()

"   return obj
" endfunction

function! ml#beyes#new(category, ...)
  " let obj = s:beyes_base()

  let obj            = {}
  let obj.categories = {}
  let obj.words      = 0
  let obj.counts     = {}
  let obj.word_count = {}

  func obj.add_category(category)
    let arg_type = type(a:category)
    if arg_type == type({})
      call extend(self.categories, a:category)
    elseif arg_type == type([])
      for c in a:category
        call self.add_category(c)
      endfor
    elseif arg_type == type('') || type(0) || type(0.0)
      let self.categories[s:as_category(a:category)] = {}
    else
      echoerr 'ml#beyes#add_category Error: Unable to handle argument type ' . type(a:category) . ' for argument ' . string(a:category)
    endif
  endfunc

  func obj.train(category, text)
    let category = s:as_category(a:category)
    let self.word_count[category] = get(self.word_count, category, 0)
    let self.counts[category] = get(self.counts, category, 0) + 1
    for [word, cnt] in items(string#words(a:text))
      let self.categories[category][word]   =  get(self.categories[category], word, 0) + cnt
      let self.word_count[category]        +=  cnt
      let self.words                       +=  cnt
    endfor
    return self
  endfunc

  " Returns the scores in each category of the provided `text`, eg:
  "   {"Uninteresting" : -12.6997928013932, "Interesting" : -18.4206807439524}
  " The score closest to 0 is the one picked out by classify()
  func obj.classifications(text)
    let scores = {}
    let training_count = 0.0
    for cnt in values(self.counts)
      let training_count += cnt
    endfor
    for [category, words] in items(self.categories)
      let scores[category] = 0
      let total = get(self.word_count, category, 1) * 1.0
      for [word, cnt] in items(string#words(a:text))
        let scores[category] += log(get(words, word, 0.1) / total)
      endfor
      " add in prior probability for the category
      let scores[category] += log(get(self.counts, category, 0.1) / training_count)
    endfor
    return scores
  endfunc

  func obj.classify(text)
    " return sort(items(self.classifications(a:text)), 's:sort_numerically')
    return sort(items(self.classifications(a:text)), 's:sort_numerically')[0][0]
  endfunc


  call obj.add_category(a:category)
  if a:0
    for c in a:000
      call obj.add_category(c)
    endfor
  endif

  return obj
endfunction

" let b = ml#beyes#new('yes', 'no')
" call b.train('yes', 'this is something good')
" call b.train('no', 'this is something bad and full of hate')
" echo b.classifications('something to hate you with')
" echo b.classify('something to hate you with')
