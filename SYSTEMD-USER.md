# System daemon user bus

<https://wiki.archlinux.org/title/systemd/User>

systemd는 사용자 제어 하에 서비스들을 관리할 수 있는 사용자별 systemd 인스턴스를 제공하여, 사용자가 자신의 유닛을 시작, 중지, 활성화 및 비활성화할 수 있게 한다.

## Pam 사용

아래 스크립트로 `pam`이 사용중인지 체크

```sh
grep UsePAM /etc/ssh/sshd_config 
```

UsePam no 인 경우

## systemd-journald

`/etc/systemd/journald.conf`수정 `Storage` to `persistent`

## Service 등록


```sh
$ systemctl --user deamon-reload  # Service 파일 동기화
$ systemctl --user enable {service}@imqa.service  # 부팅 시 실행
$ systemctl --user start {service}@imqa.service  # Service 시작
$ systemctl --user restart {service}@imqa.service  # Service 재시작
$ systemctl --user stop {service}@imqa.service  # Service 종료
$ systemctl --user status {service}@imqa.service  # Service 상태 확인
```
root가 실행하는 service는 `/etc/systemd/system`에 등록되어 운영되나, 사용자가 실행하는 service는 사용자의 홈 경로(`~/.config/systemd/user`)에 등록되어 운영된다.

## 로그아웃 시 Service 유지

- systemd 사용자 인스턴스는 사용자 세션이 시작될 때 함께 시작되며 세션이 종료될 때 함께 종료된다. [archwiki](https://wiki.archlinux.org/title/Systemd/User#Automatic_start-up_of_systemd_user_instances)
- 서비스를 부팅시 실행하고 시스템 종료와 함께 종료시키고 싶을 때에는 [archwiki](https://wiki.archlinux.org/title/Systemd/User#Automatic_start-up_of_systemd_user_instances)에서 소개하는 loginctl를 사용한다.
- root 계정에서 `enable-linger` 옵션을 주어 `loginctl`으로 해당 계정을 lingering 한다.

```sh
enable-linger [USER...], disable-linger [USER...]
    Enable/disable user lingering for one or more users. If enabled for a specific user, a
    user manager is spawned for the user at boot and kept around after logouts. This
    allows users who are not logged in to run long-running services. Takes one or more
    user names or numeric UIDs as argument. If no argument is specified, enables/disables
    lingering for the user of the session of the caller.
```

```sh
$ loginctl enable-linger username
```
- 만약 `dbus`가 동작하고 있지 않다면, root 계정에서 `systemctl enable dbus` 그리고 `systemctl start dbus`로 시작해준다.


## IMQA


### Default

- `$HOME/.config/systemd/user`: 시스템 데몬 위치
- `$HOME/.pid`: 프로세스 위치
- `$HOME/.sbin`: 실행 시스템 바이너리 위치
- `$HOME/.bin`: 바이너리 위치
- `$HOME/.logs`: 로그 위치
- `$HOME/.scripts`: 커스텀 스크립트 위치

### MySQL

- `sudo mv /usr/sbin/mysqld $HOME/.sbin`
- 