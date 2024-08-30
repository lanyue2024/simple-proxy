# 用certstrap生成根证书及签署证书
# certstrap: https://github.com/square/certstrap
# 签署的证书域名从文件hosts.txt读取

$ca = "ca"
$ca_expires = "20 years"
$cert = "allname"
$cert_expires = "10 years"
$out = "conf"
$hosts_file = "hosts.txt"

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

$hosts = ""
# \w = [a-zA-Z_0-9] 匹配 example.com, *.example.com
$regex = "^[\*|\w].*"
foreach($line in Get-Content $hosts_file) {
    if($line -match $regex){
        $hosts = "$hosts" + "${line},"
    }
}
$allhosts = "${hosts}" + "localhost"
Echo ""
Echo "包含以下域名："
Echo "$allhosts"
Echo ""

Remove-Item "${out}/${cert}.*" -Force
certstrap.exe --depot-path="$out" request-cert --passphrase="" --common-name="$cert" --domain="$allhosts"
certstrap.exe --depot-path="$out" sign "$cert" --passphrase="" --expires="$cert_expires" --CA="$ca" 


Echo ""
Pause
