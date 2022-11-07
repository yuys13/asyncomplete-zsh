let s:srcfile = expand('<sfile>:p:h:h:h:h') . '/bin/capture.zsh'

function! asyncomplete#sources#zsh#completor(opt, ctx) abort
  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  let l:kw = matchstr(l:typed, '\v\S+$')
  let l:kwlen = len(l:kw)

  let l:startcol = l:col - l:kwlen

  let l:cmd = s:srcfile . ' ' . l:typed

  if has('nvim')
    let l:out = system(l:cmd)

    let l:words = []
    for item in split(l:out, '\r\n')
      let l:pieces = split(item, ' -- ')
      call add(l:words, l:pieces[0])
    endfor

    let l:matches = map(l:words, '{"word": v:val, "dup": 1, "icase": 1, "menu": "[zsh]"}')

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
    return
  endif

  let l:F = { channel -> s:callback(channel, a:opt, a:ctx, l:startcol) }
  let l:job = job_start(l:cmd, { 'close_cb': l:F })
endfunction

function! s:callback(channel, opt, ctx, startcol) abort
  let l:words= []
  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:line = ch_read(a:channel)
    let l:pieces = split(l:line, ' -- ')
    call add(l:words, l:pieces[0])
  endwhile

  let l:matches = map(l:words, '{"word": v:val, "dup": 1, "icase": 1, "menu": "[zsh]"}')

  call asyncomplete#complete(a:opt['name'], a:ctx, a:startcol, l:matches)
endfunction

