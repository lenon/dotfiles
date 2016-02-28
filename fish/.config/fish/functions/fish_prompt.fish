function fish_prompt
  set -l last_status $status
  set -l status_indicator " "

  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
  end

  #
  # settings for __fish_git_prompt
  #

  if not set -q __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_show_informative_status 1
  end

  if not set -q __fish_git_prompt_showcolorhints
    set -g __fish_git_prompt_showcolorhints 1
  end

  if not set -q __fish_git_prompt_char_stagedstate
    set -g __fish_git_prompt_char_stagedstate '+'
  end

  if not set -q __fish_git_prompt_char_dirtystate
    set -g __fish_git_prompt_char_dirtystate "*"
  end

  if not set -q __fish_git_prompt_char_untrackedfiles
    set -g __fish_git_prompt_char_untrackedfiles 'u'
  end

  if not set -q __fish_git_prompt_char_upstream_ahead
    set -g __fish_git_prompt_char_upstream_ahead '▴'
  end

  # put an exclamation mark "!" into the prompt if the last command
  # exited with an error
  if test $last_status -ne 0
    set status_indicator "!"
  end

  echo -n -s (prompt_pwd) $normal "@" $__fish_prompt_hostname \
    (__fish_git_prompt) $status_indicator "> "
end
