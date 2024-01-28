## SETUID

출처 : http://blog.naver.com/ca66044/120007045439

★ SETUID에 대하여....

유닉스/리눅스 시스템에서의 파일모드는 아래와 같이 세자리 숫자로 되어 있다. 
즉, 755(-rwxr-xr-x), 644(-rw-r--r--)와 같은 조합을 이루고 있다.

그런데 여기에 한자리의 숫자가 맨앞에 하나더 있다. 즉, 755의 경우 0755가 되는 것이다. 
맨 앞의 숫자는 다음과 같은 의미를 가진다(0은 아무런 설정도 되어있지 않음을 의미).

SetUID 
4 
이 부분이 설정되면 실행시 그 파일의 소유자 권한으로 
실행된다. 따라서 누가 그 파일을 실행하게 되면 실행시 실제로 그 파일의 소유권을 가진 
유저가 실행하는 것과 같은 의미를 가지게 된다. 설정되면 권한에서 소유자의 실행(x)부분이 
"s", "S"로 나타나게 된다.

SetGID 
2 
이 부분이 설정되면 실행시 그 파일의 소유그룹의 권한으로 실행된다. 위와 같은 의미이고, 
설정되면 권한에서 소유그룹의 실행(x)부분이 "s", "S"로 나타난다.

Sticky bit 
1 
이 부분은 해당 파일의 소유자에게만 쓰기 권한을 제공한다. 이 부분이 설정되면 
해당파일, 디렉토리는 public에게 쓰기가 되어있다고 하더라도 해당파일의 소유자가 아니면 
쓰기에 관련된 작업을 할 수 없다. 
설정되면 public의 실행(x)부분이 "t", "T"로 나타난다.

[SetUID, SetGID, sticky bit의 의미]
SUID, SGID, Sticky bit의 설정과 제거는 아래와 같이 chmod 명령으로 한다.

○ SUID 
chmod u+s filename : filename 파일의 user에게(u) SUID 비트를(s) 부여한다.
or,
chmod 4*** filename : SUID 비트는 8진수로 4의 값을 갖는다. *** 자리에는 755 등과 같은 
기존의 8진수 모드 값이 오게 된다.
[ex]
위에서 xl이라는 스크립트에 SUID를 설정할 경우,
[bluesky@bluestar bluesky]# ls -l xl
-rwxr-xr-x 1 root root 2886 Apr 29 2000 xl
[bluesky@bluestar bluesky]# chmod u+s xl
[bluesky@bluestar bluesky]# ls -l
-rwsr-xr-x 1 root root 2886 Apr 29 2000 xl

이렇게 suid 비트가 설정이 되면 다른 유저가 xl이라는 스크립트를 실행할 때 루트의 권한을 
가질수 있게 된다.

○ SGID
chmod g+s filename : filename 파일의 group에게(g) SGID 비트를(s)를 부여한다.
or,
chmod 2*** filename : SGID 비트는 8진수로 2의 값을 가진다. 마찬가지로, *** 자리에는 
755와 같은 기존 8진수 모드의 값이 온다.

[ex]
위에서 xlock-exploit라는 스크립트에 SGID를 설정할 경우,
[bluesky@bluestar bluesky]# ls -l xlock-exploit
-rwxr-xr-x 1 root root 6018 Apr 29 2000 xlock-exploit
[bluesky@bluestar bluesky]# chmod g+s xlock-exploit
[bluesky@bluestar bluesky]# ls -l xlock-exploit
-rwxr-sr-x 1 root root 6018 Apr 29 2000 xlock-exploit

○ Sticky bit
chmod o+t filename : filename 파일 또는 디렉토리에 Sticky bit를 부여한다.
chmod 1*** filename : Sticky bit의 8진수 값은 1이다.

[ex]
예를 들어, 위에서 shell_scripts라는 디렉토리에 sticky bit를 설정하려고 할 경우,
[bluesky@bluestar bluesky]# ls -l shell_scripts
drwxrwxr-x 2 bluesky bluesky 1024 Apr 20 2000 shell_scripts
[bluesky@bluestar bluesky]# chmod o+t shell_scripts
[bluesky@bluestar bluesky]# ls -l shell_scripts
drwxrwxr-t 2 bluesky bluesky 1024 Apr 20 2000 shell_scripts

각각의 설정을 제거하려고 할 경우는 + 대신에 -를 사용한다.
그리고 위에서 SUID, SGID, Sticky bit 설정시 실행(x)부분에 "s", "S" 
또는 "t", "T"로 나타난다고 했는데, 소문자의 경우는 
이미 기존의 파일에 실행권한이 부여되어 있는경우에 SUID,SGID,Sticky bit를 
설정시에 나타나게 되고, 대문자(S, T)의 경우는 기존의 파일에 실행권한이 
없는 상태에서 SUID, SGID, Sticky bit를 설정할 경우에 나타나게 된다. 
즉, 대문자인 경우는 기존 파일의 권한에서 실행권한이 없는 상태에서 설정했기
때문에 SUID,SGID 등을 설정해도 실행은 되지 않는다. 즉, 대문자로 나타나는 
경우는 동작되지 않음을 의미한다.

예를 들어 아래와 같이 실행권한이 없는 suid란 파일에 SUID 비트를 설정해보면,
[bluesky@bluestar bluesky]# ls -l suid
-rw-rw-rw- 1 bluesky bluesky 2290 May 6 2000 suid <- 실행권한 없음
[bluesky@bluestar bluesky]# chmod u+s suid
[bluesky@bluestar bluesky]# ls -l suid
-rwSrw-rw- 1 bluesky bluesky 2290 May 6 2000 suid <- 대문자 S
[bluesky@bluestar bluesky]# ./suid
bash: ./suid: Permission denied

지금까지는 전반적인 내용과 설정법에 대해 알아보았는데, 그렇다면 실제로 유닉스 
시스템에서 어떻게 사용되고 있는지 알아보자.

유닉스/리눅스 시스템에서 사용자가 자신의 패스워드를 바꾸려고 할 때 
passwd(/usr/bin/passwd)란 명령을 사용한다. 이 명령을 사용하여 사용자는 
/etc/passwd란 파일을 수정하여 자신의 패스워드를 변경하게 된다.
그런데 /etc/passwd란 파일의 접근권한을 보면,
[bluesky@bluestar bluesky]# ls -l /etc/passwd
-rw-r--r-- 1 root root 930 Mar 5 04:38 /etc/passwd

즉, root 유저만 이 파일을 수정할 수가 있다. 그런데 어떻게 일반 사용자가 
이 파일을 수정하여 자신의 패스워드를 변경할 수가 있는가??

그 비밀은 passwd(/usr/bin/passwd)란 파일의 접근권한(즉, SUID)에 있다. 이 파일의 
접근권한을 보면,
[bluesky@bluestar bluesky]# ls -l /usr/bin/passwd
-r-sr-xr-x 1 root bin 58306 Apr 13 1999 /usr/bin/passwd

위와 같이 /usr/bin/passwd란 파일은 root 유저에게 SUID 비트가 설정되어 있다. 
그러므로 일반 사용자들도 이 파일을 실행하고 있는 동안에는 root의 권한을 
잠시 빌려쓸 수 있게 되고 그리하여 root 만 변경할 수 있는 파일인 /etc/passwd 파일도 
수정하여 자신의 패스워드를 변경할 수가 있는 것이다.

이번에는 Sticky bit의 사용에 대해 알아보자.
유닉스/리눅스 시스템에서 /tmp 디렉토리의 권한을 보면,
[bluesky@bluestar bluesky]# ls -l /tmp
drwxrwxrwt 15 root root 1024 Mar 8 23:27 tmp

위를 보면 /tmp 디렉토리의 권한이 1777(rwxrwxrwt)로 설정되어 있다. 
이 디렉토리가 sticky bit가 설정이 되어 있는데, 일반적으로 /tmp 디렉토리는 
많은 유저들이 임시적으로 파일을 생성하거나 복사하여 작업하는 디렉토리이다.
그런데 만약 A라는 유저가 파일을 /tmp 에 만들었는데 B라는 유저가 이 파일을 
보고 지워버린다면 어떻게 되겠는가?? 
바로 이런 불상사를 막기 위해서 /tmp 디렉토리에 sticky bit가 설정되어 있는데 
이렇게 sticky bit가 설정되어 있으면 해당 디렉토리내에서 다른 유저들이 만들어 
놓은 파일들을 보거나 실행은 가능하지만 지우거나 변경을 할 경우에는 
반드시 그 파일의 소유자의 권한이 있어야만 한다. 즉, 해당 파일의 소유자만이 
그 파일을 변경하거나 지울 수가 있는 것이다.
이러한 suid는 위와 같이 매우 유용하게 사용될 수 있는 반면 보안상으로 매우 
취약한 약점을 가지고 있다. 여기서 suid가 왜 문제가 되는지 간단한 예를 하나 들어보자.

예를 들어 시스템 관리자가 관리자용으로 따로 만든 계정이 아닌 그냥 root로 작업을 
하고 있다가 잠시 자리를 비웠다고 가정해 보자. 
이때, 이 시스템에 hacker란 계정을 가진 사람이 들어와서 아래와 같이 했다면 큰일이다.
[root@bluestar /root]# cp /bin/sh /home/hacker
[root@bluestar /root]# chmod 4775 /home/hacker/sh
[root@bluestar /root]# ls -l /home/hacker/sh
-rwsrwxr-x 1 root root 373304 Mar 23 04:05 /home/hacker/sh

위와 같이 해두면 hacker란 사용자는 다음에 자신의 계정으로 로긴한 후 이 훔친 
shell(일종의 백도어이다.)을 이용하여 언제라도 root가 될 수 있으니 얼마나 위험한 
일인가...다음은 그 과정을 보여준다.
[hacker@bluestar hacker]$ <-- hacker가 자신의 계정으로 로긴..
[hacker@bluestar hacker]$ whoami
hacker
[hacker@bluestar hacker]$ ls -l
-rwsr-xr-x 1 root root 373304 Mar 23 04:05 sh
[hacker@bluestar hacker]$ ./sh <-- root의 권한으로 shell을 실행시킴(root shell 획득...)
[hacker@bluestar hacker]#whoami(프롬프트가 $->#으로 바뀐것을 주목..)
root
이후의 일은 끔찍함 그자체.... ^_^

그러므로 시스템 관리자는 화면 잠금없이 자리를 비우는 일이 없도록 해야하며, 
수시로 아래명령으로 불필요하게 suid/sgid 설정이 되어있는 화일이 없는지 확인해야 한다. 
(보안툴을 이용해서 점검이 가능..)
[root@bluestar /root]# find / -perm -4000 -o -perm -2000 -print
위에서 SUID,SGID에 대해서 알아보았는데, 만약 중요한 실행파일들이 사용자들에게 
root의 소유이면서 suid가 설정되어 있다면 그 실행파일로 인해서 대부분의 침입자들은 
root 유저의 권한을 얻거나 시스템을 파괴하려들 것이다. 따라서 불필요한 
SUID는 제거해야 한다. 시스템에 있는 모든 SUID/SGID를 찾아내어 그러한 설정 비트들이 
왜 붙어 있는지를 따져보고 불필요한 suid, sgid라면 제거를 해야하고, 만약 전에 
없던 suid 비트가 어떤 실행파일에 설정되어 있다면 침입의 여부를 꼼꼼히 살펴보아야 할 것이다.

suid/sgid가 설정된 파일을 찾을 때는 아래와 같은 명령을 사용한다.

[bluesky@bluestar bluesky]# find / -type f ( -perm -04000 -o -perm -02000 )
or,
[bluesky@bluestar bluesky]# find / -perm -4000 -o -perm -2000 -print 2>/dev/null

이렇게 해서 나온 결과들을 보고 해당 실행파일에 불필요하게 suid/sgid가 설정이 되어 
있다면 바로 제거해야 한다. suid와 sgid는 잠재적인 보안 위험 요소이며 철저하게 감시되어야 한다.
만약 크래커가 여러분의 시스템에 사용권을 얻게되고, 특히 시스템 파일이나 월드 라이터블(World-writable) 
파일들을 변경할 수 있게되면 심각한 보안 개구멍이 존재하게 된다.(월드 라이터블이란 public 부분이 
쓰기 가능한 경우이다. 즉, "--------w-"의 권한 비트를 말한다) 
또한 월드-라이터블 디렉토리도 위험하다. 그래서 이러한 파일 및 디렉토리들도 찾아보고 왜 
"쓰기가능"으로 설정되어 있는지 따져보아야 하며 불필요한 경우에는 "쓰기가능"을 제거해 주어야 한다.
정상적인 운영에 있어서 /dev의 일부와 심볼릭 링크를 포함한 여러 파일들이 라이터블로 되어 있을 수 있다.

이러한 World-writable 파일들을 찾는 명령은 아래와 같다.
[bluesky@bluestar bluesky]# find / -perm -2 -print

또한 무소속의 파일들 또한 침입자가 시스템에 들어왔다는 징후일 수 있으므로 주인이 없거나 그룹에 
소속되어 있지 않는 파일들이 없는지 아래의 명령으로 찾아보아야 한다.
[bluesky@bluestar bluesky]# find / -nouser -o -nogroup -print

마지막으로 리모트 호스트(.rhosts) 파일들 또한 반드시 살펴보아야 한다. 시스템내의 /home 디렉토리 내의 임의의 
사용자의 디렉토리내에 이러한 파일이 있다는 것은 시스템에 암호없이 들어올 수 있는 특정 호스트가 존재한다는 것이기 
때문에 매우 위험하다.
이러한 .rhosts 파일들을 찾기위해서는 다음과 같이 한다.
[bluesky@bluestar bluesky]# find /home -name .rhosts -print
/home/bluesky/.rhosts
[bluesky@bluestar bluesky]# rm /home/bluesky/.rhosts
rm: remove `/home/bluesky/.rhosts'? y