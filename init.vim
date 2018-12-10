" -*- encoding: utf-8 -*-
" vim: set ts=2 sw=2 et sts=2 :


" Default Settings {{{
if get(s:, 'loaded', 0) != 0  " 防止重复加载
  finish
else
  let s:loaded = 1
endif

set nocompatible
" }}}


" General Settings {{{
set encoding=utf-8  " 内部编码
set fileencoding=utf-8  " 文件默认编码
set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1  " 打开文件时的尝试顺序
set langmenu=none  " 忽略 locale 而使用英语菜单
" language message en.US  " 忽略 locale 而使用英语提示

let mapleader = " "

set clipboard+=unnamed  " 默认使用系统剪贴板

set formatoptions+=m  " 对于 Unicode 大于 255 的文本，折行不必等待空格
set formatoptions+=B  " 合并两行中文时，不在中间加空格
set fileformats=unix,dos,mac  " 默认 unix 换行（\n）。set ffs= 可修改当前文件

set backspace=eol,start,indent  " 退格键可穿越行末、行首和缩进

set cindent  " 默认缩进方式
if has('autocmd')  " 允许 Vim 自带脚本根据文件类型自动设置缩进
  filetype plugin indent on
endif

set winaltkeys=no  " Windows 下不用 Alt 键操作菜单栏，这样 Alt 可以作其他用途
set nowrap  " 不自动折行

set ignorecase  " 搜索时忽略大小写
set smartcase  " 如搜索内容包含大写则大小写敏感
set hlsearch  " 高亮搜索内容
set incsearch  " 增量显示搜索结果
" }}}


" Appearance Settings {{{
set ruler
set showmatch
set matchtime=2
set display=lastline
set wildmenu
set lazyredraw  " 使用延迟重绘提升显示性能

set listchars=tab:\|\ ,trail:.,extends:>,precedes:<
set list

set laststatus=2
set number
set signcolumn=yes
set showtabline=2
set showcmd
set t_Co=256
if has('gui_running')
  colorscheme desert
  set splitright
  set background=dark
  set guifont="Sarasa\ Mono\ CL:h12
  set guioptions-=T
  " let g:config_vim_tab_style = 3
else
  set background=dark
endif

set statusline=
set statusline+=\ %F
set statusline+=\ [%1*%M*%n%R%H]
set statusline+=%=
set statusline+=\ %y
set statusline+=\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %v:%l/%L%)

if has('syntax')  " 如果可以，打开语法着色
  syntax enable
  syntax on
endif

" 更清晰的错误标注：默认一片红色背景，语法高亮都被搞没了
" 只显示红色或者蓝色下划线或者波浪线
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellRare
hi! clear SpellLocal
if has('gui_running')
  hi! SpellBad gui=undercurl guisp=red
  hi! SpellCap gui=undercurl guisp=blue
  hi! SpellRare gui=undercurl guisp=magenta
  hi! SpellRare gui=undercurl guisp=cyan
else
  hi! SpellBad term=standout ctermfg=1 term=underline cterm=underline
  hi! SpellCap term=underline cterm=underline
  hi! SpellRare term=underline cterm=underline
  hi! SpellLocal term=underline cterm=underline
endif

" 去掉 sign column 的白色背景
hi! SignColumn guibg=NONE ctermbg=NONE

" 修改行号为浅灰色，默认主题的黄色行号很难看，换主题可以仿照修改
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE 
  \ gui=NONE guifg=DarkGrey guibg=NONE

" 修正补全目录的色彩：默认太难看
hi! Pmenu guibg=gray guifg=black ctermbg=gray ctermfg=black
hi! PmenuSel guibg=gray guifg=brown ctermbg=brown ctermfg=gray

" quickfix 设置，隐藏行号
augroup VimInitStyle
  autocmd!
  autocmd FileType qf setlocal nonumber
augroup END

"----------------------------------------------------------------------
" 标签栏文字风格：默认为零，GUI 模式下空间大，按风格 3显示
" 0: filename.txt
" 2: 1 - filename.txt
" 3: [1] filename.txt
"----------------------------------------------------------------------
if has('gui_running')
  let g:config_vim_tab_style = 3
endif

"----------------------------------------------------------------------
" 终端下的 tabline
"----------------------------------------------------------------------
function! Vim_NeatTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{Vim_NeatTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999XX'
  endif

  return s
endfunc

"----------------------------------------------------------------------
" 需要显示到标签上的文件名
"----------------------------------------------------------------------
function! Vim_NeatBuffer(bufnr, fullname)
  let l:name = bufname(a:bufnr)
  if getbufvar(a:bufnr, '&modifiable')
    if l:name == ''
      return '[No Name]'
    else
      if a:fullname 
        return fnamemodify(l:name, ':p')
      else
        let aname = fnamemodify(l:name, ':p')
        let sname = fnamemodify(aname, ':t')
        if sname == ''
          let test = fnamemodify(aname, ':h:t')
          if test != ''
            return '<'. test . '>'
          endif
        endif
        return sname
      endif
    endif
  else
    let l:buftype = getbufvar(a:bufnr, '&buftype')
    if l:buftype == 'quickfix'
      return '[Quickfix]'
    elseif l:name != ''
      if a:fullname 
        return '-'.fnamemodify(l:name, ':p')
      else
        return '-'.fnamemodify(l:name, ':t')
      endif
    else
    endif
    return '[No Name]'
  endif
endfunc

"----------------------------------------------------------------------
" 标签栏文字，使用 [1] filename 的模式
"----------------------------------------------------------------------
function! Vim_NeatTabLabel(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:bufnr = l:buflist[l:winnr - 1]
  let l:fname = Vim_NeatBuffer(l:bufnr, 0)
  let l:num = a:n
  let style = get(g:, 'config_vim_tab_style', 0)
  if style == 0
    return l:fname
  elseif style == 1
    return "[".l:num."] ".l:fname
  elseif style == 2
    return "".l:num." - ".l:fname
  endif
  if getbufvar(l:bufnr, '&modified')
    return "[".l:num."] ".l:fname." +"
  endif
  return "[".l:num."] ".l:fname
endfunc

"----------------------------------------------------------------------
" GUI 下的标签文字，使用 [1] filename 的模式
"----------------------------------------------------------------------
function! Vim_NeatGuiTabLabel()
  let l:num = v:lnum
  let l:buflist = tabpagebuflist(l:num)
  let l:winnr = tabpagewinnr(l:num)
  let l:bufnr = l:buflist[l:winnr - 1]
  let l:fname = Vim_NeatBuffer(l:bufnr, 0)
  let style = get(g:, 'config_vim_tab_style', 0)
  if style == 0
    return l:fname
  elseif style == 1
    return "[".l:num."] ".l:fname
  elseif style == 2
    return "".l:num." - ".l:fname
  endif
  if getbufvar(l:bufnr, '&modified')
    return "[".l:num."] ".l:fname." +"
  endif
  return "[".l:num."] ".l:fname
endfunc


"----------------------------------------------------------------------
" 设置 GUI 标签的 tips: 显示当前标签有哪些窗口
"----------------------------------------------------------------------
function! Vim_NeatGuiTabTip()
  let tip = ''
  let bufnrlist = tabpagebuflist(v:lnum)
  for bufnr in bufnrlist
    " separate buffer entries
    if tip != ''
      let tip .= " \n"
    endif
    " Add name of buffer
    let name = Vim_NeatBuffer(bufnr, 1)
    let tip .= name
    " add modified/modifiable flags
    if getbufvar(bufnr, "&modified")
      let tip .= ' [+]'
    endif
    if getbufvar(bufnr, "&modifiable")==0
      let tip .= ' [-]'
    endif
  endfor
  return tip
endfunc

"----------------------------------------------------------------------
" 标签栏最终设置
"----------------------------------------------------------------------
set tabline=%!Vim_NeatTabLine()
set guitablabel=%{Vim_NeatGuiTabLabel()}
set guitabtooltip=%{Vim_NeatGuiTabTip()}


" Terminal 下分模式使用不同 cursors
if &term == "xterm-256color" || &term == "screen-256color"
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[1 q"
endif

if exists("$TMUX")
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
endif
" }}}


" Folding Settings {{{
if has('folding')  " 如果可以，打开文本折叠
  set foldenable
  set foldmethod=marker
  set foldlevel=99
endif
autocmd FileType vim normal zM
" }}}


" Terminal Settings {{{
set ttimeout  " 终端下功能键超时，可适用于网络条件很差的情形
set ttimeoutlen=50  " 50ms 内功能键序列未发送完毕则忽略按键
if $TMUX != ''  " 对 Tmux 单独设置超时时间
  set ttimeoutlen=30
elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
  set ttimeoutlen=80
endif

if has('nvim') == 0 && has('gui_running') == 0  " 终端下允许使用 Alt 键
  function! s:metacode(key)
    exec "set <M-".a:key.">=\e".a:key
  endfunc
  for i in range(10)
    call s:metacode(nr2char(char2nr('0') + i))
  endfor
  for i in range(26)
    call s:metacode(nr2char(char2nr('a') + i))
    call s:metacode(nr2char(char2nr('A') + i))
  endfor
  for c in [',', '.', '/', ';', '{', '}']
    call s:metacode(c)
  endfor
  for c in ['?', ':', '-', '_', '+', '=', "'"]
    call s:metacode(c)
  endfor
endif

function! s:key_escape(name, code)  " 终端下的功能键
  if has('nvim') == 0 && has('gui_running') == 0
    exec "set ".a:name."=\e".a:code
  endif
endfunc

" 功能键终端码矫正
call s:key_escape('<F1>', 'OP')
call s:key_escape('<F2>', 'OQ')
call s:key_escape('<F3>', 'OR')
call s:key_escape('<F4>', 'OS')
call s:key_escape('<S-F1>', '[1;2P')
call s:key_escape('<S-F2>', '[1;2Q')
call s:key_escape('<S-F3>', '[1;2R')
call s:key_escape('<S-F4>', '[1;2S')
call s:key_escape('<S-F5>', '[15;2~')
call s:key_escape('<S-F6>', '[17;2~')
call s:key_escape('<S-F7>', '[18;2~')
call s:key_escape('<S-F8>', '[19;2~')
call s:key_escape('<S-F9>', '[20;2~')
call s:key_escape('<S-F10>', '[21;2~')
call s:key_escape('<S-F11>', '[23;2~')
call s:key_escape('<S-F12>', '[24;2~')

" 防止 tmux 下 vim 的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
if &term =~ '256color' && $TMUX != ''
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif
" }}}


" Backup Settings {{{
set backup
set writebackup
set backupdir=~/.vim/backup/
set noswapfile
set noundofile
silent! call mkdir(expand('~/.vim/backup'), "p", 0755)

" 打开文件时恢复上一次光标位置
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
" }}}


" File Type Settings {{{
" 文件名补充和搜索时忽略下列扩展名
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android

let g:tex_flavor='latex'
" }}}


" Keymap Settings {{{
" use Emacs keymaps in insert mode
inoremap <M-b> <C-o>b
inoremap <M-f> <C-o>w
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>
inoremap <C-_> <C-k>

"----------------------------------------------------------------------
" 设置 CTRL+HJKL 移动光标（INSERT 模式偶尔需要移动的方便些）
" 使用 SecureCRT/XShell 等终端软件需设置：Backspace sends delete
" 详见：http://www.skywind.me/blog/archives/2021
"----------------------------------------------------------------------
noremap <C-h> <left>
noremap <C-j> <down>
noremap <C-k> <up>
noremap <C-l> <right>
inoremap <C-h> <left>
inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>

"----------------------------------------------------------------------
" 命令模式的快速移动
"----------------------------------------------------------------------
cnoremap <c-h> <left>
cnoremap <c-j> <down>
cnoremap <c-k> <up>
cnoremap <c-l> <right>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-f> <c-d>
cnoremap <c-b> <left>
cnoremap <c-d> <del>
cnoremap <c-_> <c-k>

"----------------------------------------------------------------------
" <leader>+数字键 切换tab
"----------------------------------------------------------------------
noremap <silent><leader>1 1gt<cr>
noremap <silent><leader>2 2gt<cr>
noremap <silent><leader>3 3gt<cr>
noremap <silent><leader>4 4gt<cr>
noremap <silent><leader>5 5gt<cr>
noremap <silent><leader>6 6gt<cr>
noremap <silent><leader>7 7gt<cr>
noremap <silent><leader>8 8gt<cr>
noremap <silent><leader>9 9gt<cr>
noremap <silent><leader>0 10gt<cr>

"----------------------------------------------------------------------
" ALT+N 切换 tab
"----------------------------------------------------------------------
noremap <silent><m-1> :tabn 1<cr>
noremap <silent><m-2> :tabn 2<cr>
noremap <silent><m-3> :tabn 3<cr>
noremap <silent><m-4> :tabn 4<cr>
noremap <silent><m-5> :tabn 5<cr>
noremap <silent><m-6> :tabn 6<cr>
noremap <silent><m-7> :tabn 7<cr>
noremap <silent><m-8> :tabn 8<cr>
noremap <silent><m-9> :tabn 9<cr>
noremap <silent><m-0> :tabn 10<cr>
inoremap <silent><m-1> <ESC>:tabn 1<cr>
inoremap <silent><m-2> <ESC>:tabn 2<cr>
inoremap <silent><m-3> <ESC>:tabn 3<cr>
inoremap <silent><m-4> <ESC>:tabn 4<cr>
inoremap <silent><m-5> <ESC>:tabn 5<cr>
inoremap <silent><m-6> <ESC>:tabn 6<cr>
inoremap <silent><m-7> <ESC>:tabn 7<cr>
inoremap <silent><m-8> <ESC>:tabn 8<cr>
inoremap <silent><m-9> <ESC>:tabn 9<cr>
inoremap <silent><m-0> <ESC>:tabn 10<cr>

" MacVim 允许 CMD+数字键快速切换标签
if has("gui_macvim")
  set macmeta
  noremap <silent><d-1> :tabn 1<cr>
  noremap <silent><d-2> :tabn 2<cr>
  noremap <silent><d-3> :tabn 3<cr>
  noremap <silent><d-4> :tabn 4<cr>
  noremap <silent><d-5> :tabn 5<cr>
  noremap <silent><d-6> :tabn 6<cr>
  noremap <silent><d-7> :tabn 7<cr>
  noremap <silent><d-8> :tabn 8<cr>
  noremap <silent><d-9> :tabn 9<cr>
  noremap <silent><d-0> :tabn 10<cr>
  inoremap <silent><d-1> <ESC>:tabn 1<cr>
  inoremap <silent><d-2> <ESC>:tabn 2<cr>
  inoremap <silent><d-3> <ESC>:tabn 3<cr>
  inoremap <silent><d-4> <ESC>:tabn 4<cr>
  inoremap <silent><d-5> <ESC>:tabn 5<cr>
  inoremap <silent><d-6> <ESC>:tabn 6<cr>
  inoremap <silent><d-7> <ESC>:tabn 7<cr>
  inoremap <silent><d-8> <ESC>:tabn 8<cr>
  inoremap <silent><d-9> <ESC>:tabn 9<cr>
  inoremap <silent><d-0> <ESC>:tabn 10<cr>
endif

" 缓存：插件 unimpaired 中定义了 [b, ]b 来切换缓存
noremap <silent> <leader>bn :bn<cr>
noremap <silent> <leader>bp :bp<cr>

" TAB：创建，关闭，上一个，下一个，左移，右移
" 其实还可以用原生的 CTRL+PageUp, CTRL+PageDown 来切换标签
noremap <silent> <leader>tc :tabnew<cr>
noremap <silent> <leader>tq :tabclose<cr>
noremap <silent> <leader>tn :tabnext<cr>
noremap <silent> <leader>tp :tabprev<cr>

" 左移 tab
function! Tab_MoveLeft()
  let l:tabnr = tabpagenr() - 2
  if l:tabnr >= 0
    exec 'tabmove '.l:tabnr
  endif
endfunc

" 右移 tab
function! Tab_MoveRight()
  let l:tabnr = tabpagenr() + 1
  if l:tabnr <= tabpagenr('$')
    exec 'tabmove '.l:tabnr
  endif
endfunc

noremap <silent><leader>tl :call Tab_MoveLeft()<cr>
noremap <silent><leader>tr :call Tab_MoveRight()<cr>
noremap <silent><m-left> :call Tab_MoveLeft()<cr>
noremap <silent><m-right> :call Tab_MoveRight()<cr>


"----------------------------------------------------------------------
" ALT 键移动增强
"----------------------------------------------------------------------

" ALT+h/l 快速左右按单词移动（正常模式+插入模式）
noremap <m-h> b
noremap <m-l> w
inoremap <m-h> <c-left>
inoremap <m-l> <c-right>

" ALT+j/k 逻辑跳转下一行/上一行（按 wrap 逻辑换行进行跳转） 
noremap <m-j> gj
noremap <m-k> gk
inoremap <m-j> <c-\><c-o>gj
inoremap <m-k> <c-\><c-o>gk

" 命令模式下的相同快捷
cnoremap <m-h> <c-left>
cnoremap <m-l> <c-right>

" ALT+y 删除到行末
noremap <m-y> d$
inoremap <m-y> <c-\><c-o>d$

"----------------------------------------------------------------------
" 窗口切换：ALT+SHIFT+hjkl
" 传统的 CTRL+hjkl 移动窗口不适用于 vim 8.1 的终端模式，CTRL+hjkl 在
" bash/zsh 及带文本界面的程序中都是重要键位需要保留，不能 tnoremap 的
"----------------------------------------------------------------------
noremap <C-/> <C-w>v
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
inoremap <C-/> <C-o><C-w>v
inoremap <m-H> <esc><c-w>h
inoremap <m-L> <esc><c-w>l
inoremap <m-J> <esc><c-w>j
inoremap <m-K> <esc><c-w>k

if has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
  " vim 8.1 支持 termwinkey ，不需要把 terminal 切换成 normal 模式
  " 设置 termwinkey 为 CTRL 加减号（GVIM），有些终端下是 CTRL+?
  " 后面四个键位是搭配 termwinkey 的，如果 termwinkey 更改，也要改
  set termwinkey=<c-_>
  tnoremap <m-H> <c-_>h
  tnoremap <m-L> <c-_>l
  tnoremap <m-J> <c-_>j
  tnoremap <m-K> <c-_>k
  tnoremap <m-q> <c-\><c-n>
elseif has('nvim')
  " neovim 没有 termwinkey 支持，必须把 terminal 切换回 normal 模式
  tnoremap <m-H> <c-\><c-n><c-w>h
  tnoremap <m-L> <c-\><c-n><c-w>l
  tnoremap <m-J> <c-\><c-n><c-w>j
  tnoremap <m-K> <c-\><c-n><c-w>k
  tnoremap <m-q> <c-\><c-n>
endif

if has('unix')
  autocmd! InsertLeave * call UseIBusDefault()
  autocmd! InsertEnter * call RecoverLastIM()
endif

let g:IBusLastEngine = system('ibus engine')
let g:IBusDefaultEngine = 'xkb:us::eng'
function! UseIBusDefault()
  let g:IBusLastEngine = system('ibus engine')
  call system('ibus engine ' . g:IBusDefaultEngine)
endfunction
function! RecoverLastIM()
  call system('ibus engine ' . g:IBusLastEngine)
endfunction
" }}}


" Programming Settings {{{

" Python
autocmd BufWritePre *.py :%s/\s\+$//e

let g:asyncrun_open = 6
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>
" Ubuntu term 中 F10 被激活菜單佔用了
noremap <silent> <leader>qf :call asyncrun#quickfix_toggle(6)<cr>

" F9 编译 C/C++ 文件
" nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
" F9 編譯 C/C++ 和 LaTeX
nnoremap <silent> <F9> :call CompileFile()<cr>

" F5 运行文件
nnoremap <silent> <F5> :call ExecuteFile()<cr>

" F7 编译项目
nnoremap <silent> <S-F7> :AsyncRun -cwd=<root> make <cr>
nnoremap <silent> <F7> :AsyncRun make <cr>

function! CompileFile()
  let cmd = ''
  if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
    let cmd = 'gcc -Wall -O2 "$(VIM_FILEPATH)" -o $(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
  elseif &ft == 'tex'
    let cmd1 = 'xelatex --shell-escape "$(VIM_FILEPATH)"'
    let cmd = cmd1 . ' && ' . cmd1
  else
    return
  endif
  if has('win32') || has('win64')
    exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=4 '. cmd
  else
    exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
  endif
endfunction

" F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
function! ExecuteFile()
  let cmd = ''
  if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
    " native 语言，把当前文件名去掉扩展名后作为可执行运行
    " 写全路径名是因为后面 -cwd=? 会改变运行时的当前路径，所以写全路径
    " 加双引号是为了避免路径中包含空格
    let cmd = '"$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
  elseif &ft == 'python'
    let $PYTHONUNBUFFERED=1 " 关闭 python 缓存，实时看到输出
    let cmd = 'python3 "$(VIM_FILEPATH)"'
  elseif &ft == 'javascript'
    let cmd = 'node "$(VIM_FILEPATH)"'
  elseif &ft == 'perl'
    let cmd = 'perl "$(VIM_FILEPATH)"'
  elseif &ft == 'ruby'
    let cmd = 'ruby "$(VIM_FILEPATH)"'
  elseif &ft == 'php'
    let cmd = 'php "$(VIM_FILEPATH)"'
  elseif &ft == 'lua'
    let cmd = 'lua "$(VIM_FILEPATH)"'
  elseif &ft == 'zsh'
    let cmd = 'zsh "$(VIM_FILEPATH)"'
  elseif &ft == 'ps1'
    let cmd = 'powershell -file "$(VIM_FILEPATH)"'
  elseif &ft == 'vbs'
    let cmd = 'cscript -nologo "$(VIM_FILEPATH)"'
  elseif &ft == 'sh'
    let cmd = 'bash "$(VIM_FILEPATH)"'
  elseif &ft == 'sh'
    let cmd = 'evince "$(VIM_FILENOEXT).pdf"'
  else
    return
  endif
  " Windows 下打开新的窗口 (-mode=4) 运行程序，其他系统在 quickfix 运行
  " -raw: 输出内容直接显示到 quickfix window 不匹配 errorformat
  " -save=2: 保存所有改动过的文件
  " -cwd=$(VIM_FILEDIR): 运行初始化目录为文件所在目录
  if has('win32') || has('win64')
    exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=4 '. cmd
  else
    exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
  endif
endfunc
" }}}


" Tabsize Settings {{{
set shiftwidth=4
set tabstop=4
set expandtab
set softtabstop=4
augroup TabSizes
  autocmd!
  autocmd FileType python setlocal shiftwidth=4 tabstop=4 expandtab softtabstop=4
  autocmd FileType tex setlocal shiftwidth=2 tabstop=2 expandtab softtabstop=2
augroup END
" }}}


" Plugin Settings {{{
source ~/.vim/init/init_plugin.vim
" }}}
