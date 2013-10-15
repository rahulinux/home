Checking() {
    msg="${@}"
    char=${#msg}
    col_size=$(( $(tput cols) - 45))
    col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput setaf 3 ; tput bold )"${@}" $col "[   OK    ]"
    tput sgr 0
}

OK() {
	msg="${@}"
	char=${#msg}
	col_size=$(( $(tput cols) - 45))
	col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput bold )"${@}" $col "[ success ]"
	tput sgr 0
}

Warning() {
	msg="${@}"
	char=${#msg}
	col_size=$(( $(tput cols) - 45))
	col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput setaf 1; tput bold )"${@}" $col "[ warning ]"
	tput sgr 0
}

Show_menu() {
clear
cat <<_EOF
    ------------------------------------
    |              Menu                |
    ------------------------------------
    |   1. SSH Security Check          |
    |   2. TCP Wrapper                 |
    ------------------------------------


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
    local restruck_sting_handle_backslash=$( echo ${input_string} | sed 's/\(\/\)/\\\//g' )
    local sed_pattern_1=$(  echo "${restruck_sting_handle_backslash}" |\
                            sed -ne 's/\(\S*\) \([A-Za-z0-9.\\\/]*\)/\"\s\/\\(^\\s*\1\\s*[.0-9A-Za-z\\\/]*\
                            \\\)\/#\\1\\n\1 \2\\n\/\"/p')
    local sed_patter_2=$(   echo "${restruck_sting_handle_backslash}" |\
                            sed -ne 's/\(\S*\)\([A-Za-z0-9.\\\/]*\)/\"1\,\/\1\/\{s\/\\(\^\\s*#\\s*\1\
                            \\s*[,.0-9A-Za-z\\\/]*\\\)\/\\1 \\n\1 \2\\n\/\}" /p' )

    [[ -z $config_file ]] && { Warning "Error: Config file not Specified.."; exit 1; };

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

    Checking "SSH LogLevel Check"
    ChecknAdd "LogLevel INFO"  $SSHD_Conf

    Checking "SSH LoginGraceTime Check"
    ChecknAdd "LoginGraceTime 2m" $SSHD_Conf

    Checking "SSH PermitRootLogin Check"
    ChecknAdd "PermitRootLogin no" $SSHD_Conf

    Checking "SSH MaxAuthTries Check"
    ChecknAdd "MaxAuthTries 3" $SSHD_Conf

    Checking "SSH PermitEmptyPasswords Check"
    ChecknAdd "PermitEmptyPasswords no" $SSHD_Conf

    Checking "SSH PasswordAuthentication Check"
    ChecknAdd "PasswordAuthentication no" $SSHD_Conf

    Checking "SSH ClientAliveInterval Check"
    ChecknAdd "ClientAliveInterval 7m" $SSHD_Conf

    Checking "SSH ClientAliveCountMax Check"
    ChecknAdd "ClientAliveCountMax 3" $SSHD_Conf

    Checking "SSH MaxStartups Check"
    ChecknAdd "MaxStartups 4" $SSHD_Conf

    Checking "SSH Banner Check"
    ChecknAdd "Banner /etc/issue.ssh" $SSHD_Conf
}

Show_menu
read input 

case $input in

    1)  echo "Select SSH"
        SSH_Security_check  ;;
    2)  echo "TCP Wrapper"
        TCPWrapper_check    ;;

    *) echo "unknown Options... exit.."; exit 1 ;;

esac
