# asyncomplete-zsh.vim

Provide zsh autocompletion source for [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)

## Installing

```vim
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'yuys13/asyncomplete-zsh.vim'
```

### Registration

```vim
call asyncomplete#register_source({
      \ 'name': 'zsh',
      \ 'allowlist': ['zsh'],
      \ 'triggers': {'*': ['-']},
      \ 'completor': function('asyncomplete#sources#zsh#completor')
      \ })
```

## Original code

It includes
[zsh-capture-completion](https://github.com/Valodim/zsh-capture-completion) and
[deoplete-zsh](https://github.com/deoplete-plugins/deoplete-zsh)
