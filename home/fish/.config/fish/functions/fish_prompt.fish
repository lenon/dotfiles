function fish_prompt
  if test $status -eq 0
    set_color $fish_color_cwd
  else
    set_color $fish_color_error
  end

  printf '%s@%s%s> ' (prompt_pwd) $__fish_prompt_hostname (__fish_git_prompt)

  set_color normal
end
