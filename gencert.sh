#!/bin/bash
# certstrap: https://github.com/square/certstrap

hosts_file="hosts.txt"
tmpfile="/tmp/hosts-tmp.txt"
out="conf"
ca="ca"
ca_expires="20 years"
cert="allname"
cert_expires="20 years"
hosts=""
map_host_file="${out}/map-host.conf"
map_addr_file="${out}/map-addr.conf"
map_sni_file="${out}/map-sni.conf"

chmod 755 nginx certstrap

if ! [ -f "${out}/ca.crt" ]; then
    echo "生成根证书CA..."
    ./certstrap --depot-path="$out" init --passphrase="" --expires="$ca_expires" --common-name="$ca"
    echo
fi

echo "生成自签名证书，包含以下域名："
echo "" > $map_host_file
echo "" > $map_addr_file
echo "" > $map_sni_file
echo
while IFS='' read -r line; do
    if [[ "$line" =~ ^[\*|[:alnum:]].*$ ]]; then
	host=$(echo $line |cut -d ',' -f 1)
	proxy_conn=$(echo $line |cut -d ',' -f 2)
	addr=$(echo $line |cut -d ',' -f 3)
	sni=$(echo $line |cut -d ',' -f 4)
        echo "$host ${proxy_conn};" >> $map_host_file
        if [ "$addr" ]; then
            echo "$host ${addr};" >> $map_addr_file
        fi
        if [ "$sni" ]; then
            echo "$host ${sni};" >> $map_sni_file
        fi

        echo $host
        hosts="${hosts}${host},"
    fi
done < "$hosts_file"
allhosts="${hosts}localhost"
echo

rm -f ${out}/${cert}.*

./certstrap --depot-path="$out" request-cert --passphrase="" --common-name="$cert" --domain="$allhosts"
./certstrap --depot-path="$out" sign "$cert" --passphrase="" --expires="$cert_expires" --CA="$ca"
echo

