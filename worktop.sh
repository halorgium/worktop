__worktop_cd() {
  local cwd

  # Get the first argument or the pwd.
  cwd="${1:-"$PWD"}"

  while : ; do

    # if no cwd, in home or /
    if [[ -z "$cwd" || "$HOME" = "$cwd" || "/" = "$cwd" ]] ; then

      # if no longer dir with .worktoprc
      if [[ -n "${worktop_worktoprc_cwd:-""}" ]] ; then
        __worktop_uncd
      fi

      break
    else
      if [[ -f "$cwd/.worktoprc" ]] ; then
        if [[ "${worktop_worktoprc_cwd:-""}" != "$cwd" ]] ; then
          worktop_worktoprc_cwd="$cwd"

          source "$cwd/.worktoprc"

          return 0
        fi
        break

      else
        cwd="$(dirname "$cwd")"
      fi
    fi
  done

  return $?
}

__worktop_uncd() {
  if [[ -n "${worktop_original_WORKTOP_NAME:-""}" ]] ; then
    export WORKTOP_NAME=${worktop_original_WORKTOP_NAME}
    unset worktop_original_WORKTOP_NAME
  else
    unset WORKTOP_NAME
  fi

  if [[ -n "${worktop_original_GEM_HOME:-""}" ]] ; then
    export GEM_HOME=${worktop_original_GEM_HOME}
    unset worktop_original_GEM_HOME
  else
    unset GEM_HOME
  fi

  if [[ -n "${worktop_original_GEM_PATH:-""}" ]] ; then
    export GEM_PATH=${worktop_original_GEM_PATH}
    unset worktop_original_GEM_PATH
  else
    unset GEM_PATH
  fi

  if [[ -n "${worktop_original_BUNDLE_PATH:-""}" ]] ; then
    export BUNDLE_PATH=${worktop_original_BUNDLE_PATH}
    unset worktop_original_BUNDLE_PATH
  else
    unset BUNDLE_PATH
  fi

  if [[ -n "${worktop_original_PATH:-""}" ]] ; then
    export PATH=${worktop_original_PATH}
    unset worktop_original_PATH
  else
    echo "Should not be unsetting PATH"
    return 1
  fi

  unset worktop_worktoprc_cwd
}

worktop() {
  if [[ ! -n "${WORKTOP_DIR:-""}" ]]; then
    echo "No WORKTOP_DIR specified" >&2
    return 1
  fi

  local base_dir
  base_dir=${WORKTOP_DIR}

  if [[ ! -n "${1:-""}" ]]; then
    if [[ -n "${WORKTOP_NAME:-""}"  ]] ; then
      echo "Currently on worktop [${WORKTOP_NAME}]" >&2
      echo >&2
    fi

    echo "Provide a worktop name" >&2
    return 1
  fi

  local name
  name="${1}"
  shift

  if [[ "${name}" == '--exit' ]]; then
    if [[ -n "${WORKTOP_NAME:-""}"  ]] ; then
      echo "Leaving worktop [${WORKTOP_NAME}]" >&2
      __worktop_uncd
      return 0
    else
      echo "Not in a worktop" >&2
      return 1
    fi
  fi

  echo "Changing to worktop [${name}]" >&2

  local gem_dir
  gem_dir="${base_dir}/${name}"

  # WORKTOP_NAME GEM_HOME GEM_PATH BUNDLE_PATH PATH
  if [ -n "${WORKTOP_NAME:-""}" ]; then
    worktop_original_WORKTOP_NAME="${WORKTOP_NAME}"
  fi

  if [ -n "${GEM_HOME:-""}" ]; then
    worktop_original_GEM_HOME="${GEM_HOME}"
  fi

  if [ -n "${GEM_PATH:-""}" ]; then
    worktop_original_GEM_PATH="${GEM_PATH}"
  fi

  if [ -n "${BUNDLE_PATH:-""}" ]; then
    worktop_original_BUNDLE_PATH="${BUNDLE_PATH}"
  fi

  if [ -n "${PATH:-""}" ]; then
    worktop_original_PATH="${PATH}"
  fi

  export WORKTOP_NAME="${name}"
  export GEM_HOME="${gem_dir}"
  export GEM_PATH=""
  export BUNDLE_PATH="${GEM_HOME}"
  export PATH="${gem_dir}/bin:${PATH}"

  if [ -n "${1:-""}" ]; then
    $@
  else
    return $?
  fi
}

if [[ -n "${ZSH_VERSION:-""}" ]] ; then
  autoload is-at-least
  if is-at-least 4.3.4 >/dev/null 2>&1; then
    # On zsh, use chpwd_functions
    chpwd_functions=( "${chpwd_functions[@]}" __worktop_cd )
  else
    cd() {
      builtin cd "$@"
      result=$?
      __worktop_cd
      return $result
    }
  fi
else
  cd() {
    builtin cd "$@"
      result=$?
    __worktop_cd
    return $result
  }
fi
