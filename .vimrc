set encoding=utf-8

" Tabs not spaces by default; show as 3 columns wide.
set noexpandtab
set shiftwidth=3
set tabstop=3


" No hideous auto-formatting
set textwidth=0  " Urgh, fuck off with arbitrary line lengths
set wrapmargin=0  " Just don't
set formatoptions=  " Basically like 'paste' is always set -- no auto-formatting whatsoever, thanks

set autoindent  " Except this: preserve current indentation on new lines


" Disable annoying bullshit ex mode binding which I often accidentally trigger when trying to hit ':'
nnoremap Q <nop>


" Make scrolling behaviour a little more pleasant and useful
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
set scrolloff=5  " Always keep some visible surroundings surrounding the cursor line


" Visual pleasantries
syntax enable
set bg=dark

highlight LineNr ctermfg=240
highlight CursorLineNr ctermbg=238 ctermfg=232

set listchars=tab:-\ ,trail:·
set list
highlight SpecialKey ctermfg=238
highlight NonText ctermfg=238

set wrap
set showbreak=...
set breakindent

set incsearch
set hlsearch


" Bonus plugins in case I can be arsed with this again
if exists("*pathogen")  " TODO is this exactly right?
	call pathogen#infect()
	noremap <C-p> :NERDTreeFind<CR>
endif
