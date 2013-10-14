Checking() {
	echo "$(tput setaf 3 ; tput bold )"${@}" $(tput sgr 0)"
}

OK() {
	msg="${@}"
	char=${#msg}
	col_size=$(tput cols)
	col=$(( col_size - char))
	printf '%s%*s%s\n' $(tput bold )"${@}" $col "[success]"
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

SSH_Security_check() {
	SSHD_Conf="/etc/ssh/sshd_config"
	Checking "Checking SSH Protocol Version"
	ReadOnly off $SSHD_Conf
	if grep -q -P "^[\s]*Protocol[\s]*2" "${SSHD_Conf}"; then
		OK "SSH Protocol Version is OK"
	else
		OK "Updateing Protocol Version..."
		sed -i.bkp-$(date +%F) 's/\(^\s*Protocol\s*[.0-9]*\)/# \1 \nProtocol 2\n/' ${SSHD_Conf}

		if ! grep -q -P "^[\s]*Protocol[\s]*2" "${SSHD_Conf}"; then
			sed -i.bkp-$(date +%F)  '1,/Protocol/{s/\(^\s*#\s*Protocol\s*[.,0-9]*\)/\1 \nProtocol 2\n/}' ${SSHD_Conf}
		fi
		OK "Done"
	fi	
	#ReadOnly on $SSHD_Conf

	Checking "Checking SyslogFacylity Check" 
	if grep -q  -P "^[\s]*SyslogFacility[\s]*AUTHPRIV" ${SSHD_Conf}; then
		OK "SyslogFacylity is AUTHPRIVE"
	else
		OK "Updating SyslogFacylity"	
		sed -i.bkp-$(date +%F)   '1,/SyslogFacility/{s/\(^\s*SyslogFacility\s*[A-Za-z.,]*\)/#\1 \nSyslogFacility AUTHPRIV \n/}'  ${SSHD_Conf}
		OK "Done"
		if ! grep -q  -P "^[\s]*SyslogFacility[\s]*AUTHPRIV" ${SSHD_Conf}; then
			sed -i.bkp-$(date +%F)   '1,/SyslogFacility/{s/\(^\s*#\s*SyslogFacility\s*[A-Za-z.,]*\)/\1 \nSyslogFacility AUTHPRIV \n/}'  ${SSHD_Conf}
			OK "Done"	
		fi
	fi	
}

Show_menu
read input 
case $input in 

	1) 	echo "Select SSH"
		SSH_Security_check
	;;
	*) echo "unknown Options... exit.."; exit 1 ;;

esac
 
