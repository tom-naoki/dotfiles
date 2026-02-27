" プラグイン
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
call plug#end()

" LSP キーマッピング
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> K  <plug>(lsp-hover)
  nmap <buffer> <Leader>rn <plug>(lsp-rename)
  nmap <buffer> [d <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <plug>(lsp-next-diagnostic)
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" NERDTreeの表示切り替え
nnoremap <Leader>b :NERDTreeToggle<CR>

" 引数なし or ディレクトリを開いたときにNERDTreeを自動で開く
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) | execute 'NERDTree' argv()[0] | wincmd p | enew | wincmd p | endif

" git差分マークをガターに表示
set signcolumn=yes
set updatetime=100

" 文字コードをUFT-8に設定
set fenc=utf-8
" スクロール速度を速く設定
set lazyredraw

" vim のコピーをクリップボードに
set clipboard+=unnamed

" colorscheme
colorscheme default

" GitGutterのサイン色を明示的に設定（VimEnterで全プラグイン読み込み後に適用）
autocmd VimEnter,ColorScheme * highlight GitGutterAdd    ctermfg=green  ctermbg=NONE
autocmd VimEnter,ColorScheme * highlight GitGutterChange ctermfg=yellow ctermbg=NONE
autocmd VimEnter,ColorScheme * highlight GitGutterDelete ctermfg=red    ctermbg=NONE
" 検索ハイライトの色（黒背景 + 黄色文字）
autocmd VimEnter,ColorScheme * highlight Search ctermfg=yellow ctermbg=black cterm=bold

"行番号を表示
set number
"選択中の行を強調
set cursorline
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" 括弧入力時の対応する括弧を表示
set showmatch
" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" シンタックスハイライトの有効化
syntax enable

" インデント
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=2 " Vimが挿入するインデントの幅
set tabstop=2 " タブ文字の表示幅

" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索結果をハイライト表示
set hlsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan

" Ctrl+a Ctrol+e で行頭、行末に移動
inoremap <C-e> <Esc>$a
inoremap <C-a> <Esc>^i
noremap <C-e> <Esc>$
noremap <C-a> <Esc>^
vnoremap <C-e> $
vnoremap <C-a> ^
" カッコ補完
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
" クオテーション補完
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
