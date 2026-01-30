secret.set () {
  echo -n "Enter in value for the variable '${1}': "
  eval "export $1=\$(read -s value;echo \$value)"
}