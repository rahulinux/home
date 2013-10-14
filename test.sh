Checking() {
    msg="${@}"
    char=${#msg}
    col_size=$(( $(tput cols) - 50))
    col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput setaf 3 ; tput bold )"${@}" $col "[  checks ]"
    tput sgr 0
}

OK() {
	msg="${@}"
	char=${#msg}
	col_size=$(( $(tput cols) - 50))
	col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput bold )"${@}" $col "[ success ]"
	tput sgr 0
}


Show_menu() {

cat <<_EOF

	1. SSH Security Check


_EOF
}

ReadOnly() {
	local on_off=$1
	conf=$2
	case $1 in 
		on) chattr +i $conf ;;
		off) chattr -i $conf ;;
	esac

}

ChecknAdd() {
    local input_string=${1}
    local config_file=${2}
    local grep_search_pattern="$(echo "${input_string}" |\
                                sed -ne 's/\(\S*\) \([A-Za-z0-9.]*\)/^[ ^\\t]*\1*[ ^\\t]*\2/p' )" 
    local sed_pattern_1=$(  echo "${input_string}" |\
                            sed -ne 's/\(\S*\) \([A-Za-z0-9.]*\)/ \"\s\/\\(^\\s*\1\\s*[.0-9]*\\\)\/# \
                            \\1\\n\1 \2\\n\/\"/p')
    local sed_patter_2=$( echo $input_string |\
                          sed -ne 's/\(\S*\) \([A-Za-z0-9.]*\)/\"1\,\/\1\/\{s\/\\(\^\\s*#\\s*\1\\s* \
                          [,.0-9]*\\\)\/\\1 \\n\1 \2\\n\/\}" /p')

   if grep -q -P "${grep_search_pattern}" $config_file ; then
        echo "Option ${input_string} Already Configured"
   else
        OK "Option ${input_string} Updating...."
        echo sed -i.bkp-$(date +%F) $sed_pattern_1 $config_file | sh

        if ! grep -q -P "${grep_search_pattern}" $config_file ; then
           echo sed -i.bkp-$(date +%F) ${sed_patter_2} $config_file | sh
           OK 'Done'
        fi
    fi

}


SSH_Security_check() {
	SSHD_Conf="/etc/ssh/sshd_config"
	Checking "Checking SSH Protocol Version"
	ReadOnly off $SSHD_Conf

    ChecknAdd "Protocol 2" $SSHD_Conf	
	#ReadOnly on $SSHD_Conf

	Checking "Checking SyslogFacylity Check"
    ChecknAdd "SyslogFacility AUTHPRIV" $SSHD_Conf
}

Show_menu
read input 
case $input in 

	1) 	echo "Select SSH"
		SSH_Security_check
	;;
	*) echo "unknown Options... exit.."; exit 1 ;;

esac
 
