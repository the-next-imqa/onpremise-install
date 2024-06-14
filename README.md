# Offline Packages

## RHEL 8.4

### Preparing

Internet required

```sh
sudo yum repolist
sudo yum install yum-utils
```

Download RPM packages

```sh
sudo yumdownloader {package}
```

```sh
sudo yum install --releasever 8 --installroot=/home/test/repo_root --downloadonly --downloaddir=/home/test/repo git curl wget nginx haproxy proxysql redis createrepo unzip
```

#### RabbitMQ

Cloudsmith Mirror Yum Repository (https://www.rabbitmq.com/docs/install-rpm#cloudsmith)

```
## primary RabbitMQ signing key
sudo rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
## modern Erlang repository
sudo rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
## RabbitMQ server repository
sudo rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'
```

<details>
<summary>
adding `/etc/yum.repos.d/rabbitmq.repo`
</summary>

```
# In /etc/yum.repos.d/rabbitmq.repo

##
## Zero dependency Erlang RPM
##

[modern-erlang]
name=modern-erlang-el8
# uses a Cloudsmith mirror @ yum.novemberain.com in addition to its Cloudsmith upstream.
# Unlike Cloudsmith, the mirror does not have any traffic quotas
baseurl=https://yum1.novemberain.com/erlang/el/8/$basearch
        https://yum2.novemberain.com/erlang/el/8/$basearch
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/8/$basearch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[modern-erlang-noarch]
name=modern-erlang-el8-noarch
# uses a Cloudsmith mirror @ yum.novemberain.com.
# Unlike Cloudsmith, it does not have any traffic quotas
baseurl=https://yum1.novemberain.com/erlang/el/8/noarch
        https://yum2.novemberain.com/erlang/el/8/noarch
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/8/noarch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[modern-erlang-source]
name=modern-erlang-el8-source
# uses a Cloudsmith mirror @ yum.novemberain.com.
# Unlike Cloudsmith, it does not have any traffic quotas
baseurl=https://yum1.novemberain.com/erlang/el/8/SRPMS
        https://yum2.novemberain.com/erlang/el/8/SRPMS
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/8/SRPMS
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1


##
## RabbitMQ Server
##

[rabbitmq-el8]
name=rabbitmq-el8
baseurl=https://yum2.novemberain.com/rabbitmq/el/8/$basearch
        https://yum1.novemberain.com/rabbitmq/el/8/$basearch
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/rpm/el/8/$basearch
repo_gpgcheck=1
enabled=1
# Cloudsmith's repository key and RabbitMQ package signing key
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq-el8-noarch]
name=rabbitmq-el8-noarch
baseurl=https://yum2.novemberain.com/rabbitmq/el/8/noarch
        https://yum1.novemberain.com/rabbitmq/el/8/noarch
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/rpm/el/8/noarch
repo_gpgcheck=1
enabled=1
# Cloudsmith's repository key and RabbitMQ package signing key
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq-el8-source]
name=rabbitmq-el8-source
baseurl=https://yum2.novemberain.com/rabbitmq/el/8/SRPMS
        https://yum1.novemberain.com/rabbitmq/el/8/SRPMS
        https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/rpm/el/8/SRPMS
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
gpgcheck=0
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md
```

</details>

```sh
sudo yum update -y
```

```sh
sudo yum install --releasever 8 --installroot=/home/test/repo_root --downloadonly --downloaddir=/home/test/repo socat logrotate erlang rabbitmq-server
```

#### JDK 11.0.3

- Show JDK repo list
```sh
yum list java*jdk-devel
```

```sh
yum --showduplicates list java-11-openjdk-devel
```

- `11.0.3.7-2.el8_0`
- `11.0.20.0.8-2.el8`
- `11.0.23.0.9-3.el8`

```sh
yum install java-11-openjdk-devel-11.0.3.7-2.el8_0
```

#### Docker CE

```sh
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

```sh
sudo yum update -y
```

```sh
sudo yum install --releasever 8 --installroot=/home/test/repo_root --downloadonly --downloaddir=/home/test/repo docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Podman

```sh
sudo yum install --releasever 8 --installroot=/home/test/repo_root --downloadonly --downloaddir=/home/test/repo podman python3-pip
```

#### InfluxDB

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
```

### Copy file

#### Testing

> `wget` 설치 (optional: 테스트 서버에서 다운로드 받을 경우, 일반적으로 on-premise 서버에는 우리가 준비한 파일이 모두 있어야 함)
> `yum install wget`
> 고객사 설치시 제외

- 전체 패키지 다운로드 경로 `wget https://cdn.oh.camp/install/imqa-rhel-8.x-packages.tar.xz` 
- `tar` 설치파일: `wget https://cdn.oh.camp/install/tar-1.30-9.el8.x86_64.rpm`

#### Offline

아래와 같이 파일들이 준비되어 있어야 함

- 압축 유틸: `tar-1.30-9.el8.x86_64.rpm`
- 인프라 설치 패키지: `rhel8.x-imqa-packages.tar.xz`
- Node Version Manager 설치: `nvm-packed-12-18.tar.xz`
- 전체 설치 자동화 스크립트: `install.sh`

### Installation

#### `tar` 설치

in `repo`

```sh
rpm -i tar-1.30-9.el8.x86_64.rpm
```

#### 인프라 설치 패키지 압축 해제

```sh
tar -xvJf rhel8.x-imqa-packages.tar.xz
```

#### Install `createrepo`

in `repo` directory

```sh
rpm -i drpm-0.4.1-3.el8.x86_64.rpm
rpm -i createrepo_c-libs-0.17.7-6.el8.x86_64.rpm
rpm -i createrepo_c-0.17.7-6.el8.x86_64.rpm
```

createrepo --database /root/repo

#### Offline repo 추가

> `No available modular metadata for modular package` 문제 해결 [link](https://blog.naver.com/PostView.naver?blogId=websearch&logNo=223127467306)

```sh
cat > /etc/yum.repos.d/offline-imqa.repo
[offline-imqa] 
name=CentOS-8 - IMQA Repository 
baseurl=file:///root/repo 
enabled=1 
gpgcheck=0 
module_hotfixes=1
```

### 인프라 패키지 설치

- `git`, `nginx`, `haproxy`, `proxysql`, `redis`

```sh
yum --disablerepo=\* --enablerepo=offline-imqa install git nginx haproxy proxysql redis -y
``` 

- `rabbitmq`

```sh
yum --disablerepo=\* --enablerepo=offline-imqa socat logrotate erlang rabbitmq-server -y
```

- JDK 11.0.3

```sh
yum --disablerepo=\* --enablerepo=offline-imqa java-11-openjdk-devel-11.0.3.7-2.el8_0 -y
```

- `docker-ce` (optional)

```sh
yum --disablerepo=\* --enablerepo=offline-imqa docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

- `podman` (optional)
```sh
yum --disablerepo=\* --enablerepo=offline-imqa podman python3-pip -y
```


## Optional VSCode Remote Tunnel

```sh
wget https://cdn.oh.camp/install/code-1.90.0-1717530065.el8.aarch64.rpm
```