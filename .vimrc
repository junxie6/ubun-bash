" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
"set nocompatible

" === [START] Vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

" let Vundle manage Vundle, required
"Plugin 'VundleVim/Vundle.vim'

"Plugin 'fatih/vim-go'
"Plugin 'Shougo/neocomplete.vim'
"Plugin 'SirVer/ultisnips'
"Plugin 'majutsushi/tagbar'
"Plugin 'jlanzarotta/bufexplorer'

" All of your Plugins must be added before the following line
"call vundle#end()            " required

filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" === [END] Vundle

"set backup		" keep a backup file
"set backupdir=~/.vimbak " controls where backup files (with ~ extension by default) go.
set directory=~/.vimbak " The 'directory' option controls where swap files go.
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
"set showmode            " show mode in status bar (insert/replace/...)
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set mouse=		" Set mouse equals to nothing stopping vim from interpreting the mouse clicks.
set noequalalways       " disable auto resize when splitting split a window.
set number              " line number
set nowrap              " do not wrap lines
set completeopt-=preview " disable scratch preview window when autocomplete popped up and selected
let loaded_matchparen = 1 " Disable highlight matched parentheses

" set tabstop=4 shiftwidth=4 softtabstop=0 noexpandtab

" set tab character that appears as 2-spaces-wide.
autocmd BufRead,BufNewFile *.php,*.module,*.html,*.twig,*.ts,*.vue,*.js,*.json,*.css,*.yml,*yaml set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd BufNewFile,BufRead,BufReadPost *.twig,*.vue set syntax=html

set backspace=indent,eol,start " allow backspacing over everything in insert mode

" reformat php code after the file is saved
" Note: You can add "silent" in front of "call" to avoid the "press enter to continue" message.
" However, it's not recommanded for PhpCsFixerFixFile because you will not be able to see the error message.
"autocmd BufWritePost *.php call PhpCsFixerFixFile()

" let vim correctly load these ecnoding files.
" vim開檔自動判斷檔案編碼先從utf-8開始
" This is a list of character encodings considered when starting
" to edit an existing file. When a file is read, Vim tries to
" use the first mentioned character encoding. If an error is detected,
" the next one in the list is tried. When an encoding is found that works,
" 'fileencoding' is set to it.
set fileencodings=utf-8,big5,euc-jp,gbk,euc-kr,utf-bom,iso8859-1

" Sets the character encoding for the file of this buffer.
" 建立新檔的時候以什麼編碼建立
set fileencoding=utf-8

" file default encoding utf-8
set encoding=utf-8

" When you don't use tmux or screen, you only need to configure your terminal
" emulators to advertise themselves as "capable of displaying 256 colors"
" by setting their TERM to xterm-256color or any comparable value that works with
" your terminals and platforms. How you do it will depend on the terminal emulator
" and is outside of the scope of your question and this answer.
"
" You don't need to do anything in Vim as it's perfectly capable to do the right thing by itself.
"
" When you use tmux or screen, those programs set their own default value for $TERM,
" usually screen, and Vim does what it has to do with the info it is given.
"
" screen-256color is the recommended color TERM for tmux. Fixing color
" problems in tmux is as easy as setting it properly and not trying to mess
" with vim-specific hacks. Frankly, all these shenanigans within one's
" ~/.vimrc are absolutely useless.
"
" Note: disabled it by Jun since 2017-10-10. There is a proper way to deal with it
"
" Reference:
" https://stackoverflow.com/questions/15375992/vim-difference-between-t-co-256-and-term-xterm-256color-in-conjunction-with-tmu/15378816#15378816
"set t_Co=256

if &diff
	colorscheme blue
	set t_Co=16
else
	colorscheme darkblue
endif

" Shougo/neocomplete.vim
"let g:acp_enableAtStartup = 0
"let g:neocomplete#enable_at_startup = 0
"let g:neocomplete#sources#syntax#min_keyword_length = 3

" Valloric/YouCompleteMe
"let g:ycm_gocode_binary_path = "$HOME/go/bin/gocode-gomod"
"let g:ycm_godef_binary_path = "$HOME/go/bin/godef"

"
let g:bufExplorerSortBy='fullpath'

"nmap <F2> :GoCoverageToggle<CR>

" <F2> PHP xdebugger - step over
noremap [12~ :py3 debugger.step_over()<CR>

" <F3> PHP xdebugger - step into
noremap [13~ :py3 debugger.step_into()<CR>

" <F4> PHP xdebugger - step out
noremap [14~ :py3 debugger.step_out()<CR>

" <F4> Toggle auto-indenting for code paste.
" Note: press ctrl-v F4 to geenerate ^[[14~
"set pastetoggle=[14~
"set pastetoggle=<F4>

" <F4> To copy a large text. Press enter. Then, press ctrl-d to end of the document.
noremap [14~ :r!cat<CR>

" <F5> Stop the highlighting for the 'hlsearch' option. It is automatically turned back on when using a search command, or setting the 'hlsearch' option.
"map ^[[15~ :nohlsearch<CR>
"noremap <F5> :nohlsearch<CR>

" <F8> toogle the tag bar
noremap <F8> :TagbarToggle<CR>

" <F11> Save the current vim sessions
noremap <F11> :mksession! ~/vim_session <cr>

" <F12> Load the saved vim sessions
noremap <F12> :source ~/vim_session <cr>

" <ctrl-j> open explore to list file in a directory
noremap <c-j> :Explore<CR>

" <ctrl-k> open BufExplorer
noremap <c-k> :BufExplorer<CR>

" <ctrl-j> auto-complete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has("gui_running")
  " view UTF-8 Characters in Gvim (GUI Vim)
  "set guifont=VeraMono:h10
  set guifont=Bitstream_Vera_Sans_Mono:h11:cANSI
  " set guifontwide acts as second fallback for regional languages.
  set guifontwide=MingLiu:h11
endif

augroup vimrc_jun_todo
	au!
	au Syntax * syn match JunTodo /\v<(FIXME|NOTE|TODO|DEBUG|OPTIMIZE):/ containedin=.*Comment,vimCommentTitle
augroup END
hi def link JunTodo Todo

" Only do this part when compiled with support for autocommands.
"if has("autocmd")
"  " Enable file type detection.
"  " Use the default filetype settings, so that mail gets 'tw' set to 72,
"  " 'cindent' is on in C files, etc.
"  " Also load indent files, to automatically do language-dependent indenting.
"  "filetype plugin indent on
"
"  " Put these in an autocmd group, so that we can delete them easily.
"  augroup vimrcEx
"  au!
"
"  " For all text files set 'textwidth' to 78 characters.
"  "autocmd FileType text setlocal textwidth=78
"  " to fix auto-wrap for long line:
"  "autocmd FileType text setlocal textwidth=0
"
"  " When editing a file, always jump to the last known cursor position.
"  " Don't do it when the position is invalid or when inside an event handler
"  " (happens when dropping a file on gvim).
"  " Also don't do it when the mark is in the first line, that is the default
"  " position when opening a file.
"  autocmd BufReadPost *
"    \ if line("'\"") > 1 && line("'\"") <= line("$") |
"    \   exe "normal! g`\"" |
"    \ endif
"
"  augroup END
"else
"  set autoindent		" always set autoindenting on
"endif " has("autocmd")

" [START] add by danny
" [command] =======================================================
" Find String, Search String.
" Open quickfix window automatically after running grep command.
" Reference: http://blog.ijun.org/2012/01/use-grep-to-search-string-in-files.html
"command! -nargs=+ Mygrep execute "silent grep! <args>" | copen

" [set] ===========================================================

" Vim will open up as many tabs as you like on startup, up to the maximum number of tabs set.
"set tabpagemax=15

" to see the tab bar all the time. Use 0 to turn off.
" Try ":verbose set showtabline?" to find out what script replaced showtabline=1 with showtabline=2
"set showtabline=2

" go to next or previous buffer
"nmap <c-h> :bp<CR>
"nmap <c-l> :bn<CR>

" adjust windows size when there are three vertically split windows
"nmap <c-e> <c-w>60><c-w>l<c-w>30>

" [vmap] ===========================================================
" comment and uncomment lines
vnoremap ,c I//<ESC>

" [imap] ===========================================================

" [abbreviation] ==================================================
"iab cc ###
"iab cd ### [DEBUG]
iab Init Initialize

let g:vdebug_options = {}
let g:vdebug_options["port"] = 9009 " xdebug's default port is 9000. But, php-fpm uses port 9000 as well.

" Trim the trailing white spaces
fun! TrimWhitespace()
    let l:save = winsaveview()
    %s/\t/    /ge
    %s/\s\+$//e
    call winrestview(l:save)
endfun

" Format JavaScript codes. Run the following command to install:
" $ npm install js-beautify --save-dev
" Note: If a function already exists with the same name as you want to create, the "!" will tell it to overwrite the previously-existing function.
fun! FormatJavaScript()
    let l:save = winsaveview()
    %!node ./node_modules/js-beautify/js/bin/js-beautify.js
    w
    call winrestview(l:save)
endfun

fun! FormatHTML()
    let l:save = winsaveview()
    %!node ./node_modules/js-beautify/js/bin/html-beautify.js
    w
    call winrestview(l:save)
endfun

fun! FormatCSS()
    let l:save = winsaveview()
    %!node ./node_modules/js-beautify/js/bin/css-beautify.js
    w
    call winrestview(l:save)
endfun

" vim-markdown
let g:vim_markdown_folding_disabled = 1

" vim-go
" use gopls for autocompletion by default in Vim8
" NOTE: https://stackoverflow.com/questions/35837990/how-to-trigger-omnicomplete-auto-completion-on-keystrokes-in-insert-mode
" NOTE: https://stackoverflow.com/questions/24100896/vim-go-autocompletion-not-working
" NOTE: :verbose setlocal omnifunc?
" NOTE: https://octetz.com/posts/vim-as-go-ide
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
"let g:go_highlight_fields = 1
let g:go_highlight_format_strings = 1
"let g:go_highlight_function_calls = 1
"let g:go_highlight_function_parameters = 1
"let g:go_highlight_functions = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_operators = 1
"let g:go_highlight_string_spellcheck = 1
"let g:go_highlight_types = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_variable_declarations = 1
let g:go_metalinter_command = 'golangci-lint'

" disable vim-go :GoDef short cut (gd)
" " this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0

" prompt autocomplete automatically
"au filetype go inoremap <buffer> . .<C-x><C-o>
" [END] add by danny

"let g:LanguageClient_serverCommands = {
"  \ 'c': ['clangd-7'],
"  \ }

" -------------------------------------------------------------------------------------------------
" coc.nvim default settings
" -------------------------------------------------------------------------------------------------

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
"set updatetime=300
" don't give |ins-completion-menu| messages.
"set shortmess+=c
" always show signcolumns
"set signcolumn=yes

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

