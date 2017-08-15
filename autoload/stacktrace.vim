if exists("g:done_stacktrace_autoload")
  finish
endif
let g:done_stacktrace_autoload = 1

function! s:find_file_path(classAndMethod, filename)
  let parts = split(a:classAndMethod, '\.')
  let package = join(parts[0:-3], '.')
  let class = substitute(parts[-2], '\$\d\d*$', '', '')
  let method = parts[-1]
  " Look for a tag that matches the method and class precisely
  for matchingTag in taglist(method)
    let tagFile = matchingTag['filename']
    let tagClass = (has_key(matchingTag, 'class') ? matchingTag['class'] : matchingTag['interface'])
    if (matchingTag['kind'] == 'm') && (matchingTag['name'] == method) && (tagClass == class) && (a:filename == fnamemodify(tagFile, ':t'))
      return tagFile
    endif
  endfor
  " Look for a tag that matches the just the class
  for matchingTag in taglist(class)
    let tagFile = matchingTag['filename']
    let tagClass = ''
    if has_key(matchingTag, 'class')
      let tagClass = matchingTag['class']
    elseif has_key(matchingTag, 'interface')
      let tagClass = matchingTag['interface']
    else
      let tagClass = matchingTag['name']
    endif
    if (tagClass == class) && (a:filename == fnamemodify(tagFile, ':t'))
      return tagFile
    endif
  endfor
  " fall back to using find . -name
  let matchingFiles = split(system('find . -name ' . a:filename), "\n")
  if len(matchingFiles) == 1
    return matchingFiles[0]
  end
endfunction

" filename	name of a file; only used when "bufnr" is not present or it is invalid.
" lnum	    line number in the file
function! s:parse_stack_frame(line)
  let parts = matchlist(a:line, '^\s\s*at \([^(]*\)(\([^:]*\):\(\d*\))')
  if len(parts) > 0
    let classAndMethod = parts[1]
    let filename = parts[2]
    let path = s:find_file_path(classAndMethod, filename)
    if filereadable(path)
      return {'text': classAndMethod, 'filename': path, 'lnum': parts[3]}
    end
  endif
  return {'text': a:line}
endfunction

function! s:parse_stack_trace(lines)
  let frames = []
  for line in a:lines
    if match(line, '\s\s*at.*') != -1
      call add(frames, s:parse_stack_frame(line))
    else
      call add(frames, {'text': line})
    endif
  endfor
  return frames
endfunction

function! stacktrace#load_lines(firstLine, lastLine)
  call setqflist(s:parse_stack_trace(getline(a:firstLine, a:lastLine)))
  copen
endfunction
