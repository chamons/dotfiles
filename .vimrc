" Sane defaults
set nocompatible

" , is the key
let mapleader = ","

" New MBP have broken escape key so get used to something else
imap jk <Esc>
imap JK <Esc>

" Let us swap files without saving always
set hidden

" Let's use the mouse like any modern program
set mouse=a
set autoindent

" Beeping is the devil
set visualbell

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start 

" Don't dirty disk with backup files
set nobackup
set noswapfile
set nowritebackup

" keep 50 lines of command line history
set history=50

" Always show status line
set laststatus=2

" Key curser away from the edges, scroll
set sidescroll=5
set sidescrolloff=5
set scrolloff=5
set splitbelow
set splitright

" Tab behavior
set tabstop=8
set shiftwidth=8
set smartindent
set smarttab
set cindent

" Simple search behavior
set ignorecase
set hlsearch
set incsearch
set showmatch

" Set colors and font
syntax clear
set background=dark
syntax on

hi Normal guibg=Black guifg=gray70
hi Cursor guibg=LightGreen guifg=Black
hi StatusLineNC guibg=Black guifg=#808080
hi StatusLine guibg=Black guifg=#c0c0c0
set guifont=Monaco:h16

" Get rid of any GUI junk
set guioptions-=m 
set guioptions-=T
unmenu ToolBar
unmenu! ToolBar

" Delete without blapping buffer
noremap R "_d

" Insert key drops to insert 
noremap <Help> i
noremap <C-Help> i
noremap <M-Help> i
noremap <S-Help> i
inoremap <Help> <nop>

" Show line number by default
set ruler

" Make mvim large by default
if has("gui_running")
	set lines=47
	set columns=200
endif

" Let shift+insert paste
map <S-Help> <MiddleMouse>
map! <S-Help> <MiddleMouse>

" Never show tab line
set stal=0

" Load Command-T
execute pathogen#infect()
let g:CommandTFileScanner = "git"
let g:CommandTSCMDirectories='.git'

" Destory All Software shortcuts  
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" Command in/out easily
au FileType vim let b:comment_leader = '" '
au FileType c,cpp,java,cs let b:comment_leader = '// '
au FileType sh,make let b:comment_leader = '# '
noremap <silent> <leader>c :<C-B>sil <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:noh<CR>
noremap <silent> <leader>u :<C-B>sil <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:noh<CR>  

" Sane file completion behavior
set wildmenu
set wildmode=longest,list
set wildignore+=*.a,*.o
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
set wildignore+=.DS_Store,.git,.hg,.svn
set wildignore+=*~,*.swp,*.tmp

" Let me i in the end of a line without shift+a
set virtualedit=onemore
