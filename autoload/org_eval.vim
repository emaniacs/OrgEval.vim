" ==============================================================================
" File:       org_eval.vim
" Description: vim plugin for evaluating source blocks in org files
" Maintainer: Alexander Goussas <agoussas@espol.edu.ec>
" License: TODO
" ==============================================================================

" Global options {{{

if !exists("g:org_eval_start_src") " {{{{
  let g:org_eval_start_src = '#+begin_src'
endif " }}}
if !exists("g:org_eval_end_src") " {{{
  let g:org_eval_end_src   = '#+end_src'
endif " }}}
if !exists("g:org_eval_tmp_file") " {{{
  let g:org_eval_tmp_file  = tempname()
endif " }}}
if !exists("g:org_eval_edit_file") " {{{
  " Needs to end in org for the keybinds
  let g:org_eval_edit_file = tempname() . '.org'
endif " }}}
if !exists("g:org_eval_run_cmd") " {{{
  let g:org_eval_run_cmd = {
        \ 'python': 'python3',
        \ 'clojure': 'clojure',
        \ 'haskell': 'runhaskell',
        \ 'sh': 'sh',
        \ 'bash': 'bash',
        \ 'awk': 'awk -f',
        \ 'java': 'java --source 11',
        \ 'c': 'tcc -run',
        \}
endif " }}}

" }}}

" Helper functions {{{

function! s:getRange() abort " {{{
  " save cursor position
  normal! mq

  " Flags:
  " c -- accept match at cursor position
  " b -- search backward instead of forward
  " W -- do not wrap around eof
  let start = search('\c^\s*'.g:org_eval_start_src, "cbW")
  let end   = search('\c^\s*'.g:org_eval_end_src, "cW")

  " restore cursor position
  normal! 'q

  " check we are in range
  if end <= start || end < line('.')
      \ || (start == 0 && getline(start) !~ g:org_eval_start_src)
    return [-1, "Nothing to do here"]
  else
    return [start, end]
  endif
endfunction " }}}

function! s:getLang(lnum) abort " {{{
  let matches = matchlist(getline(a:lnum), '\c^\s*'.g:org_eval_start_src.'\s\+\(\w\+\)')

  " No :lang in source block header
  if len(matches) < 2
    return ""
  else
    return matches[1]
  endif
endfunction " }}}

function! s:getSrcBlock() abort " {{{
  let [start, end] = s:getRange()

  if start < 0
    echo end
    return {}
  else
    let lines = []
    for lnum in range(start+1, end-1)
      call add(lines, getline(lnum))
    endfor
    return {'start': start, 'end': end, 'lines': lines}
  endif
endfunction " }}}

function! s:cleanStr(str) abort " {{{
  return substitute(a:str, "\n", "", "g")
endfunction " }}}

function! s:writeSrcBlock(block) abort " {{{
  call writefile(a:block, g:org_eval_tmp_file)
endfunction " }}}

function! s:isEditing() abort " {{{
  if !exists("s:editing")
    let s:editing = 0
  endif
  return s:editing
endfunction

" }}}

" }}}

" Public API {{{

function! org_eval#OrgEdit() abort " {{{
  let block = s:getSrcBlock()

  if !empty(block)
    " set the editing state to true
    let s:editing = 1

    " prepare editing buffer with the contents of the source block
    " set filetype to the source block language for a better experience
    let lang  = s:getLang(block['start'])
    call s:writeSrcBlock(block['lines'])
    execute "normal! :vsp " . g:org_eval_edit_file . "\<cr>"
    execute "normal! :set filetype=" . lang . "\<cr>"
    normal! ggdG

    " Save edited source block starting line number for writing the edits later
    let s:edit_start = block['start']
    let s:edit_end   = block['end']
    execute "normal! :r " . g:org_eval_tmp_file . "\<cr>"
  endif
endfunction " }}}

function! org_eval#OrgFinishEdit() abort " {{{
  if !s:isEditing()
    echo 'Not editing a source block!'
    return
  endif

  " set editing state to false
  let s:editing = 0
  let delete_start = s:edit_start + 1
  let delete_end   = s:edit_end - 1
  " Save the edit buffer
  execute "normal! :wq\<cr>"
  " Delete previous src block
  execute "normal! " . delete_start . "G"
  execute "normal! d" . delete_end . "G"
  " Write new block
  call append(s:edit_start, readfile(g:org_eval_edit_file))
endfunction " }}}

function! org_eval#OrgToggleEdit() abort " {{{
  if s:isEditing()
    call org_eval#OrgFinishEdit()
  else
    call org_eval#OrgEdit()
  endif
endfunction
" }}}

function! org_eval#OrgEval() abort " {{{
  let block = s:getSrcBlock()

  if !empty(block)
    let lang  = s:getLang(block['start'])
    let cmd   = get(g:org_eval_run_cmd, lang, "")
    if !empty(cmd)
      call s:writeSrcBlock(block['lines'])
      let result = s:cleanStr(system(cmd . ' ' . g:org_eval_tmp_file))
      call append(block['end'], 'RESULT: ' . result)
    else
      if empty(lang)
        echo 'Language not specified'
      else
        echo 'Language not supported'
      endif
    endif
  endif
endfunction " }}}

" }}}
