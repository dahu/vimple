let s:script_dir = expand('<sfile>:p:h:h')
let s:script_db = s:script_dir . '/scripts.db'
let s:init_sql = 'create virtual table plugins using fts4 (plugin, file, type, content);'
let s:content_sql = 'insert into plugins values("%s", "%s", "%s", "%s")'

function! scripts#query(sql)
  let sql = 'sqlite3 ' . s:script_db . " '" . a:sql . "'"
  return system(sql)
endfunc

function! scripts#escape(value)
  return substitute(substitute(a:value, '"', '""', 'g'), "'", "'\"'\"'", 'g')
endfunc

function! scripts#init()
  if filereadable(s:script_db)
    call delete(s:script_db)
  endif
  call scripts#query(s:init_sql)
  redir => scripts
  silent scriptnames
  redir END
  for s in split(scripts, "\n")
    if s == ""
      continue
    endif
    let file = matchstr(s, '^\s*\d\+:\s*\zs\(.*\)')
    let content = readfile(file)
    let plugin = ''
    if file =~ '/\.\?\(ex\|gvim\|vim\)rc$'
      let type = 'vimrc'
      let plugin = matchstr(file, '/\zs.\+\ze/\.\?\(ex\|gvim\|vim\)rc$')
    elseif file =~ '/autoload/'
      let type = 'autoload'
    elseif file =~ '/after/'
      let type = matchstr(file, '/\zsafter/.\+\ze/[^/]\+$')
    else
      let type = matchstr(file, '.*/\zs.\+\ze/[^/]\+$')
    endif
    if plugin == ''
      let plugin = matchstr(file, '.*/\zs.\+\ze/' . type)
    endif
    echo scripts#query(printf(s:content_sql, scripts#escape(plugin), scripts#escape(file), scripts#escape(type), scripts#escape(join(content, "\n"))))
  endfor
endfunction

command! ScriptMatch echo scripts#query('select file from plugins where content match "' . scripts#escape(<q-args>) . '"')
