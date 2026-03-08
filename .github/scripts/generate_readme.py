#!/usr/bin/env python3
"""devwiki README.md 자동 생성 스크립트.

디렉토리 구조를 스캔하여 카테고리별 문서 목록을 README.md로 생성한다.
구성: 전체 카테고리 목차 → 각 카테고리별 문서 목록 → TIL (최신순 정렬)
"""

import re
import urllib.parse
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent

# 스캔에서 제외할 디렉토리
SKIP_DIRS = {".git", ".github", ".vscode", "packages", "node_modules"}

# 스캔에서 제외할 파일
SKIP_FILES = {"README.md", "LICENSE"}

# TIL 폴더는 별도 섹션으로 분리하여 최신순 정렬
TIL_DIR = "TIL"


def url_encode_path(path: str) -> str:
    """경로의 각 구성요소를 URL 인코딩한다 (공백, 한글 등)."""
    parts = path.split("/")
    return "/".join(urllib.parse.quote(p) for p in parts)


def display_name(filepath: Path) -> str:
    """파일명에서 확장자를 제거하여 표시용 이름을 반환한다."""
    return filepath.stem


def make_anchor(name: str) -> str:
    """GitHub 호환 앵커 링크를 생성한다 (소문자 변환, 특수문자 제거)."""
    anchor = name.lower()
    anchor = re.sub(r"[^\w\s가-힣-]", "", anchor)
    anchor = re.sub(r"\s+", "-", anchor.strip())
    return anchor


def collect_md_files(directory: Path) -> list[Path]:
    """디렉토리에서 마크다운 파일 목록을 반환한다 (이름순 정렬)."""
    return sorted(
        [f for f in directory.iterdir()
         if f.is_file() and f.suffix == ".md" and f.name not in SKIP_FILES],
        key=lambda f: f.name.lower(),
    )


def scan_categories(root: Path) -> dict:
    """일반 카테고리를 스캔한다 (TIL 제외).

    Returns:
        {카테고리명: {"files": [파일경로...], "subcats": {하위카테고리명: [파일경로...]}}}
    """
    categories = {}

    for entry in sorted(root.iterdir(), key=lambda e: e.name.lower()):
        # TIL, 숨김폴더, 제외 대상 건너뛰기
        if entry.name in SKIP_DIRS or entry.name == TIL_DIR or not entry.is_dir():
            continue

        cat = {"files": collect_md_files(entry), "subcats": {}}

        # 하위 디렉토리 탐색 (1단계만)
        for sub in sorted(entry.iterdir(), key=lambda e: e.name.lower()):
            if sub.is_dir() and sub.name not in SKIP_DIRS:
                sub_files = collect_md_files(sub)
                if sub_files:
                    cat["subcats"][sub.name] = sub_files

        if cat["files"] or cat["subcats"]:
            categories[entry.name] = cat

    return categories


def scan_til(root: Path) -> list[Path]:
    """TIL 폴더를 스캔하여 파일 목록을 최신순(제목 내림차순)으로 반환한다."""
    til_dir = root / TIL_DIR
    if not til_dir.is_dir():
        return []
    files = [f for f in til_dir.iterdir()
             if f.is_file() and f.suffix == ".md" and f.name not in SKIP_FILES]
    # 파일명이 날짜로 시작하므로 내림차순 정렬 → 최신 글이 위로
    return sorted(files, key=lambda f: f.name.lower(), reverse=True)


def format_file_link(filepath: Path) -> str:
    """파일 하나에 대한 마크다운 링크를 생성한다."""
    rel = filepath.relative_to(REPO_ROOT)
    return f"- [{display_name(filepath)}]({url_encode_path(str(rel))})"


def generate_readme(categories: dict, til_files: list[Path]) -> str:
    """최종 README 마크다운 문자열을 생성한다."""
    lines = [
        "# devwiki",
        "",
        "개발에 관련된 메모를 적어둡니다.",
        "",
        "---",
        "",
        "<!-- sitemap start -->",
        "",
    ]

    # ── 1단: 전체 카테고리 목차 ──
    lines.append("## Categories")
    lines.append("")
    for cat_name, cat_data in categories.items():
        lines.append(f"* [{cat_name}](#{make_anchor(cat_name)})")
        for sub_name in cat_data["subcats"]:
            lines.append(f"  * [{sub_name}](#{make_anchor(sub_name)})")
    # TIL은 목차 마지막에 추가
    if til_files:
        lines.append(f"* [{TIL_DIR}](#{make_anchor(TIL_DIR)})")
    lines.append("")
    lines.append("---")

    # ── 2단: 각 카테고리별 문서 목록 ──
    for cat_name, cat_data in categories.items():
        lines.append("")
        lines.append(f"### {cat_name}")
        lines.append("")
        for f in cat_data["files"]:
            lines.append(format_file_link(f))

        for sub_name, sub_files in cat_data["subcats"].items():
            lines.append("")
            lines.append(f"#### {sub_name}")
            lines.append("")
            for f in sub_files:
                lines.append(format_file_link(f))

    # ── 3단: TIL (최신순) ──
    if til_files:
        lines.append("")
        lines.append(f"### {TIL_DIR}")
        lines.append("")
        for f in til_files:
            lines.append(format_file_link(f))

    lines.append("")
    lines.append("<!-- sitemap end -->")
    lines.append("")
    return "\n".join(lines)


def main():
    categories = scan_categories(REPO_ROOT)
    til_files = scan_til(REPO_ROOT)
    readme = generate_readme(categories, til_files)
    (REPO_ROOT / "README.md").write_text(readme, encoding="utf-8")

    total = sum(
        len(c["files"]) + sum(len(sf) for sf in c["subcats"].values())
        for c in categories.values()
    ) + len(til_files)
    print(f"README.md 생성 완료: {len(categories)}개 카테고리, TIL {len(til_files)}개, 총 {total}개 문서")


if __name__ == "__main__":
    main()
