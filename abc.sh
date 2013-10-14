SSHD_Conf="/etc/ssh/sshd_config"
Checking "Checking SSH Protocol Version"
ReadOnly off $SSHD_Conf

ChecknAdd() {
    local input_string="${1}"
    local config_file=${2}
    local grep_search_pattern="$(echo "${input_string}" |\
                                sed -ne 's/\(\S*\) \([0-9]\)/^[ ^\\t]*\1*[ ^\\t]*\2/p' )" 
    local sed_pattern_1="$(echo $input_string |\
                          sed -ne 's/\(\S*\) \([0-9]\)/ \"\s\/\\(^\s*\1\\s*[.0-9]*\\\)\/# \\1\\n\1 \2\\n\/\" /p')"

    local sed_patter_2="$(echo $input_string |\
                          sed -ne 's/\(\S*\) \([0-9]\)/ \"1\,\/\1\/\{s\/\\(\^\\s*#\\s*\1\\s*[,.0-9]*\\\)\/\\1 \\n\1 \2\\n\/\}" /p')"

   if grep -q -P "${grep_search_pattern}" $config_file ; then
        echo "Option ${input_string} Already Configured"
   else
        echo "Option ${input_string} Updating...."
        sed -i.bkp-$(date +%F) "${sed_pattern_1}" $config_file

        if ! grep -q -P "${grep_search_pattern}" $config_file ; then
            sed -i.bkp-$(date +%F) "${sed_patter_2}" $config_file
        fi
        echo 'Done'
    fi

}
ChecknAdd "Protocol 2" /etc/sshd/sshd_conf
#if grep -q -P "^[\s]*Protocol[\s]*2" "${SSHD_Conf}"; then
#    OK "SSH Protocol Version is OK"
#else
#    OK "Updateing Protocol Version..."
#    sed -i.bkp-$(date +%F) 's/\(^\s*Protocol\s*[.0-9]*\)/# \1 \nProtocol 2\n/' ${SSHD_Conf}
#                            "s/(^s*Protocol\s*[.0-9]*\)/# \1 \nProtocol 2\n/"
#
#    if ! grep -q -P "^[\s]*Protocol[\s]*2" "${SSHD_Conf}"; then
#        sed -i.bkp-$(date +%F)  
#        '1,/Protocol/{s/\(^\s*#\s*Protocol\s*[.,0-9]*\)/\1 \nProtocol 2\n/}' ${SSHD_Conf}
#        "1,/Protocol/{s/\(^\s*#\s*Protocol\s*[,.0-9]*\)/\1 \nProtocol 2\n/}"
#        fi
#        OK "Done"
#fi
