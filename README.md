# exception.vim

Vim plugin for tracing exceptions thrown by VimL scripts.  The most recent
exceptions are parsed and displayed in the QuickFix window.


## Usage

Call `exception#trace()` to display the call stack for the most recent
exceptions.  After that, use the QuickFix commands to move through the stack.

You could also create a command:

```vim
command! WTF call exception#trace()
```


## Useful VimL dev plugins

- [vim-lookup](https://github.com/mhinz/vim-lookup)
- [helpful.vim](https://github.com/tweekmonster/helpful.vim)
