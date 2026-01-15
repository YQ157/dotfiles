" ====================================================
" 基础显示设置 
" ====================================================
syntax on                   " 开启语法高亮，根据编程语言关键字显示不同颜色
set number                  " 在屏幕左侧显示行号，方便定位错误行
set cursorline              " 在光标所在行显示一条横线
set ruler                   " 在右下角显示光标当前的行号和列号
set wrap                    " 如果一行代码太长，自动折行显示，不超出屏幕边界
set showmatch               " 当光标移动到括号时，自动高亮匹配的另一半括号
set encoding=utf-8			" 强制 UTF-8 编码

" ====================================================
" 缩进与格式
" ====================================================
set tabstop=4               " Tab 键宽度
set shiftwidth=4            " 自动缩进 4 个空格
set expandtab               " Tab 键转为空格
set autoindent              " 换行时，光标自动移动到与上一行对齐的位置
set smartindent             " 智能缩进

" ====================================================
" 按键映射
" ====================================================
" 自动展开成代码框并缩进
inoremap {<CR> {<CR>}<Esc>O
" 将Normal模式的Esc映射为取消高亮
nnoremap <silent> <Esc> :noh<CR><Esc>
" 设置括号补全
inoremap () ()<Left>
inoremap "" ""<Left>
inoremap [] []<Left>
inoremap '' ''<Left>
" 'kj' or 'jk' 快速 Esc
inoremap jk <Esc>
inoremap kj <Esc>

" ====================================================
" 搜索设置 
" ====================================================
set hlsearch                " 搜索完成后，高亮显示所有匹配到的结果
set incsearch               " 边输入搜索词，边实时跳转到第一个匹配项
set ignorecase              " 搜索时默认不区分大小写
set smartcase               " 若搜索词包含大写字母，则转为区分大小写搜索

" ====================================================
" 系统集成 
" ====================================================
set clipboard=unnamed       " 让 Vim 的复制粘贴寄存器与 Mac 系统的剪贴板同步

" ====================================================
" Leader 配置
" ====================================================
let mapleader = "\<Space>"
" 快速退出
nnoremap <Leader>q :q<CR>
" 快速保存
nnoremap <Leader>w :w<CR>
" 快速取消高亮
nnoremap <Leader>h :noh<CR>

" 映射快捷键：Leader + n (New Problem)
" 实现在下面“自动关联目录名，新建题目文件”

" 映射快捷键：Leader + t (switch cin>>t;)
" 实现在下面“切换 cin>>t; 注释状态”

" ====================================================
" 自动化功能：F5 一键编译运行 
" ====================================================
" 将键盘上的 F5 键映射为调用我们定义的 CompileRunGpp 函数
nnoremap <F5> :call CompileRunGpp()<CR>
inoremap <F5> <Esc>:call CompileRunGpp()<CR>
" 定义编译运行函数，! 表示如果函数已存在则覆盖
func! CompileRunGpp()
    " 执行 :w 命令，在编译前先强制保存当前文件，防止运行旧代码
    execute "w"
    " 如果当前文件的类型是 C++ (cpp)
    if &filetype == 'cpp'
        " 调用外部 g++ 编译器，使用 C++17 标准，显示所有警告 (-Wall)，编译成功后直接运行
        " % 代表当前文件名，%< 代表去掉后缀的文件名
        execute "!g++ -std=c++17 -Wall -g -fsanitize=address % -o ~/Files/CppFiles/temp_bin/runner  && ~/Files/CppFiles/temp_bin/runner"
    " 如果当前文件的类型是 Python (python)
    elseif &filetype == 'python'
        " 调用外部 python3 解释器直接运行当前文件
        execute "!python3 %"
    " 结束判断条件
    endif
" 结束函数定义
endfunc

" ====================================================
" 自动加载模板：新建 .cpp 文件时，自动读取模板文件内容
" ====================================================
" --- 路径设置 ---
" <sfile>: 当前被 source 的文件，软链接地址
" expand(':p'): 转为绝对路径
" resolve() 解析软链接，找到真实物理路径
" fnamemodify(':h') 去掉文件名，只保留目录，Head
" g 表示全局作用域，s表示脚本作用域
let s:current_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:template_dir = s:current_dir . '/templates/'
" autocmd: 自动化命令
" BufNewFile: 触发时机是“创建一个不存在的新文件时”
" *.cpp: 匹配所有以 .cpp 结尾的文件
" silent!: 如果模板文件不存在，不报错
" execute: 动态拼接命令
" "0read": 从第 0 行开始读取 (Read) 后面路径文件的内容
autocmd BufNewFile *.cpp silent! 
    \ execute "0read" . g:template_dir . "algorithm.cpp" 
    \ | call search('void solve') | normal! kzz

" ====================================================
" 自动关联目录名，新建题目文件：
" 在 cf1234/ 目录中使用，输入题号
" ====================================================
function! NewContestProblem()
    " 提取当前工作目录名称作为比赛ID
    " getcwd() 获取当前路径，':t' (tail) 提取路径最后一部分
    let l:contest_id = fnamemodify(getcwd(), ':t')
    if l:contest_id == "CppFiles"
        echo "\n[Warning] Not in contest folder."
        return
    endif
    " 交互式输入题号 （A/B/C）
    let l:problem_letter = input("Problem Letter: ")
    " 校验输入
    if l:problem_letter == ""
        echo "\n[CANCEL] No input detected."
        return
    endif
    " 转为大写
    let l:problem_letter = toupper(l:problem_letter)
    " 拼接文件名：ID + 题号 + .cpp
    let l:filename = l:contest_id . l:problem_letter . ".cpp"
    " 打开文件
    execute "edit " . l:filename
endfunction
" 映射快捷键：Leader + n (New Problem)
nnoremap <Leader>n :call NewContestProblem()<CR>

" ====================================================
" 切换 cin>>t; 注释状态
" ====================================================
function! ToggleCinComment()
    " 存当前光标位置
    let l:pos = getpos('.')
    " 找到相关行
    if search('cin>>t;','W')
        " 判断是否以 '//' 开头，忽略开头空格
        " =~ 是正则匹配
        if getline('.') =~ '^\s*//'
            normal! ^2x
        else
            normal! I//
        endif
    endif
    " 恢复光标位置
    call setpos('.',l:pos)
endfunction
" 映射，<silent> 使命令行不显示搜索过程
nnoremap <silent> <Leader>t :call ToggleCinComment()<CR>
