# aws-sso-profile and aws-sso-clear, generated from aws-sso's own helpers, so they
# follow each release. The completions are in functions/.
() {
  # The real binary, not a version manager's shim: its path is what gets compared and
  # baked into the helpers.
  local command=${commands[aws-sso]}
  if [[ -z $command || $command == */shims/* ]]; then
    if (( ${+commands[mise]} )); then
      command=$(mise which aws-sso 2>/dev/null)
    elif (( ${+commands[asdf]} )); then
      command=$(asdf which aws-sso 2>/dev/null)
    fi
  fi
  [[ -x $command ]] || return 1
  typeset -g _zim_aws_sso=$command

  # Generated again when aws-sso or this file changes.
  local initfile=$1/aws-sso-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command || $initfile -ot $1/init.zsh ]]; then
    local script
    script=$($command setup completions --source --shell zsh 2>/dev/null)
    if [[ -z $script ]]; then
      print -u2 -R "zim-aws-sso-cli: '$command setup completions --source' printed nothing; needs aws-sso 2"
      return 1
    fi
    # `compdef` and `complete -C` need compinit and bashcompinit at this point;
    # functions/ has the completions instead.
    print -rl -- ${${(f)script}:#(compdef|complete) *} >| $initfile
    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}
