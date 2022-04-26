# code reference:
# [1]: https://hex.moe/p/aaafb04f/
# [2]: https://github.com/namnamir/configurations-and-security-hardening/blob/main/DDNS.md

# Offial documents: https://api.cloudflare.com/

# information Settings
email=youremail@email.com
global_token=
zone_name=
dns_record=
dns_record_ipv6=
# zone_id could be found in your dns size webpage
zone_id=
# network interface
NT="eth0"

# Do some check before running
# Check if already running
if ps ax | grep $0 | grep -v $$ | grep bash | grep -v grep; then
    echo -e "\033[0;31m [-] The script is already running."
    exit 1
fi

# Check jq installed
check_jq=$(which jq)
if [ -z "${check_jq}" ]; then
  	echo -e "\033[0;31m [-] jq not installed. jq must be created first!"
  	exit
fi

# get your ipv4 ip with ifconfig
ipv4=$(ifconfig $NT | grep "inet addr" | awk '{ print $2}' | awk -F: '{ print $2}')

# ipv6 not usable now
ipv6=$(curl -s -X GET -6 https://ifconfig.co)

# write down IPv4 and/or IPv6
if [ $ipv4 ]; then echo -e "\033[0;32m [+] Your public IPv4 address: $ipv4"; else echo -e "\033[0;33m [!] Unable to get any public IPv4 address."; fi
if [ $ipv6 ]; then echo -e "\033[0;32m [+] Your public IPv6 address: $ipv6"; else echo -e "\033[0;33m [!] Unable to get any public IPv6 address."; fi

# get your dns_record id
dns_record_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$dns_record" \
     -H "Content-Type:application/json" \
     -H "X-Auth-Key:$global_token" \
     -H "X-Auth-Email:$email" \
     | jq -r '{"result"}[] | .[0] | .id'
     )

# write down your dns_record_id
if [ $dns_record_id ]   
then
    echo -e "\033[0;32m [+] Your dns record ipv4 id : $dns_record_id"
    if [ $ipv4 ]
    then
        # get your current record first
        dns_record_a_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$dns_record"  \
                                   -H "Content-Type: application/json" \
                                   -H "X-Auth-Email: $email" \
                                   -H "X-Auth-Key: $global_token"
                             )
        dns_record_a_ip=$(echo $dns_record_a_id |  jq -r '{"result"}[] | .[0] | .content')
        # only update the record if neccessary
        if [ $dns_record_a_ip != $ipv4 ]
        then
            curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_id" \
                -H "Content-Type:application/json" \
                -H "X-Auth-Key:$global_token" \
                -H "X-Auth-Email:$email" \
                --data '{"type":"A","name":"'$dns_record'","content":"'$ipv4'","ttl":1,"proxied":false}' \
                | jq -r '.errors'
            # write the result
            echo -e "\033[0;32m [+] Updated: The IPv4 is successfully set on Cloudflare as the A Record with the value of: $ipv4"
        else
            echo -e "\033[0;37m [~] No change: The current IPv4 address matches Cloudflare"
        fi
    fi
else 
    echo -e "\033[0;33m [!] Unable to get your dns record ipv4 id."; 
fi

# get your dns_record id
dns_record_ipv6_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=AAAA&name=$dns_record_ipv6" \
     -H "Content-Type:application/json" \
     -H "X-Auth-Key:$global_token" \
     -H "X-Auth-Email:$email" \
     | jq -r '{"result"}[] | .[0] | .id'
     )

# write down your dns_record_id
if [ $dns_record_ipv6_id ]; 
then 
    echo -e "\033[0;32m [+] Your dns record ipv6 id : $dns_record_ipv6_id"
    # check if there is any IP version 6
    if [ $ipv6 ]
    then
        dns_record_aaaa_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=AAAA&name=$dns_record_ipv6"  \
                                    -H "Content-Type: application/json" \
                                    -H "X-Auth-Email: $email" \
                                    -H "X-Auth-Key: $global_token"
                            )
        # if the IPv6 exist
        dns_record_aaaa_ip=$(echo $dns_record_aaaa_id | jq -r '{"result"}[] | .[0] | .content')
        if [ $dns_record_aaaa_ip != $ipv6 ]
        then
            # change the AAAA record
            curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_ipv6_id" \
                -H "Content-Type:application/json" \
                -H "X-Auth-Key:$global_token" \
                -H "X-Auth-Email:$email" \
                --data '{"type":"AAAA","name":"'$dns_record_ipv6'","content":"'$ipv6'","ttl":1,"proxied":false}' \
                | jq -r '.errors'
            # write the result
            echo -e "\033[0;32m [+] Updated: The IPv6 is successfully set on Cloudflare as the AAAA Record with the value of: $ipv6"
        else
            echo -e "\033[0;37m [~] No change: The current IPv6 address matches Cloudflare."
        fi
    fi
else 
    echo -e "\033[0;33m [!] Unable to get your dns record ipv6 id."; 
fi

