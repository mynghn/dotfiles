# 페이지 만들기 — 자기완결 문서

목차: [골격](#골격) · [테마와 색 배선](#테마와-색-배선) · [타이포와 레이아웃](#타이포와-레이아웃) ·
[페이지 안의 계층 줌](#페이지-안의-계층-줌) · [담기](#담기) ·
[피해야 할 기계 티](#피해야-할-기계-티) · [체크리스트](#체크리스트)

이 파일을 감싸는 것은 아무것도 없다. 디스크에서 열리고, 네트워크가 없어도
렌더링된다. 필요한 것은 전부 안에 담아 보낸다.

## 골격

```html
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>… 대상 — 다이제스트</title>
<style>
  :root {
    color-scheme: light dark;
    /* 의미를 지는 상태 색 — diagram-craft.md 참조. 산문과 SVG가 같은 변수를 읽는다 */
    --ink: #1a1d21; --muted: #5d6672; --bg: #faf9f7; --surface: #fff; --line: #e2e0db;
    --state-a: #0e6f68; --state-b: #b1692b; --state-c: #9c3a2d;
  }
  @media (prefers-color-scheme: dark) {
    :root { --ink: #e6e8ea; --muted: #99a1ab; --bg: #14171a; --surface: #1c2024; --line: #2c3137;
            --state-a: #4ec2b2; --state-b: #e0a05c; --state-c: #e08a72; }
  }
  *, *::before, *::after { box-sizing: border-box; }
  body { margin: 0; padding: 0 1.25rem; background: var(--bg); color: var(--ink);
         font: 1.02rem/1.62 -apple-system, BlinkMacSystemFont, "Segoe UI", "Apple SD Gothic Neo",
               "Noto Sans KR", sans-serif; }
  .wrap { max-width: 46rem; margin: 0 auto; padding: 2.5rem 0 5rem; }
  img { max-width: 100%; }
</style>
</head>
<body>
<div class="wrap"> … </div>
</body>
</html>
```

시스템 폰트 스택만 쓴다 — 웹폰트는 네트워크를 탄다. 한글 본문은 위 스택이 macOS·
Windows·리눅스에서 각각 자기 기본 고딕으로 떨어진다. `ui-monospace,
SFMono-Regular, Menlo, monospace`는 대상 자신의 어휘(식별자·경로·상태)를 표시해
코드 같은 낱말이 한 무리로 읽히게 한다. 한글 본문에 세리프를 섞는 것은 권하지
않는다 — 라틴 세리프 스택은 한글 글리프를 잡아주지 못한다.

## 테마와 색 배선

색은 하나도 빠짐없이 `:root`의 커스텀 프로퍼티로 한 번만 선언하고,
`@media (prefers-color-scheme: dark)` 안에서 그 세트를 통째로 덮어쓴다. 그러면
**산문과 SVG가 같은 변수를 읽는다** — 다이어그램 안에는 `fill="var(--state-a)"`만
쓰고 리터럴 hex는 쓰지 않는다. 색을 박아 넣은 그림은 독자 시스템이 다크 모드로
넘어가는 순간 읽히지 않는다.

테마 토글은 선택이다. 붙인다면 루트 엘리먼트에 `data-theme="dark|light"`를 찍고
`:root[data-theme="dark"] { … }` 규칙이 미디어 쿼리를 양방향으로 이기게 쓴다.

## 타이포와 레이아웃

- 한 줄 길이는 라틴 기준 **64–70자** 언저리에서 끊는다(컨테이너에
  `max-width: 46rem`이면 된다). 한글은 같은 폭에서 30–35자쯤 들어간다.
- 주장은 본문 잉크로, 캡션·용어 풀이·곁말은 `--muted`로. 이 대비 차이가 곧
  위계다 — 세 번째 굵기는 거의 필요 없다.
- 테두리와 카드 — `1px solid var(--line)`, `border-radius: 10px`, 패딩
  `1rem 1.2rem`. 배경은 `var(--surface)`로 페이지 배경에서 한 단계만 띄운다.
  꽉 찬 채색은 쓰지 않는다.
- 비교 그리드 — `grid-template-columns: 1fr 1fr`, `680px` 아래에서 `1fr`로 접는다.
- 움직임은 로드 시 한 번 드러나는 정도까지만, 그것도
  `@media (prefers-reduced-motion: no-preference)` 안에서.
- 누를 수 있는 것은 진짜 `<button>`으로 만들고 `:focus-visible` 외곽선을 남긴다.

## 페이지 안의 계층 줌

다이제스트는 줌이 되는 지도다. 한 문서 안에 세 겹을 둔다.

1. **훑는 겹** — 제목, 한 문단짜리 논지, 그리고 절 제목들. 문단마다 주장을 첫
   문장에 두면 제목과 첫 문장만 읽은 독자도 줄기를 얻는다. 그 독자를 염두에 두고
   써라.
2. **읽는 겹** — 절 본문, 순서대로.
3. **파는 겹** — 일부 독자만 필요한 부분. `<details>` 뒤에 둔다.

접는 상자는 **도입 문장이 펼치지 않아도 참인 계약을 말할 때만** 정당하다.
다이제스트 전체가 통과해야 하는 캡슐화 시험과 같은 시험이다.

```html
<details>
  <summary>손댄 파일 열한 개 전부와 각각이 움직인 이유</summary>
  …
</details>
```

절이 다섯 개를 넘으면 독자 계약 바로 뒤에 짧은 목차를 두고 `id`가 붙은 제목으로
건다. 평평하게 유지한다.

## 담기

**페이지 본문은 절대 가로로 스크롤되지 않는다.** 넓은 것은 저마다 자기 스크롤
상자를 가진다.

```html
<figure>
  <div class="fig-frame"><svg viewBox="0 0 720 240" role="img" aria-label="…">…</svg></div>
  <figcaption>여기서 무엇을 가져갈지 한 줄로.</figcaption>
</figure>
```

```css
.fig-frame { border: 1px solid var(--line); border-radius: 12px; padding: 1.4rem 1.1rem .6rem;
             background: var(--surface); overflow-x: auto; }
.fig-frame svg { display: block; margin: 0 auto; min-width: 34rem; }
figcaption { color: var(--muted); font-size: .9rem; margin-top: .7rem; max-width: 64ch; }
pre, .tablewrap { overflow-x: auto; }
```

SVG에 건 `min-width`는 의도한 것이다. 읽을 수 없는 크기로 찌그러지느니 그림은
제 크기를 지키고 그 틀이 대신 스크롤된다.

## 피해야 할 기계 티

기계가 찍어낸 것처럼 보이는 문서는 기계가 생각한 것처럼 읽힌다. 표시는 이렇다.

- 보라에서 파랑으로 흐르는 배너, 그 밖에 장식으로 쓰인 모든 그러데이션
- 반투명 유리 카드와 짙은 드롭 섀도
- 절 표시로 쓰는 이모지
- 아무 상태도 지지 않는 채도 높은 무지개 강조색
- 전부 가운데 정렬에, 얇은 본문 위에 얹힌 거대한 히어로 제목
- 서로 다른 것들에 같은 모양을 강제하는 균일한 카드 그리드

여섯 가지를 뒤집으면 하나가 된다. 색은 대상 자신의 구분에서 고르고, 껍데기는
조용히 두고, 시각적 무게는 딱 한 번 — 가장 어려운 생각에 쓴다.

## 체크리스트

- [ ] 완결된 문서다. 네트워크를 끊고 `file://`로 열어도 뜬다.
- [ ] CSS·JS 전부 인라인. 외부 폰트·스타일시트·스크립트·이미지 없음.
- [ ] 색은 `:root` 커스텀 프로퍼티. 다크 모드 대응. SVG fill이 그 변수를 읽음.
- [ ] 375px에서 본문이 가로로 밀리지 않음. 넓은 요소마다 자기 스크롤 상자.
- [ ] 모든 `<svg>`에 `role="img"`와 `aria-label`.
- [ ] 그림마다 가져갈 것을 말하는 캡션.
- [ ] 위쪽에 `<section class="reader-contract">`, 끝 쪽에
      `<section class="self-check">`. 둘 다 안에 `<section>`을 중첩하지 않음.
- [ ] 속성은 큰따옴표, 닫는 태그 빠짐 없음, `<title>` 있음, `<html lang="ko">`.
