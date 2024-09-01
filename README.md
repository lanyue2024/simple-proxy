# simple-proxy
用nginx做http代理，解决docker和huggingface不能用的问题。

[下载](https://github.com/lanyue2024/simple-proxy/archive/refs/heads/main.zip)解压，运行<gencert.bat>生成CA和证书。
双击<conf/ca.crt>安装根证书到<受信任的根证书颁发机构>，打开<nginx.exe>，代理地址是 127.0.0.1:9080。

可用：
- docker hub和docker镜像下载
- google
- huggingface
- duckduckgo搜索
- 其他列在[<hosts.txt>](https://github.com/lanyue2024/simple-proxy/blob/main/hosts.txt)

