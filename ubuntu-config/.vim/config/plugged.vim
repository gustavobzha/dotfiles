call plug#begin('~/.vim/plugged')

"A solid language pack for Vim
Plug 'sheerun/vim-polyglot'

"Atom colorscheme for vim
"Plug 'rakr/vim-one'

"File navigation
Plug 'lambdalisue/fern.vim'

Plug 'easymotion/vim-easymotion'

Plug 'jiangmiao/auto-pairs'

Plug 'tpope/vim-surround'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

"Plug 'terryma/vim-multiple-cursors'

call plug#end()
