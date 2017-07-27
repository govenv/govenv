if [[ ! -o interactive ]]; then
    return
fi

compctl -K _govenv govenv

_govenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(govenv commands)"
  else
    completions="$(govenv completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}
