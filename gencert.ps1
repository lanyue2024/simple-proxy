# 生成根证书及签署证书
# certstrap: https://github.com/square/certstrap
# 依赖文件hosts.txt，certstrap
# 生成nginx的map文件

$ca = "ca"
$ca_expires = "20 years"
$cert = "allname"
$cert_expires = "10 years"
$out = "conf"
$hosts_file = "hosts.txt"
$hosts = ""

$simple_host = ""
$proxy_conn = ""
$addr = ""
$sni = ""
$map_host_file = "${out}/map-host.conf"
$map_addr_file = "${out}/map-addr.conf"
$map_sni_file = "${out}/map-sni.conf"


if ( ! (Test-Path "certstrap.exe" -PathType Leaf)) { 
    Echo "certstrap.exe 不存在，无法进行" 
    Echo ""
    Pause
    exit
}

if ( ! (Test-Path "${out}/${ca}.crt" -PathType Leaf)) { 
    Echo "生成根证书CA..." 
    certstrap.exe --depot-path="$out" init --passphrase="" --expires="$ca_expires" --common-name="$ca"
    Echo ""
}

Echo "生成自签名证书..."
if ( ! (Test-Path "$hosts_file" -PathType Leaf)) { 
    Echo "${hosts_file} 不存在，无法进行"
    Echo ""
    Pause
    exit
}

# 清空nginx的map文件
"" | Out-File $map_host_file -Encoding ascii
"" | Out-File $map_addr_file -Encoding ascii
"" | Out-File $map_sni_file -Encoding ascii

# \w = [a-zA-Z_0-9] 匹配 example.com, *.example.com
$regex = "^[\*|\w].*"
foreach($line in Get-Content $hosts_file) {
    if($line -match $regex){
        $parts = $line -split ","
        
        $simple_host = $parts[0]
        $proxy_conn = $parts[1]
        $addr = $parts[2]
        $sni = $parts[3]
        
        $hosts = $hosts + $simple_host + ","
        "$simple_host ${proxy_conn};" | Out-File $map_host_file -Append -Encoding ascii
        
        if ($addr -match '\s*\S+') {
            "$simple_host ${addr};" | Out-File $map_addr_file -Append -Encoding ascii
        }
        if ($sni -match '\s*\S+') {
            "$simple_host ${sni};" | Out-File $map_sni_file -Append -Encoding ascii
        }
    }
}
$allhosts = $hosts + "localhost"
Echo ""
Echo "包含以下域名："
Echo $allhosts
Echo ""

Remove-Item "${out}/${cert}.*" -Force
certstrap.exe --depot-path="$out" request-cert --passphrase="" --common-name="$cert" --domain="$allhosts"
certstrap.exe --depot-path="$out" sign "$cert" --passphrase="" --expires="$cert_expires" --CA="$ca" 

Echo ""
Pause
