## vim

출처 : http://vim.wikia.com/wiki/Using_tab_pages

### 탭으로 열기

	:tabedit {file}   edit specified file in a new tab
	:tabfind {file}   open a new tab with filename given, searching the 'path' to find it
	:tabclose         close current tab
	:tabclose {i}     close i-th tab
	:tabonly          close all other tabs (show only the current tab)

### Tab : Navigation

	:tabs         list all tabs including their displayed windows
	:tabm 0       move current tab to first
	:tabm         move current tab to last
	:tabm {i}     move current tab to position i+1

	:tabn         go to next tab
	:tabp         go to previous tab
	:tabfirst     go to first tab
	:tablast      go to last tab

### In normal mode, you can type:

	gt            go to next tab
	gT            go to previous tab
	{i}gt         go to tab in position i

### When using gvim, in normal mode and in insert mode, you can type:

	Ctrl-PgDn     go to next tab
	Ctrl-PgUp     go to previous tab

### Switching to another buffer

	set switchbuf=usetab
	nnoremap <F8> :sbnext<CR>
	nnoremap <S-F8> :sbprevious<CR>

### Shortcuts

	nnoremap <C-Left> :tabprevious<CR>
	nnoremap <C-Right> :tabnext<CR>
	nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
	nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>

### Undo

윈도우에서는 Ctrl+z 누르면 undo하지만 다른 os는 shell로 나간다. 
`u` 입력하면 undo함.