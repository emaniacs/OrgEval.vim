" ==============================================================================
" File:       OrgEval.vim
" Description: vim plugin for evaluating source blocks in org files
" Maintainer: Alexander Goussas <agoussas@espol.edu.ec>
" License: TODO
" ==============================================================================

" Init {{{

if exists('loaded_org_eval')
    finish
endif
let loaded_org_eval = 1

" }}}
" Commands {{{

command! -nargs=0 OrgEval call org_eval#OrgEval()
command! -nargs=0 OrgEdit call org_eval#OrgEdit()
command! -nargs=0 OrgFinishEdit call org_eval#OrgFinishEdit()

" }}}
" Mappings {{{

if !exists('g:org_eval_map_keys')
    let g:org_eval_map_keys = 1
endif

if g:org_eval_map_keys
  autocmd BufNewFile,BufRead *.org nnoremap <buffer> <C-c><C-c> :call org_eval#OrgEval()<cr>
  autocmd BufNewFile,BufRead *.org nnoremap <buffer> <C-c><C-e> :call org_eval#OrgEdit()<cr>
  autocmd BufNewFile,BufRead *.org nnoremap <buffer> <C-c><C-f> :call org_eval#OrgFinishEdit()<cr>
  autocmd BufNewFile,BufRead *.org nnoremap <buffer> <C-c>' :call org_eval#OrgToggleEdit()<cr>
endif

" }}}
