(( ${+commands[aws-sso]} || ${+commands[asdf]} && ${+functions[_direnv_hook]} )) && () {

  local command=${commands[aws-sso]:-"$(${commands[asdf]} which aws-sso 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating init file
  local initfile=$1/aws-sso-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command ]]; then
cat <<EOF >| $initfile
aws-sso-profile() {
  local _args=\${AWS_SSO_HELPER_ARGS:- -L error}
  if [ -n "\${AWS_PROFILE}" ]; then
    echo "Unable to assume a role while AWS_PROFILE is set"
    return 1
  fi

  if [ -z "\$1" ]; then
    echo "Usage: aws-sso-profile <profile>"
    return 1
  fi

  eval \$($command \${=_args} eval -p "\$1")
  if [ "\${AWS_SSO_PROFILE}" != "\$1" ]; then
    return 1
  fi
}

aws-sso-clear() {
  local _args=\${AWS_SSO_HELPER_ARGS:- -L error}
  if [ -z "\${AWS_SSO_PROFILE}" ]; then
    echo "AWS_SSO_PROFILE is not set"
    return 1
  fi
  eval \$($command \${=_args} eval -c)
}
EOF
    zcompile -UR $initfile
  fi

  local compfile=$1/functions/_aws-sso-profile
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
cat <<EOF >| $compfile
#compdef aws-sso-profile

# Completion function for aws-sso-profile
_aws_sso_profile_complete() {
  # Path to your aws-sso binary
  local _aws_sso_bin=$command
  local _args
  _args=\${AWS_SSO_HELPER_ARGS:- -L error}

  # Fetch profiles in CSV mode, skip header if needed
  local -a profiles
  profiles=(\$(\$_aws_sso_bin \${=_args} list --csv Profile 2>/dev/null | tail -n +2))

  if (( \${#profiles[@]} > 0 )); then
    # Escape colons in profile names for _values
    local -a escaped_profiles
    local profile
    for profile in \$profiles; do
      escaped_profiles+=(\${profile//:/\\\\:})
    done
    _values 'AWS SSO profiles' \$escaped_profiles
  else
    _message 'No AWS SSO profiles found'
  fi
}

# aws-sso-profile: complete profiles
_aws-sso-profile() {
  _arguments \\
    '1:AWS SSO profile:_aws_sso_profile_complete'
}
EOF
    print -u2 -PR "* Detected a new version 'aws-sso'. Regenerated completions."
  fi

  source $initfile
} ${0:h}
