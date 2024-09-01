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

if ! [ -f "${out}/ca.crt" ]; then
    echo "生成根证书CA..."
    ./certstrap --depot-path="$out" init --passphrase="" --expires="$ca_expires" --common-name="$ca"
    echo
fi

echo "生成自签名证书，包含以下域名："
echo
while IFS='' read -r line; do
    if [[ "$line" =~ ^[\*|[:alnum:]].*$ ]]; then
	echo $line
        hosts="${hosts}${line},"
    fi
done < "$hosts_file"
allhosts="${hosts}localhost"
echo

rm -f ${out}/${cert}.*

./certstrap --depot-path="$out" request-cert --passphrase="" --common-name="$cert" --domain="$allhosts"
./certstrap --depot-path="$out" sign "$cert" --passphrase="" --expires="$cert_expires" --CA="$ca"
echo

