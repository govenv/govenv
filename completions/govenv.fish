function __fish_govenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'govenv' ]
    return 0
  end
  return 1
end

function __fish_govenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c govenv -n '__fish_govenv_needs_command' -a '(govenv commands)'
for cmd in (govenv commands)
  complete -f -c govenv -n "__fish_govenv_using_command $cmd" -a "(govenv completions $cmd)"
end
