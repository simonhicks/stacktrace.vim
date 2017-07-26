if exists("g:done_stacktrace_plugin")
  finish
endif
let g:done_stacktrace_plugin = 1

command! -nargs=0 -range LoadStackTrace call stacktrace#load_lines(<line1>, <line2>)
