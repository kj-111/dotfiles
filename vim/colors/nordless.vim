scriptencoding utf-8

" Local no-color scheme: Nord UI, mostly grayscale syntax.
" Inspired by mcchrish/vim-no-color-collections and the Nord-like nordbones idea.

set background=dark
highlight clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'nordless'

let s:none = 'NONE'
let s:bg = '#2E3440'
let s:ui0 = '#3B4252'
let s:ui1 = '#434C5E'
let s:ui2 = '#4C566A'
let s:dim = '#616E88'
let s:fg = '#D8DEE9'
let s:fg1 = '#E5E9F0'
let s:fg2 = '#ECEFF4'
let s:accent = '#88C0D0'
let s:blue = '#81A1C1'
let s:red = '#BF616A'
let s:yellow = '#EBCB8B'
let s:green = '#A3BE8C'
let s:purple = '#B48EAD'

function! s:hi(group, fg, bg, attr, ctermfg, ctermbg) abort
  let l:cmd = 'highlight ' . a:group
  let l:cmd .= ' guifg=' . a:fg . ' guibg=' . a:bg . ' gui=' . a:attr
  let l:cmd .= ' ctermfg=' . a:ctermfg . ' ctermbg=' . a:ctermbg . ' cterm=' . a:attr
  execute l:cmd
endfunction

function! s:link(group, target) abort
  execute 'highlight! link ' . a:group . ' ' . a:target
endfunction

call s:hi('Normal', s:fg, s:bg, 'NONE', 253, 236)
call s:hi('NormalFloat', s:fg, s:bg, 'NONE', 253, 236)
call s:hi('SignColumn', s:fg, s:bg, 'NONE', 253, 236)
call s:hi('EndOfBuffer', s:ui0, s:bg, 'NONE', 237, 236)
call s:hi('NonText', s:ui0, s:none, 'NONE', 237, 'NONE')
call s:hi('Conceal', s:ui1, s:none, 'NONE', 238, 'NONE')
call s:hi('Directory', s:accent, s:none, 'NONE', 110, 'NONE')
call s:hi('LineNr', s:ui1, s:bg, 'NONE', 238, 236)
call s:hi('CursorLineNr', s:ui2, s:bg, 'bold', 240, 236)
call s:hi('CursorLine', s:none, s:ui0, 'NONE', 'NONE', 237)
call s:hi('CursorColumn', s:none, s:ui0, 'NONE', 'NONE', 237)
call s:hi('ColorColumn', s:none, s:ui0, 'NONE', 'NONE', 237)
call s:hi('VertSplit', s:bg, s:bg, 'NONE', 236, 236)
call s:hi('WinSeparator', s:bg, s:bg, 'NONE', 236, 236)
call s:hi('Visual', s:none, s:ui1, 'NONE', 'NONE', 238)
call s:hi('VisualNOS', s:none, s:ui1, 'NONE', 'NONE', 238)
call s:hi('Search', s:fg2, s:blue, 'NONE', 255, 109)
call s:hi('IncSearch', s:fg2, s:blue, 'NONE', 255, 109)
call s:hi('CurSearch', s:fg2, s:blue, 'NONE', 255, 109)
call s:hi('MatchParen', s:purple, s:none, 'bold,underline', 139, 'NONE')
call s:hi('Folded', s:dim, s:none, 'NONE', 241, 'NONE')
call s:hi('FoldColumn', s:accent, s:bg, 'NONE', 110, 236)
call s:hi('Title', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('Question', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Error', s:red, s:none, 'underline', 167, 'NONE')
call s:hi('ErrorMsg', s:red, s:none, 'NONE', 167, 'NONE')
call s:hi('WarningMsg', s:yellow, s:none, 'NONE', 222, 'NONE')
call s:hi('MoreMsg', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('ModeMsg', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('SpecialKey', s:blue, s:none, 'NONE', 109, 'NONE')
call s:hi('Underlined', s:blue, s:none, 'underline', 109, 'NONE')
call s:hi('StatusLine', s:fg, s:ui1, 'NONE', 253, 238)
call s:hi('StatusLineNC', s:fg, s:ui0, 'NONE', 253, 237)
call s:hi('WildMenu', s:yellow, s:ui0, 'NONE', 222, 237)
call s:hi('Pmenu', s:fg, s:bg, 'NONE', 253, 236)
call s:hi('PmenuSel', s:fg2, s:ui2, 'NONE', 255, 240)
call s:hi('PmenuSbar', s:none, s:ui0, 'NONE', 'NONE', 237)
call s:hi('PmenuThumb', s:none, s:ui2, 'NONE', 'NONE', 240)
call s:hi('SpellBad', s:red, s:none, 'underline', 167, 'NONE')
call s:hi('SpellCap', s:accent, s:none, 'underline', 110, 'NONE')
call s:hi('SpellLocal', s:blue, s:none, 'underline', 109, 'NONE')
call s:hi('SpellRare', s:purple, s:none, 'underline', 139, 'NONE')
call s:hi('DiffAdd', s:green, s:none, 'reverse', 150, 'NONE')
call s:hi('DiffChange', s:yellow, s:none, 'reverse', 222, 'NONE')
call s:hi('DiffDelete', s:red, s:none, 'reverse', 167, 'NONE')
call s:hi('DiffText', s:purple, s:none, 'reverse', 139, 'NONE')
call s:hi('YankHighlight', s:none, s:blue, 'NONE', 'NONE', 109)

call s:hi('Comment', s:dim, s:none, 'italic', 241, 'NONE')
call s:hi('Constant', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('String', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Character', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Number', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Boolean', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Float', s:fg1, s:none, 'NONE', 254, 'NONE')
call s:hi('Identifier', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('Function', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('Statement', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('PreProc', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('Type', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('Special', s:fg2, s:none, 'NONE', 255, 'NONE')
call s:hi('Delimiter', s:fg, s:none, 'NONE', 253, 'NONE')
call s:hi('Todo', s:yellow, s:none, 'bold', 222, 'NONE')

call s:link('Conditional', 'Statement')
call s:link('Repeat', 'Statement')
call s:link('Label', 'Statement')
call s:link('Operator', 'Statement')
call s:link('Keyword', 'Statement')
call s:link('Exception', 'Statement')
call s:link('Include', 'PreProc')
call s:link('Define', 'PreProc')
call s:link('Macro', 'PreProc')
call s:link('PreCondit', 'PreProc')
call s:link('StorageClass', 'Type')
call s:link('Structure', 'Type')
call s:link('Typedef', 'Type')
call s:link('SpecialChar', 'Special')
call s:link('Tag', 'Special')
call s:link('SpecialComment', 'Special')
call s:link('Debug', 'Special')
call s:link('Ignore', 'NonText')

call s:hi('markdownHeadingDelimiter', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('markdownH1', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('markdownH2', s:fg2, s:none, 'bold', 255, 'NONE')
call s:hi('markdownH3', s:fg1, s:none, 'bold', 254, 'NONE')
call s:hi('markdownCode', s:fg1, s:ui0, 'NONE', 254, 237)
call s:hi('markdownCodeBlock', s:fg1, s:ui0, 'NONE', 254, 237)
call s:hi('markdownLinkText', s:blue, s:none, 'underline', 109, 'NONE')
call s:link('htmlLink', 'markdownLinkText')
call s:link('mkdLink', 'markdownLinkText')

let g:terminal_ansi_colors = [
      \ s:ui0, s:red, s:green, s:yellow,
      \ s:blue, s:purple, s:accent, s:fg1,
      \ s:ui2, s:red, s:green, s:yellow,
      \ s:blue, s:purple, s:accent, s:fg2
      \ ]
