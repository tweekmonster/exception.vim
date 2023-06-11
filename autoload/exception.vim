" exception#trace() {{{1
"
" Parses errors from :messages and displays them in the quickfix window.
" Since the last error is often not the origin error, a list of consecutive
" exceptions are collected.
function! exception#trace() abort
  let lines = reverse(s:execute('silent messages'))
  if len(lines) < 3
    return
  endif

  let i = 0
  let e = 0
  let errors = []

  while i < len(lines)
    if i > 1 && lines[i] =~# '^Error detected while processing function '
          \ && lines[i-1] =~? '^line\s\+\d\+'
      let lnum = matchstr(lines[i-1], '\d\+')
      let stack = printf('%s[%d]', lines[i][41:-2], lnum)
      call add(errors, {
            \  'stack': reverse(split(stack, '\.\.')),
            \  'msg': lines[i-2],
            \ })
      let e = i
    endif

    let i += 1
    if e && i - e > 3
      break
    endif
  endwhile

  if empty(errors)
    return
  endif

  let errlist = []

  for err in errors
    let nw = len(len(err.stack))
    let i = 0
    call add(errlist, {
          \   'text': err.msg,
          \   'lnum': 0,
          \   'bufnr': 0,
          \   'type': 'E',
          \ })

    for t in err.stack
      let func = matchstr(t, '.\{-}\ze\[\d\+\]$')
      let lnum = str2nr(matchstr(t, '\[\zs\d\+\ze\]$'))

      let verb = s:execute('silent! verbose function '.func)
      if len(verb) < 2
        continue
      endif

      let src = fnamemodify(matchstr(verb[1], 'Last set from \zs.\+\ze\%( line \d\+\)'), ':p')
      if !filereadable(src)
        continue
      endif

      let pat = '\C^\s*fu\%[nction]!\?\s\+'
      if func =~# '^<SNR>'
        let pat .= '\%(<\%(sid\|SID\)>\|s:\)'
        let func = matchstr(func, '<SNR>\d\+_\zs.\+')
      endif
      let pat .= func.'\>'

      for line in readfile(src)
        let lnum += 1
        if line =~# pat
          break
        endif
      endfor

      if !empty(src) && !empty(func)
        let fname = fnamemodify(src, ':.')
        call add(errlist, {
              \   'text': printf('%*s. %s', nw, '#'.i, t),
              \   'filename': fname,
              \   'lnum': lnum,
              \   'type': 'I',
              \ })
      endif

      let i += 1
    endfor
  endfor

  if !empty(errlist)
    call setqflist(errlist, 'r')
    copen
  endif
endfunction

" s:execute() {{{1
function! s:execute(cmd) abort
  if exists('*execute')
    return split(execute(a:cmd), "\n")
  endif

  redir => output
  execute a:cmd
  redir END
  return split(output, "\n")
endfunction

" }}}
" vim: set fdm=marker ts=2 sw=2 et :
