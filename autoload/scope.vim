function! scope#pair(head, tail)
  let obj = {}
  let obj.head = a:head
  let obj.tail = a:tail
  let obj.head_line_number = obj.head[0]
  let obj.tail_line_number = obj.tail[0]

  if len(obj.head[1]) == 0
    let obj.head_string = ''
  elseif join(obj.head[1][1:]) == ''
    let obj.head_string = obj.head[1][0]
  else
    let obj.head_string = string#trim(join(obj.head[1][1:], ' '))
  endif

  if len(obj.tail[1]) == 0
    let obj.tail_string = ''
  elseif join(obj.tail[1][1:]) == ''
    let obj.tail_string = obj.tail[1][0]
  else
    let obj.tail_string = join(obj.tail[1][1:], ' ')
  endif

  return obj
endfunction

function! scope#inspect(head_pattern, tail_pattern)
  let obj = {}
  let obj.head_search_pattern  = substitute(a:head_pattern, '\\(', '\\%(', 'g')
  let obj.head_collect_pattern = a:head_pattern
  let obj.tail_search_pattern  = substitute(a:tail_pattern, '\\(', '\\%(', 'g')
  if obj.tail_search_pattern !~ '\\z[es]' && obj.tail_search_pattern !~ '\$$'
    let obj.tail_search_pattern = obj.tail_search_pattern . '\zs'
  endif
  let obj.tail_collect_pattern = a:tail_pattern

  func obj.init()
    let self.stack = []
  endfunc

  func obj.push(head, tail)
    call add(self.stack, scope#pair([a:head, matchlist(getline(a:head), self.head_collect_pattern)], [a:tail, matchlist(getline(a:tail), self.tail_collect_pattern)]))
  endfunc

  func obj.find_outer_tail()
    let self.outer_tail = searchpair(self.head_search_pattern, '', self.tail_search_pattern, 'rcnW')
  endfunc

  func obj.find_outer_head()
    let self.outer_head = searchpair(self.head_search_pattern, '', self.tail_search_pattern, 'rbcnW')
  endfunc

  func obj.find_current_head()
    let self.current_head = searchpair(self.head_search_pattern, '', self.tail_search_pattern, 'bW')
  endfunc

  func obj.find_current_tail()
    let self.current_tail = searchpair(self.head_search_pattern, '', self.tail_search_pattern, 'nW')
  endfunc

  func obj.scope()
    let self.stack = reverse(list#lrotate(self.stack))
    return self
  endfunc

  func obj.get_scope()
    call self.init()
    call self.find_outer_tail()
    if self.outer_tail == 0
      return self
    endif

    let cur_pos = getpos('.')

    call self.find_outer_head()
    if self.outer_head == 0
      return self
    endif
    call self.push(self.outer_head, self.outer_tail)
    call self.find_current_head()
    while self.current_head > self.outer_head
      call self.find_current_tail()
      call self.push(self.current_head, self.current_tail)
      call self.find_current_head()
    endwhile

    call setpos('.', cur_pos)
    return self.scope()
  endfunction

  return obj.get_scope()
endfunction
