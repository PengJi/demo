# specify the interpreter path
#!/usr/bin/env bash
#!/usr/bin/env python

# output redirection
>/dev/null 2>&1

# output stdout
> &1

# output stderr
> &2

# if
if [[ -f "/etc/os-release" ]]; then
    os_type=$(cat /etc/os-release | grep PRETTY_NAME)
    if [[ ${os_type} =~ "CentOS Linux 8" ]]; then
        echo "nm"
        return
    elif [[ ${os_type} =~ "ubuntu" ]]; then
        echo "ubuntu"
        return
    else
        echo "not found"
    fi
fi

# switch
case "$(get_network_config)" in
    eni)
        by_eni $1 $2 $3 $4
        set_default_gateway ${default_gateway_ip} ${default_gateway_eth}
        ;;
    sysconfig)
        by_sysconfig $1 $2 $3 $4
        set_default_gateway ${default_gateway_ip} ${default_gateway_eth}
        ;;
    networkmanager)
        by_nm $1 $2 $3 $4
        set_default_gateway ${default_gateway_ip} ${default_gateway_eth}
        ;;
    netplan)
        by_netplan $1 $2 $3 $4
        ;;
    *)
        echo "Unsupported network config system" >&2
        exit 1
        ;;
esac


# retry
# https://unix.stackexchange.com/questions/82598/how-do-i-write-a-retry-logic-in-script-to-keep-retrying-to-run-it-upto-5-times
for i in 1 2 3 4 5;do
    for eth_file in $(ls /sys/class/net/*/address); do
        if [ "$1" == "$(cat $eth_file)" ]; then
            interface=$(echo $eth_file | awk -F/ '{print $5}')
            break
        fi
    done
    # sleep or break
    [[ ! -z $interface ]] && break || sleep 1
done


# check whether var contains substr
if [[ $(get_os_version) =~ "CentOS Linux release 7.0" ]]; then
    grep "HWADDR" "${tmp_conf}"
    if [ $? -eq 0 ]; then
        check_cmd sed -i 's/HWADDR=.*/HWADDR='"${mac}"'/g' "${tmp_conf}"
    else
        check_cmd echo -e "HWADDR=${mac}" >> "${tmp_conf}"
    fi
fi


# split string
# first
string="hello,shell,haha"
array=(${string//,/ }) 
for var in ${array[@]}
do
  echo $var
done
# second
export IFS=","
for ntp_server in $1; do
    echo $ntp_server
done
# third
string="one,two,three,four,five"
array=(`echo $string | tr ',' ' '` ) 
for var in ${array[@]}
do
  echo $var
done


# operators order
"A ; B"  # Run A and then B, regardless of success of A
"A && B"  # Run B if A succeeded
"A || B"  # Run B if A failed
"A &"  # Run A in background.
false && echo howdy!
true && echo howdy!
howdy!
true || echo howdy!
false || echo howdy!
howdy!
