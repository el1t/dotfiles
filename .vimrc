" Use iMproved settings
set nocompatible

" Theme/Formatting {{{
set background=light			" Use light background
colorscheme solarized			" Set theme solarized
set fillchars+=stl:\ ,stlnc:\ "	" Remove fillchars in statusline
set term=xterm-256color			" Declare 256 colors
set encoding=utf-8 nobomb		" Use UTF-8 without BOM header
syntax on						" Enable syntax highlighting
set rnu nu						" Enable line numbers in hybrid mode
set timeoutlen=100				" Change delay for repeated presses
let g:airline_powerline_fonts = 1
let g:airline_theme='powerline'
let g:airline#extensions#tabline#enabled = 1
" }}}

" Vundle Setup {{{
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'	" Required

" >>> Begin user plugins (call :PluginInstall to setup new plugins)

Plugin 'tpope/vim-fugitive'				" Fugitive git wrapper
Plugin 'airblade/vim-gitgutter'			" Git changes in gutter
Plugin 'scrooloose/nerdtree'			" NERDTree file browser
Plugin 'sjl/gundo.vim'					" Gundo undo tree browser
Plugin 'vim-airline/vim-airline'		" Airline for vim
Plugin 'vim-ctrlspace/vim-ctrlspace'	" Workspace/tab enhancement

" <<< End user plugins

" Format indenting
filetype plugin indent on		" Enable tabbing
set tabstop=4					" Make tabs as wide as four spaces
set shiftwidth=0				" Set tab button to insert tabstop-sized indent

call vundle#end()
" }}}

" Set History/Swap {{{
set history=500				" Enlarge history size
set hidden					" Enable backgrounded buffers
set backup writebackup		" Use backup
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if has('persistent_undo')	" Keep undo history across sessions
	silent !mkdir ~/.vim/undo > /dev/null 2>&1
	set undodir=~/.vim/undo
	set undofile
endif
set viminfo+=!				" Save vim history in viminfo
" }}}

" Search {{{
set hlsearch				" Highlight searches
set incsearch				" Highlight dynamically as pattern is typed
set ignorecase				" Ignore case of searches
set gdefault				" Add the g flag to search/replace by default
" }}}

" Behavior {{{
set wildmenu				" Enhance command-line completion
set mouse=a					" Enable mouse in all modes
set nostartofline			" Don’t reset cursor to start of line when moving around.
set clipboard=unnamed		" Use OS clipboard
set exrc					" Enable per-directory .vimrc files
set secure					" ...and disable unsafe commands in them
set binary noeol			" Don’t add empty newlines at the end of files
set ttyfast					" Optimize for fast terminal connections
set modeline				" Read and use modelines in files
set modelines=4
" }}}

" View Settings {{{
set ruler					" Show the cursor position
set shortmess=atI			" Don’t show the intro message when starting Vim
set showmode				" Show the current mode
set title					" Show the filename in the window titlebar
set showcmd					" Show the (partial) command as it’s being typed
set cursorline				" Highlight current line
set scrolloff=2				" Start scrolling three lines before the horizontal window border
set lazyredraw				" Only redraw when necessary
set list					" Show whitespace
set lcs=tab:\ \ ,trail:·	" Format whitespace characters
set laststatus=2			" Always show status line
set wmh=0 					" Only show filename of minimized files
" }}}

" Functions {{{
" Strip trailing whitespace ( ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
" }}}

" Key Remap {{{
let mapleader=" "
set esckeys							" Allow cursor keys in insert mode
set backspace=indent,eol,start		" Allow backspace in insert mode
" Save as root
cmap w!! w !sudo sh -c "cat > %"
" Open and maximize the split below
map <C-J> <C-W>j<C-W>_
" Open and maximize the split above
map <C-K> <C-W>k<C-W>_
" Visually move up/down, even on same line
nmap j gj
nmap k gk
" Jump to line and col
nmap ' `
nmap ` '
" Hotkey to turn off search highlight
nmap <leader>h :noh<CR>
" Highlight last inserted text
nmap gV `[v`]
" Save session
nmap <leader>s :mksession<CR>
" Open/close folds
nmap , za
nmap <leader>ss :call StripWhitespace()<CR>

" Plugin keymappings
map <leader>e :NERDTreeToggle<CR>
map <leader>z :GundoToggle<CR>
" }}}

" Enable Powerline {{{
"source ~/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim/plugin/powerline.vim
" }}}

" vim:foldmethod=marker:foldlevel=0
