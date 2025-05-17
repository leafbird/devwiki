# Linux 캐시 메모리 정리 방법

리눅스는 성능을 위해 사용하지 않는 메모리를 캐시로 활용합니다. 그러나 테스트 중이거나 일시적으로 메모리를 해제할 필요가 있을 때 캐시를 수동으로 정리할 수 있습니다.

## 🔧 캐시 정리 명령어

```bash
sync
echo <value> > /proc/sys/vm/drop_caches
```

> 반드시 `sync` 명령을 먼저 실행하여 디스크에 쓰기 작업을 마무리한 후 캐시를 제거해야 합니다.

## 📌 drop_caches 값 설명

| 값 | 의미 |
|----|------|
| 1  | 페이지 캐시(PageCache)만 정리 |
| 2  | 디렉터리 항목 캐시(Dentries)와 inode 캐시 정리 |
| 3  | 페이지 캐시 + Dentries + inode 캐시 모두 정리 (1 + 2) |

### 예시

```bash
sync
echo 1 > /proc/sys/vm/drop_caches  # 페이지 캐시만 정리

sync
echo 2 > /proc/sys/vm/drop_caches  # inode와 dentry 캐시만 정리

sync
echo 3 > /proc/sys/vm/drop_caches  # 모든 캐시 정리
```

## ⚠️ 주의사항

- 이 명령은 **루트 권한**이 필요합니다.
- **성능 향상을 위한 캐시를 강제로 제거**하는 것이므로, 일반적인 상황에서는 사용하지 않는 것이 좋습니다.
- 서버 운영 중 자동으로 실행하는 것보다는 수동으로 필요한 시점에만 실행하는 것이 좋습니다.

## 📚 참고

- [`/proc/sys/vm/drop_caches`](https://www.kernel.org/doc/Documentation/sysctl/vm.txt)
- `sync` 명령은 캐시된 디스크 쓰기를 즉시 디스크에 기록합니다.
