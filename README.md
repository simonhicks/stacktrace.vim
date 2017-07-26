# Stacktrace.vim

Stacktrace.vim provides the `:LoadStackTrace` command, which loads the locations referenced in a
Java stack trace into the quickfix list[^qf] so you can quickly jump between them. You can use it by
using visual mode to select the stacktrace in vim (e.g. in a log file), and then running
`:LoadStackTrace`. This will load all the locations it can resolve into then quickfix list and then
open the quickfix window.

Since java stacktraces don't include full path names, there is a certain amount of guesswork that
happens to try to figure out which file is being referenced. Here's how that works:

- First, it will search your ctags[^ctags] for a method that matches the method referenced in the
  stack frame. If it finds a tag with a matching method name, class name and file name, then it will
use the full path from that tag.
- If that fails, it will search your ctags for a class name that matches the class referenced in the
  stack frame. If it finds a tag with a matching class name and file name, then it will use the full
path from that tag
- Finally, if there are no matching tags, then it will fall back to using GNU `find` to locate a
  file in vim's working directory[^pwd] that matches the filename refered to in the stack frame.

[^qf]: See `:help qf` for more info on the quickfix list

[^ctags]: See `:help tags` for more info on ctags

[^pwd]: See `:help pwd` for more info on vim's working directory
