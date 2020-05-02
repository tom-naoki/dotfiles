" NeoBundle
if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle'))

" 自動で閉じる
NeoBundle 'tpope/vim-endwise'
" ファイルタブ
NeoBundle 'scrooloose/nerdtree'

call neobundle#end()

NeoBundleCheck


" 文字コードをUFT-8に設定
set fenc=utf-8
" スクロール速度を速く設定
set lazyredraw


" colorscheme設定
colorscheme hybrid

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
" 検索時に最後まで行ったら最初に戻る
set wrapscan

" Ctrl+a Ctrol+e で行頭、行末に移動
inoremap <C-e> <Esc>$a
inoremap <C-a> <Esc>^i
noremap <C-e> <Esc>$
noremap <C-a> <Esc>^
vnoremap <C-e> $
vnoremap <C-a> ^
" ファイルタブを開く
nnoremap <silent><C-e> :NERDTreeToggle<CR>
