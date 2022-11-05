let s:srcfile = expand('<sfile>:p:h:h:h:h') . '/bin/capture.zsh'

function! asyncomplete#sources#zsh#completor(opt, ctx) abort
  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  let l:kw = matchstr(l:typed, '\v\S+$')
  let l:kwlen = len(l:kw)

  let l:startcol = l:col - l:kwlen

  let l:out = system(s:srcfile . ' ' . shellescape(l:typed))

  let l:words = []
  for item in split(l:out, '\r\n')
    let l:pieces = split(item, ' -- ')
    call add(l:words, l:pieces[0])
  endfor

  let l:matches = map(l:words, '{"word": v:val, "dup": 1, "icase": 1, "menu": "[zsh]"}')

  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction
