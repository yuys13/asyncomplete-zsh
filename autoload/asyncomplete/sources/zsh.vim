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

    let l:matches = []
    for item in split(l:out, '\r\n')
      let l:pieces = split(item, ' -- ')
      let l:candidate = {'word': l:pieces[0], 'dup': 1, 'menu': '[zsh]'}

      if len(l:pieces) > 1
        let l:candidate['info'] = l:pieces[1]
      endif

      call add(l:matches, l:candidate)
    endfor

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
    return
  endif

  let l:F = { channel -> s:callback(channel, a:opt, a:ctx, l:startcol) }
  let l:job = job_start(l:cmd, { 'close_cb': l:F })
endfunction

function! s:callback(channel, opt, ctx, startcol) abort
  let l:matches = []

  " workaround
  if a:ctx['typed'] =~# '-'
    if ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
      let l:line = trim(ch_read(a:channel))
      let l:line = substitute(l:line, '^' . a:ctx['typed'], '', '')
      let l:pieces = split(l:line, ' -- ')
      let l:candidate = {'word': l:pieces[0], 'dup': 1, 'menu': '[zsh]'}

      if len(l:pieces) > 1
        let l:candidate['info'] = l:pieces[1]
      endif

      call add(l:matches, l:candidate)
    endif
  endif

  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:line = ch_read(a:channel)
    let l:pieces = split(l:line, ' -- ')
    let l:candidate = {'word': l:pieces[0], 'dup': 1, 'icase': 1, 'menu': '[zsh]'}

    if len(l:pieces) > 1
      let l:candidate['info'] = l:pieces[1]
    endif

    call add(l:matches, l:candidate)
  endwhile

  call asyncomplete#complete(a:opt['name'], a:ctx, a:startcol, l:matches)
endfunction

