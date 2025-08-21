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

  eval \$("$command" \${_args} eval -p "\$1")
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
  eval \$("$command" \${_args} eval -c)
}
EOF
    zcompile -UR $initfile
  fi

  local compfile=$1/functions/_aws-sso
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
cat <<EOF >| $compfile
#compdef aws-sso-profile aws-sso-clear

# Path to your aws-sso binary
local _aws_sso_bin="$command"

# Completion function for aws-sso-profile
_aws_sso_profile_complete() {
  local _args
  _args=\${AWS_SSO_HELPER_ARGS:- -L error}

  # Fetch profiles in CSV mode, skip header if needed
  local -a profiles
  profiles=(\$(\$_aws_sso_bin \${=_args} list --csv Profile 2>/dev/null | tail -n +2))

  _describe 'AWS SSO profiles' profiles
}

# aws-sso-profile: complete profiles
_aws-sso-profile() {
  _arguments \\
    '1:profile:_aws_sso_profile_complete'
}

# aws-sso-clear: has no arguments
_aws-sso-clear() {
  _arguments
}
EOF
    print -u2 -PR "* Detected a new version 'aws-sso'. Regenerated completions."
  fi

  source $initfile
} ${0:h}