# RAGFlow 시나리오 데이터 증분 동기화 가이드

> 2026-02-17 작성. 이미 벡터화된 시나리오 데이터(docx ~1400개)를 효율적으로 최신 상태로 유지하는 방법.

## 목차

- [배경 및 문제](#배경-및-문제)
- [RAGFlow 데이터 구조 이해](#ragflow-데이터-구조-이해)
- [Dataset 구성 전략](#dataset-구성-전략)
- [증분 동기화 설계](#증분-동기화-설계)
- [RAGFlow API 정리](#ragflow-api-정리)
- [동기화 스크립트 구현](#동기화-스크립트-구현)
- [크론 스케줄링](#크론-스케줄링)
- [트러블슈팅 및 주의사항](#트러블슈팅-및-주의사항)

---

## 배경 및 문제

- 시나리오 docx 파일 약 1400개가 벡터화되어 RAGFlow에 저장됨
- 시나리오팀이 수시로 파일 추가/수정/삭제
- 언제 어떤 파일이 변경될지 예측 불가
- **매일 전체 재업로드는 비효율** — 1400개 docx 파싱+임베딩은 수십 분~수 시간 소요
- 변경분만 처리하는 **증분 동기화**가 필요

---

## RAGFlow 데이터 구조 이해

### 핵심 개념

```
Dataset (= Knowledge Base)
  └── Document 1 (scenario_001.docx)    ← 파일 1개 = Document 1개
  │     └── Chunk 1-1
  │     └── Chunk 1-2
  │     └── ...
  └── Document 2 (scenario_002.docx)
  │     └── Chunk 2-1
  │     └── ...
  └── ... (1400개)
```

- **Dataset** = 테이블/컬렉션 같은 상위 단위. 임베딩 모델, 파서 설정 등을 공유.
- **Document** = 업로드된 파일 1개. 내부적으로 여러 Chunk로 분할됨.
- **Chunk** = 실제 벡터 검색의 최소 단위. 텍스트 + 벡터 쌍으로 저장.

### Document 수정 불가

RAGFlow는 **Document 단위 수정(in-place update)을 지원하지 않음.**
변경된 파일은 반드시 **삭제 → 재업로드** 순서로 처리해야 함.

---

## Dataset 구성 전략

### ✅ 정답: Dataset 1개에 Document 1400개

```
Dataset: "시나리오"
  └── scenario_001.docx
  └── scenario_002.docx
  └── ... (1400개 전부)
```

- 검색 시 하나의 벡터 인덱스에서 유사도 검색 → 효율적
- 증분 동기화도 Document 단위로 깔끔하게 관리 가능

### ❌ 하면 안 되는 것

| 방식 | 문제점 |
|---|---|
| docx 1개당 Dataset 1개 (1400개 Dataset) | 관리 불가능. 검색 시 전체 Dataset 순회 필요. |
| 모든 docx를 하나의 txt로 합치기 | 증분 업데이트 불가능. 하나 바뀌면 전체 재처리. |
| 용도 구분 없이 모든 데이터 하나의 Dataset | 시나리오/기획서/캐릭터설정 등 성격이 다르면 분리 권장 |

### Dataset을 나누는 기준

데이터 **성격이 완전히 다를 때**만 분리:

```
Dataset: "시나리오"     ← docx 1400개 (시나리오 대사/스토리)
Dataset: "기획서"       ← 시스템 기획, 밸런스 수치 등
Dataset: "캐릭터설정"   ← 캐릭터 프로필, 세계관 설정
```

챗봇(Assistant)에서 필요한 Dataset만 선택적으로 연결할 수 있어서, 검색 정확도와 속도 모두 향상.

---

## 증분 동기화 설계

### 핵심 원리

1. 시나리오 파일들의 **MD5 해시**를 기록해둔다
2. 주기적으로 현재 파일 상태와 기록을 비교한다
3. **변경된 파일만** RAGFlow API로 처리한다:
   - 신규 파일 → 업로드
   - 수정된 파일 → 삭제 후 재업로드
   - 삭제된 파일 → RAGFlow에서도 삭제

### 상태 파일 (sync_state.json)

파일별 해시와 RAGFlow document ID를 매핑:

```json
{
  "scenarios/episode_001.docx": {
    "hash": "a1b2c3d4e5f6...",
    "doc_id": "ragflow-document-uuid-here",
    "synced_at": "2026-02-17T03:00:00Z"
  },
  "scenarios/episode_002.docx": {
    "hash": "f6e5d4c3b2a1...",
    "doc_id": "ragflow-document-uuid-here",
    "synced_at": "2026-02-17T03:00:00Z"
  }
}
```

### 동기화 흐름

```
[크론 트리거 (매일 새벽 3시)]
    │
    ├── 시나리오 폴더 스캔
    │     └── 각 파일 MD5 해시 계산
    │
    ├── sync_state.json 로드
    │
    ├── 비교
    │     ├── 신규 파일 (state에 없음) → 업로드
    │     ├── 변경 파일 (해시 불일치) → 삭제 + 재업로드
    │     └── 삭제 파일 (폴더에 없음) → RAGFlow에서 삭제
    │
    ├── RAGFlow API 호출
    │
    ├── sync_state.json 업데이트
    │
    └── 로그 출력 (추가 N개, 수정 N개, 삭제 N개)
```

**변경 없으면 API 호출 0회** — 매일 돌려도 부담 없음.

---

## RAGFlow API 정리

> RAGFlow API 문서: https://ragflow.io/docs/dev/http_api_reference

### 인증

모든 요청에 API 키 필요:

```
Authorization: Bearer <your-api-key>
```

API 키는 RAGFlow 웹 UI → 프로필 → API Key에서 발급.

### Dataset(Knowledge Base) 관련

```bash
# Dataset 목록 조회
GET /api/v1/datasets

# Dataset 상세 조회
GET /api/v1/datasets/{dataset_id}
```

### Document 관련 (핵심)

```bash
# Document 목록 조회
GET /api/v1/datasets/{dataset_id}/documents

# Document 업로드 (파일)
POST /api/v1/datasets/{dataset_id}/documents
Content-Type: multipart/form-data
# Body: file=@scenario.docx

# Document 삭제
DELETE /api/v1/datasets/{dataset_id}/documents
# Body: {"ids": ["doc_id_1", "doc_id_2"]}

# Document 파싱 시작 (업로드 후 반드시 호출!)
POST /api/v1/datasets/{dataset_id}/chunks
# Body: {"document_ids": ["doc_id"]}

# Document 파싱 상태 확인
GET /api/v1/datasets/{dataset_id}/documents
# 응답의 각 document에 progress_msg, run 필드로 상태 확인
```

### ⚠️ 중요: 업로드 후 파싱은 별도 호출

Document 업로드만으로는 벡터화되지 않음!
업로드 후 **반드시 파싱(chunking + embedding) API를 호출**해야 검색 가능해짐.

```
업로드 → (파일 저장만 됨) → 파싱 호출 → (청킹 + 임베딩) → 검색 가능
```

---

## 동기화 스크립트 구현

### Python 스크립트 (sync_ragflow.py)

```python
#!/usr/bin/env python3
"""
RAGFlow 시나리오 데이터 증분 동기화 스크립트

사용법:
    python sync_ragflow.py --scenario-dir /path/to/scenarios --dataset-id <id>

환경변수:
    RAGFLOW_API_KEY: RAGFlow API 키
    RAGFLOW_BASE_URL: RAGFlow 서버 URL (기본: http://localhost:9380)
"""

import os
import sys
import json
import hashlib
import logging
import argparse
import time
from pathlib import Path
from datetime import datetime, timezone

import requests

# ============================================================
# 설정
# ============================================================

RAGFLOW_BASE_URL = os.environ.get("RAGFLOW_BASE_URL", "http://localhost:9380")
RAGFLOW_API_KEY = os.environ.get("RAGFLOW_API_KEY", "")
STATE_FILE = "sync_state.json"
LOG_FILE = "sync_ragflow.log"

# 파싱 완료 대기 설정
PARSE_POLL_INTERVAL = 10   # 초
PARSE_TIMEOUT = 600        # 최대 대기 시간 (초)

# ============================================================
# 로깅 설정
# ============================================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout),
    ],
)
logger = logging.getLogger(__name__)

# ============================================================
# 유틸리티
# ============================================================

def file_md5(filepath: str) -> str:
    """파일의 MD5 해시를 계산"""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def load_state(state_path: str) -> dict:
    """동기화 상태 파일 로드"""
    if os.path.exists(state_path):
        with open(state_path, "r") as f:
            return json.load(f)
    return {}


def save_state(state_path: str, state: dict):
    """동기화 상태 파일 저장"""
    with open(state_path, "w") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)


def api_headers() -> dict:
    return {
        "Authorization": f"Bearer {RAGFLOW_API_KEY}",
    }

# ============================================================
# RAGFlow API 래퍼
# ============================================================

def upload_document(dataset_id: str, filepath: str) -> str | None:
    """
    Document 업로드. 성공 시 document ID 반환.
    """
    url = f"{RAGFLOW_BASE_URL}/api/v1/datasets/{dataset_id}/documents"
    filename = os.path.basename(filepath)

    with open(filepath, "rb") as f:
        files = {"file": (filename, f)}
        resp = requests.post(url, headers=api_headers(), files=files)

    if resp.status_code == 200 and resp.json().get("code") == 0:
        doc_id = resp.json()["data"][0]["id"]
        logger.info(f"  업로드 성공: {filename} → doc_id={doc_id}")
        return doc_id
    else:
        logger.error(f"  업로드 실패: {filename} → {resp.text}")
        return None


def delete_documents(dataset_id: str, doc_ids: list[str]) -> bool:
    """
    Document 삭제 (복수 가능).
    """
    url = f"{RAGFLOW_BASE_URL}/api/v1/datasets/{dataset_id}/documents"
    resp = requests.delete(url, headers=api_headers(), json={"ids": doc_ids})

    if resp.status_code == 200 and resp.json().get("code") == 0:
        logger.info(f"  삭제 성공: {doc_ids}")
        return True
    else:
        logger.error(f"  삭제 실패: {doc_ids} → {resp.text}")
        return False


def start_parsing(dataset_id: str, doc_ids: list[str]) -> bool:
    """
    Document 파싱(청킹 + 임베딩) 시작.
    """
    url = f"{RAGFLOW_BASE_URL}/api/v1/datasets/{dataset_id}/chunks"
    resp = requests.post(url, headers=api_headers(), json={"document_ids": doc_ids})

    if resp.status_code == 200 and resp.json().get("code") == 0:
        logger.info(f"  파싱 시작: {len(doc_ids)}개 문서")
        return True
    else:
        logger.error(f"  파싱 시작 실패: {resp.text}")
        return False


def wait_for_parsing(dataset_id: str, doc_ids: list[str]):
    """
    파싱 완료까지 대기 (폴링).
    완료 여부만 로깅하고 진행. 실패해도 다음 동기화에서 재시도 가능.
    """
    logger.info(f"  파싱 완료 대기 중... (최대 {PARSE_TIMEOUT}초)")
    start = time.time()

    while time.time() - start < PARSE_TIMEOUT:
        url = f"{RAGFLOW_BASE_URL}/api/v1/datasets/{dataset_id}/documents"
        resp = requests.get(url, headers=api_headers(), params={"limit": 100})

        if resp.status_code != 200:
            time.sleep(PARSE_POLL_INTERVAL)
            continue

        docs = {d["id"]: d for d in resp.json().get("data", {}).get("docs", [])}
        all_done = True

        for did in doc_ids:
            doc = docs.get(did, {})
            run_status = doc.get("run", "")
            if run_status not in ("2", "DONE", "done"):  # RAGFlow 버전별 값 다를 수 있음
                all_done = False
                break

        if all_done:
            logger.info(f"  파싱 완료! ({time.time() - start:.0f}초 소요)")
            return

        time.sleep(PARSE_POLL_INTERVAL)

    logger.warning(f"  파싱 타임아웃 ({PARSE_TIMEOUT}초). 다음 동기화에서 확인.")

# ============================================================
# 메인 동기화 로직
# ============================================================

def sync(scenario_dir: str, dataset_id: str, state_path: str):
    """
    증분 동기화 실행.
    """
    logger.info("=" * 60)
    logger.info(f"동기화 시작: {datetime.now(timezone.utc).isoformat()}")
    logger.info(f"시나리오 디렉토리: {scenario_dir}")
    logger.info(f"Dataset ID: {dataset_id}")

    # 1. 현재 파일 스캔
    current_files = {}
    for f in Path(scenario_dir).rglob("*.docx"):
        rel_path = str(f.relative_to(scenario_dir))
        # 임시 파일(~$...) 제외
        if os.path.basename(rel_path).startswith("~$"):
            continue
        current_files[rel_path] = file_md5(str(f))

    logger.info(f"현재 파일 수: {len(current_files)}")

    # 2. 이전 상태 로드
    prev_state = load_state(state_path)
    logger.info(f"이전 상태 파일 수: {len(prev_state)}")

    # 3. 변경 감지
    to_add = []      # 신규 파일
    to_update = []   # 수정된 파일
    to_delete = []   # 삭제된 파일

    for rel_path, current_hash in current_files.items():
        if rel_path not in prev_state:
            to_add.append(rel_path)
        elif prev_state[rel_path]["hash"] != current_hash:
            to_update.append(rel_path)

    for rel_path in prev_state:
        if rel_path not in current_files:
            to_delete.append(rel_path)

    logger.info(f"변경 감지: 추가={len(to_add)}, 수정={len(to_update)}, 삭제={len(to_delete)}")

    if not to_add and not to_update and not to_delete:
        logger.info("변경 없음. 종료.")
        return

    # 4. 삭제 처리
    if to_delete:
        delete_ids = [prev_state[p]["doc_id"] for p in to_delete if "doc_id" in prev_state[p]]
        if delete_ids:
            delete_documents(dataset_id, delete_ids)
        for p in to_delete:
            del prev_state[p]

    # 5. 수정 처리 (삭제 → 재업로드)
    if to_update:
        update_delete_ids = [prev_state[p]["doc_id"] for p in to_update if "doc_id" in prev_state[p]]
        if update_delete_ids:
            delete_documents(dataset_id, update_delete_ids)

    # 6. 업로드 처리 (신규 + 수정)
    uploaded_doc_ids = []
    now = datetime.now(timezone.utc).isoformat()

    for rel_path in to_add + to_update:
        full_path = os.path.join(scenario_dir, rel_path)
        doc_id = upload_document(dataset_id, full_path)
        if doc_id:
            prev_state[rel_path] = {
                "hash": current_files[rel_path],
                "doc_id": doc_id,
                "synced_at": now,
            }
            uploaded_doc_ids.append(doc_id)
        else:
            logger.error(f"  업로드 실패로 건너뜀: {rel_path}")

    # 7. 파싱 시작
    if uploaded_doc_ids:
        start_parsing(dataset_id, uploaded_doc_ids)
        # 선택: 파싱 완료까지 대기할지 여부
        # wait_for_parsing(dataset_id, uploaded_doc_ids)

    # 8. 상태 저장
    save_state(state_path, prev_state)

    logger.info(f"동기화 완료: 추가={len(to_add)}, 수정={len(to_update)}, 삭제={len(to_delete)}")
    logger.info("=" * 60)

# ============================================================
# CLI
# ============================================================

def main():
    parser = argparse.ArgumentParser(description="RAGFlow 시나리오 증분 동기화")
    parser.add_argument("--scenario-dir", required=True, help="시나리오 docx 파일 디렉토리")
    parser.add_argument("--dataset-id", required=True, help="RAGFlow Dataset ID")
    parser.add_argument("--state-file", default=STATE_FILE, help="상태 파일 경로 (기본: sync_state.json)")

    args = parser.parse_args()

    if not RAGFLOW_API_KEY:
        logger.error("RAGFLOW_API_KEY 환경변수가 설정되지 않았습니다.")
        sys.exit(1)

    sync(args.scenario_dir, args.dataset_id, args.state_file)


if __name__ == "__main__":
    main()
```

### 사용법

```bash
# 환경변수 설정
export RAGFLOW_API_KEY="ragflow-xxxxx"
export RAGFLOW_BASE_URL="http://your-ragflow-server:9380"

# 실행
python sync_ragflow.py \
    --scenario-dir /path/to/scenarios \
    --dataset-id your-dataset-id-here \
    --state-file /path/to/sync_state.json
```

### Dataset ID 확인 방법

RAGFlow 웹 UI → Knowledge Base → 해당 Dataset 클릭 → URL에서 확인:
```
http://localhost:9380/knowledge/dataset/<이 부분이 dataset-id>
```

또는 API로:
```bash
curl -H "Authorization: Bearer $RAGFLOW_API_KEY" \
     "$RAGFLOW_BASE_URL/api/v1/datasets" | jq
```

---

## 크론 스케줄링

### crontab 설정

```bash
crontab -e
```

```cron
# 매일 새벽 3시에 동기화 실행
0 3 * * * cd /path/to/sync && /usr/bin/python3 sync_ragflow.py \
    --scenario-dir /path/to/scenarios \
    --dataset-id your-dataset-id \
    --state-file /path/to/sync_state.json \
    >> /var/log/ragflow-sync.log 2>&1
```

### 수동 실행 (필요 시)

시나리오팀이 대량 수정했다고 알려주면 크론 기다리지 말고 바로:

```bash
python sync_ragflow.py --scenario-dir /path/to/scenarios --dataset-id your-id
```

---

## 트러블슈팅 및 주의사항

### 1. 임시 파일 주의

Word가 편집 중인 파일에 `~$파일명.docx` 임시 파일을 생성함.
스크립트에서 `~$`로 시작하는 파일은 **이미 제외 처리**되어 있음.

### 2. 파일명 중복

같은 이름의 docx가 다른 하위 폴더에 있을 수 있음.
스크립트는 **상대 경로 기준**으로 관리하므로 문제없음:
```
episodes/ep001.docx → "episodes/ep001.docx"
side_stories/ep001.docx → "side_stories/ep001.docx"
```

### 3. 대량 변경 시

한 번에 수백 개가 변경되면 업로드+파싱에 시간이 걸림.
`wait_for_parsing()` 호출을 활성화하면 완료까지 대기하고,
비활성화하면 업로드만 하고 파싱은 백그라운드로 맡김 (기본값).

### 4. 네트워크/API 에러

업로드 실패한 파일은 state에 기록되지 않으므로,
**다음 동기화 때 자동으로 재시도**됨. 별도 재시도 로직 불필요.

### 5. 첫 실행 (초기 동기화)

`sync_state.json`이 없는 상태에서 실행하면 1400개 전부 신규로 업로드됨.
초기 1회는 시간이 많이 걸리니 여유 있는 시간에 실행.

### 6. RAGFlow API 버전 차이

RAGFlow 버전에 따라 API 경로나 응답 형식이 다를 수 있음.
최신 API 문서 확인: https://ragflow.io/docs/dev/http_api_reference

---

## 요약 체크리스트

- [ ] RAGFlow에 Dataset 1개 생성 (시나리오 전용)
- [ ] Dataset ID 확인
- [ ] API Key 발급
- [ ] 동기화 스크립트 배치 (`sync_ragflow.py`)
- [ ] 환경변수 설정 (`RAGFLOW_API_KEY`, `RAGFLOW_BASE_URL`)
- [ ] 초기 동기화 실행 (첫 1회, 수동)
- [ ] 파싱 완료 확인 (웹 UI에서)
- [ ] 검색 테스트
- [ ] crontab 등록 (매일 새벽)
- [ ] 로그 모니터링 경로 확인
