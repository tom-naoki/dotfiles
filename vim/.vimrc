" プラグインのセットアップ
call plug#begin('~/.vim/plugged')

" ファイルタブを表示
Plug 'scrooloose/nerdtree'
" 自動でend補完
Plug 'tpope/vim-endwise'
" インデントに色を追加
Plug 'nathanaelkane/vim-indent-guides'
" vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
let g:indent_guides_enable_on_vim_startup = 1

call plug#end()

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
nnoremap <silent><C-f> :NERDTree<CR>
" カッコ補完
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
" クオテーション補完
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
