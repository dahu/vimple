abs( {expr})	"Float or Number	absolute value of {expr}
acos( {expr})	"Float	arc cosine of {expr}
add( {list}, {item})	"List	append {item} to |List| {list}
append( {lnum}, {string})	"Number	append {string} below line {lnum}
append( {lnum}, {list})	"Number	append lines {list} below line {lnum}
argc()	"Number	number of files in the argument list
argidx()	"Number	current index in the argument list
argv( {nr})	"String	{nr} entry of the argument list
argv( )	"List	the argument list
asin( {expr})	"Float	arc sine of {expr}
atan( {expr})	"Float	arc tangent of {expr}
atan2( {expr}, {expr})	"Float	arc tangent of {expr1} / {expr2}
browse( {save}, {title}, {initdir}, {default})	"String	put up a file requester
browsedir( {title}, {initdir})	"String	put up a directory requester
bufexists( {expr})	"Number	TRUE if buffer {expr} exists
buflisted( {expr})	"Number	TRUE if buffer {expr} is listed
bufloaded( {expr})	"Number	TRUE if buffer {expr} is loaded
bufname( {expr})	"String	Name of the buffer {expr}
bufnr( {expr})	"Number	Number of the buffer {expr}
bufwinnr( {expr})	"Number	window number of buffer {expr}
byte2line( {byte})	"Number	line number at byte count {byte}
byteidx( {expr}, {nr})	"Number	byte index of {nr}'th char in {expr}
call( {func}, {arglist} [, {dict}])	"any	call {func} with arguments {arglist}
ceil( {expr})	"Float	round {expr} up
changenr()	"Number	current change number
char2nr( {expr})	"Number	ASCII value of first char in {expr}
cindent( {lnum})	"Number	C indent for line {lnum}
clearmatches()	"none	clear all matches
col( {expr})	"Number	column nr of cursor or mark
complete( {startcol}, {matches})	"none	set Insert mode completion
complete_add( {expr})	"Number	add completion match
complete_check()	"Number	check for key typed during completion
confirm( {msg} [, {choices} [, {default} [, {type}]]])	"Number	number of choice picked by user
copy( {expr})	"any	make a shallow copy of {expr}
cos( {expr})	"Float	cosine of {expr}
cosh( {expr})	"Float	hyperbolic cosine of {expr}
count( {list}, {expr} [, {start} [, {ic}]])	"Number	 count how many {expr} are in {list}
cscope_connection( [{num} , {dbpath} [, {prepend}]])	"Number	checks existence of cscope connection
cursor( {lnum}, {col} [, {coladd}])	"Number	move cursor to {lnum}, {col}, {coladd}
cursor( {list})	"Number	move cursor to position in {list}
deepcopy( {expr})	"any	make a full copy of {expr}
delete( {fname})	"Number	delete file {fname}
did_filetype()	"Number	TRUE if FileType autocommand event used
diff_filler( {lnum})	"Number	diff filler lines about {lnum}
diff_hlID( {lnum}, {col})	"Number	diff highlighting at {lnum}/{col}
empty( {expr})	"Number	TRUE if {expr} is empty
escape( {string}, {chars})	"String	escape {chars} in {string} with '\'
eval( {string})	"any	evaluate {string} into its value
eventhandler( )	"Number	TRUE if inside an event handler
executable( {expr})	"Number	1 if executable {expr} exists
exists( {expr})	"Number	TRUE if {expr} exists
extend( {expr1}, {expr2} [, {expr3}])	"List/Dict	insert items of {expr2} into {expr1}
exp( {expr})	"Float	exponential of {expr}
expand( {expr} [, {flag}])	"String	expand special keywords in {expr}
feedkeys( {string} [, {mode}])	"Number	add key sequence to typeahead buffer
filereadable( {file})	"Number	TRUE if {file} is a readable file
filewritable( {file})	"Number	TRUE if {file} is a writable file
filter( {expr}, {string})	"List/Dict	remove items from {expr} where {string} is 0
finddir( {name}[, {path}[, {count}]])	"String	find directory {name} in {path}
findfile( {name}[, {path}[, {count}]])	"String	find file {name} in {path}
float2nr( {expr})	"Number	convert Float {expr} to a Number
floor( {expr})	"Float	round {expr} down
fmod( {expr1}, {expr2})	"Float	remainder of {expr1} / {expr2}
fnameescape( {fname})	"String	escape special characters in {fname}
fnamemodify( {fname}, {mods})	"String	modify file name
foldclosed( {lnum})	"Number	first line of fold at {lnum} if closed
foldclosedend( {lnum})	"Number	last line of fold at {lnum} if closed
foldlevel( {lnum})	"Number	fold level at {lnum}
foldtext( )	"String	line displayed for closed fold
foldtextresult( {lnum})	"String	text for closed fold at {lnum}
foreground( )	"Number	bring the Vim window to the foreground
function( {name})	"Funcref reference to function {name}
garbagecollect( [at_exit])	"none	free memory, breaking cyclic references
get( {list}, {idx} [, {def}])	"any	get item {idx} from {list} or {def}
get( {dict}, {key} [, {def}])	"any	get item {key} from {dict} or {def}
getbufline( {expr}, {lnum} [, {end}])	"List	lines {lnum} to {end} of buffer {expr}
getbufvar( {expr}, {varname})	"any	variable {varname} in buffer {expr}
getchar( [expr])	"Number	get one character from the user
getcharmod( )	"Number	modifiers for the last typed character
getcmdline()	"String	return the current command-line
getcmdpos()	"Number	return cursor position in command-line
getcmdtype()	"String	return the current command-line type
getcwd()	"String	the current working directory
getfperm( {fname})	"String	file permissions of file {fname}
getfsize( {fname})	"Number	size in bytes of file {fname}
getfontname( [{name}])	"String	name of font being used
getftime( {fname})	"Number	last modification time of file
getftype( {fname})	"String	description of type of file {fname}
getline( {lnum})	"String	line {lnum} of current buffer
getline( {lnum}, {end})	"List	lines {lnum} to {end} of current buffer
getloclist( {nr})	"List	list of location list items
getmatches()	"List	list of current matches
getpid()	"Number	process ID of Vim
getpos( {expr})	"List	position of cursor, mark, etc.
getqflist()	"List	list of quickfix items
getreg( [{regname} [, 1]])	"String	contents of register
getregtype( [{regname}])	"String	type of register
gettabvar( {nr}, {varname})	"any	variable {varname} in tab {nr}
gettabwinvar( {tabnr}, {winnr}, {name})	"any	{name} in {winnr} in tab page {tabnr}
getwinposx()	"Number	X coord in pixels of GUI Vim window
getwinposy()	"Number	Y coord in pixels of GUI Vim window
getwinvar( {nr}, {varname})	"any	variable {varname} in window {nr}
glob( {expr} [, {flag}])	"String	expand file wildcards in {expr}
globpath( {path}, {expr} [, {flag}])	"String	do glob({expr}) for all dirs in {path}
has( {feature})	"Number	TRUE if feature {feature} supported
has_key( {dict}, {key})	"Number	TRUE if {dict} has entry {key}
haslocaldir()	"Number	TRUE if current window executed |:lcd|
hasmapto( {what} [, {mode} [, {abbr}]])	"Number	TRUE if mapping to {what} exists
histadd( {history},{item})	"String	add an item to a history
histdel( {history} [, {item}])	"String	remove an item from a history
histget( {history} [, {index}])	"String	get the item {index} from a history
histnr( {history})	"Number	highest index of a history
hlexists( {name})	"Number	TRUE if highlight group {name} exists
hlID( {name})	"Number	syntax ID of highlight group {name}
hostname()	"String	name of the machine Vim is running on
iconv( {expr}, {from}, {to})	"String	convert encoding of {expr}
indent( {lnum})	"Number	indent of line {lnum}
index( {list}, {expr} [, {start} [, {ic}]])	"Number	index in {list} where {expr} appears
input( {prompt} [, {text} [, {completion}]])	"String	get input from the user
inputdialog( {p} [, {t} [, {c}]]) String  like input() but in a GUI dialog
inputlist( {textlist})	"Number	let the user pick from a choice list
inputrestore()	"Number	restore typeahead
inputsave()	"Number	save and clear typeahead
inputsecret( {prompt} [, {text}]) String  like input() but hiding the text
insert( {list}, {item} [, {idx}])	"List	insert {item} in {list} [before {idx}]
isdirectory( {directory})	"Number	TRUE if {directory} is a directory
islocked( {expr})	"Number	TRUE if {expr} is locked
items( {dict})	"List	key-value pairs in {dict}
join( {list} [, {sep}])	"String	join {list} items into one String
keys( {dict})	"List	keys in {dict}
len( {expr})	"Number	the length of {expr}
libcall( {lib}, {func}, {arg})	"String	call {func} in library {lib} with {arg}
libcallnr( {lib}, {func}, {arg})  Number  idem, but return a Number
line( {expr})	"Number	line nr of cursor, last line or mark
line2byte( {lnum})	"Number	byte count of line {lnum}
lispindent( {lnum})	"Number	Lisp indent for line {lnum}
localtime()	"Number	current time
log( {expr})	"Float	natural logarithm (base e) of {expr}
log10( {expr})	"Float	logarithm of Float {expr} to base 10
map( {expr}, {string})	"List/Dict  change each item in {expr} to {expr}
maparg( {name}[, {mode} [, {abbr} [, {dict}]]])	"String	rhs of mapping {name} in mode {mode}
mapcheck( {name}[, {mode} [, {abbr}]])	"String	check for mappings matching {name}
match( {expr}, {pat}[, {start}[, {count}]])	"Number	position where {pat} matches in {expr}
matchadd( {group}, {pattern}[, {priority}[, {id}]])	"Number	highlight {pattern} with {group}
matcharg( {nr})	"List	arguments of |:match|
matchdelete( {id})	"Number	delete match identified by {id}
matchend( {expr}, {pat}[, {start}[, {count}]])	"Number	position where {pat} ends in {expr}
matchlist( {expr}, {pat}[, {start}[, {count}]])	"List	match and submatches of {pat} in {expr}
matchstr( {expr}, {pat}[, {start}[, {count}]])	"String	{count}'th match of {pat} in {expr}
max( {list})	"Number	maximum value of items in {list}
min( {list})	"Number	minimum value of items in {list}
mkdir( {name} [, {path} [, {prot}]])	"Number	create directory {name}
mode( [expr])	"String	current editing mode
mzeval( {expr})	"any	evaluate |MzScheme| expression
nextnonblank( {lnum})	"Number	line nr of non-blank line >= {lnum}
nr2char( {expr})	"String	single char with ASCII value {expr}
pathshorten( {expr})	"String	shorten directory names in a path
pow( {x}, {y})	"Float	{x} to the power of {y}
prevnonblank( {lnum})	"Number	line nr of non-blank line <= {lnum}
printf( {fmt}, {expr1}...)	"String	format text
pumvisible()	"Number	whether popup menu is visible
range( {expr} [, {max} [, {stride}]])	"List	items from {expr} to {max}
readfile( {fname} [, {binary} [, {max}]])	"List	get list of lines from file {fname}
reltime( [{start} [, {end}]])	"List	get time value
reltimestr( {time})	"String	turn time value into a String
remote_expr( {server}, {string} [, {idvar}])	"String	send expression
remote_foreground( {server})	"Number	bring Vim server to the foreground
remote_peek( {serverid} [, {retvar}])	"Number	check for reply string
remote_read( {serverid})	"String	read reply string
remote_send( {server}, {string} [, {idvar}])	"String	send key sequence
remove( {list}, {idx} [, {end}])	"any	remove items {idx}-{end} from {list}
remove( {dict}, {key})	"any	remove entry {key} from {dict}
rename( {from}, {to})	"Number	rename (move) file from {from} to {to}
repeat( {expr}, {count})	"String	repeat {expr} {count} times
resolve( {filename})	"String	get filename a shortcut points to
reverse( {list})	"List	reverse {list} in-place
round( {expr})	"Float	round off {expr}
search( {pattern} [, {flags} [, {stopline} [, {timeout}]]])	"Number	search for {pattern}
searchdecl( {name} [, {global} [, {thisblock}]])	"Number	search for variable declaration
searchpair( {start}, {middle}, {end} [, {flags} [, {skip} [...]]])	"Number	search for other end of start/end pair
searchpairpos( {start}, {middle}, {end} [, {flags} [, {skip} [...]]])	"List	search for other end of start/end pair
searchpos( {pattern} [, {flags} [, {stopline} [, {timeout}]]])	"List	search for {pattern}
server2client( {clientid}, {string})	"Number	send reply string
serverlist()	"String	get a list of available servers
setbufvar( {expr}, {varname}, {val})	"none	set {varname} in buffer {expr} to {val}
setcmdpos( {pos})	"Number	set cursor position in command-line
setline( {lnum}, {line})	"Number	set line {lnum} to {line}
setloclist( {nr}, {list}[, {action}])none	" Number	modify location list using {list}
setmatches( {list})	"Number	restore a list of matches
setpos( {expr}, {list})	"Number	set the {expr} position to {list}
setqflist( {list}[, {action}])	"Number	modify quickfix list using {list}
setreg( {n}, {v}[, {opt}])	"Number	set register to value and type
settabvar( {nr}, {varname}, {val})	"none	set {varname} in tab page {nr} to {val}
settabwinvar( {tabnr}, {winnr}, {varname}, {val})    set {varname} in window {winnr} in tab page {tabnr} to {val}
setwinvar( {nr}, {varname}, {val})	"none	set {varname} in window {nr} to {val}
shellescape( {string} [, {special}])	"String	escape {string} for use as shell command argument
simplify( {filename})	"String	simplify filename as much as possible
sin( {expr})	"Float	sine of {expr}
sinh( {expr})	"Float	hyperbolic sine of {expr}
sort( {list} [, {func}])	"List	sort {list}, using {func} to compare
soundfold( {word})	"String	sound-fold {word}
spellbadword()	"String	badly spelled word at cursor
spellsuggest( {word} [, {max} [, {capital}]])	"List	spelling suggestions
split( {expr} [, {pat} [, {keepempty}]])	"List	make |List| from {pat} separated {expr}
sqrt( {expr}	"Float	squar root of {expr}
str2float( {expr})	"Float	convert String to Float
str2nr( {expr} [, {base}])	"Number	convert String to Number
strchars( {expr})	"Number	character length of the String {expr}
strdisplaywidth( {expr} [, {col}]) Number display length of the String {expr}
strftime( {format}[, {time}])	"String	time in specified format
stridx( {haystack}, {needle}[, {start}])	"Number	index of {needle} in {haystack}
string( {expr})	"String	String representation of {expr} value
strlen( {expr})	"Number	length of the String {expr}
strpart( {src}, {start}[, {len}])	"String	{len} characters of {src} at {start}
strridx( {haystack}, {needle} [, {start}])	"Number	last index of {needle} in {haystack}
strtrans( {expr})	"String	translate string to make it printable
strwidth( {expr})	"Number	display cell length of the String {expr}
submatch( {nr})	"String	specific match in ":substitute"
substitute( {expr}, {pat}, {sub}, {flags})	"String	all {pat} in {expr} replaced with {sub}
synID( {lnum}, {col}, {trans})	"Number	syntax ID at {lnum} and {col}
synIDattr( {synID}, {what} [, {mode}])	"String	attribute {what} of syntax ID {synID}
synIDtrans( {synID})	"Number	translated syntax ID of {synID}
synconcealed( {lnum}, {col})	"List	info about concealing
synstack( {lnum}, {col})	"List	stack of syntax IDs at {lnum} and {col}
system( {expr} [, {input}])	"String	output of shell command/filter {expr}
tabpagebuflist( [{arg}])	"List	list of buffer numbers in tab page
tabpagenr( [{arg}])	"Number	number of current or last tab page
tabpagewinnr( {tabarg}[, {arg}])	"Number	number of current window in tab page
taglist( {expr})	"List	list of tags matching {expr}
tagfiles()	"List	tags files used
tempname()	"String	name for a temporary file
tan( {expr})	"Float	tangent of {expr}
tanh( {expr})	"Float	hyperbolic tangent of {expr}
tolower( {expr})	"String	the String {expr} switched to lowercase
toupper( {expr})	"String	the String {expr} switched to uppercase
tr( {src}, {fromstr}, {tostr})	"String	translate chars of {src} in {fromstr} to chars in {tostr}
trunc( {expr}	"Float	truncate Float {expr}
type( {name})	"Number	type of variable {name}
undofile( {name})	"String	undo file name for {name}
undotree()	"List	undo file tree
values( {dict})	"List	values in {dict}
virtcol( {expr})	"Number	screen column of cursor or mark
visualmode( [expr])	"String	last visual mode used
winbufnr( {nr})	"Number	buffer number of window {nr}
wincol()	"Number	window column of the cursor
winheight( {nr})	"Number	height of window {nr}
winline()	"Number	window line of the cursor
winnr( [{expr}])	"Number	number of current window
winrestcmd()	"String	returns command to restore window sizes
winrestview( {dict})	"none	restore view of current window
winsaveview()	"Dict	save view of current window
winwidth( {nr})	"Number	width of window {nr}
writefile( {list}, {fname} [, {binary}])	"Number	write list of lines to file {fname}
