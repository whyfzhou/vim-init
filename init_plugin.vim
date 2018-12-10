" t9md/vim-choosewin
nmap <M-e> <Plug>(choosewin)

" Ultisnips
let g:UltiSnipsSnippetDirectories=[$HOME."/vimsnippets"]
" 使用 Tab 键出发代码片段补全
let g:UltiSnipsExpandTrigger="<tab>"
" 使用 tab 切换下一个触发点，shit+tab 上一个触发点
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
" 使用 UltiSnipsEdit 命令时垂直分割屏幕
let g:UltiSnipsEditSplit="vertical"
