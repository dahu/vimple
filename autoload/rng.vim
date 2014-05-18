" George Marsaglia's Multiply-with-carry Random Number Generator
" Modified to work within Vim's semantics
let s:m_w = 1 + getpid()
let s:m_z = localtime()

" not sure of the wisdom of generating a full 32-bit RN here
" and then using abs() on the sucker. Feedback welcome.
function! rng#rand(...)
  if a:0 == 0
    let s:m_z = (36969 * and(s:m_z, 0xffff)) + (s:m_z / 65536)
    let s:m_w = (18000 * and(s:m_w, 0xffff)) + (s:m_w / 65536)
    return (s:m_z * 65536) + s:m_w      " 32-bit result
  elseif a:0 == 1 " We return a number in [0, a:1] or [a:1, 0]
    return a:1 < 0 ? rng#rand(a:1,0) : rng#rand(0,a:1)
  else " if a:0 >= 2
    return abs(rng#rand()) % (abs(a:2 - a:1) + 1) + a:1
  endif
endfunction
