## wpf margin and padding

WPF에서 Margin과 Padding은 다음과 같은 차이점이 있습니다:

Margin:

요소의 외부 공간을 정의합니다.
부모 요소와 자식 요소 사이의 간격을 설정합니다.
다른 요소와의 간격을 조정할 때 사용됩니다.

```xml
<Button Content="Click Me" Margin="10"/>
```

Padding:

요소의 내부 공간을 정의합니다.
요소의 경계와 그 안의 콘텐츠 사이의 간격을 설정합니다.
요소 내부의 콘텐츠와 경계 사이의 간격을 조정할 때 사용됩니다.

```xml
<Button Content="Click Me" Padding="10"/>
```

### 상하좌우를 각각 설정

comma로 구분한 숫자 4개를 지정하면 순서대로 left, top, right, bottom

```xml
<Button Content="Click Me" Margin="1,2,3,4"/>
```

### 상하, 좌우만 각각 설정

comma로 구분한 숫자 2개를 지정하면 순서대로 left/right, top/bottom

```xml
<Button Content="Click Me" Margin="1,2"/>
```

## wpf ViewModel에서 필터링 기능 구현하기

참조 : 
- https://forum.dotnetdev.kr/t/wpf-mvvm/10576/2
- https://blog.naver.com/vactorman/222574058746

ICollectionView는 System.ComponentModel의 구성이므로 이것을 사용하면 됩니다.
실제 객체인 CollectionViewSource는 viewModel 밖에서 생성하고, di 등을 통해 viewModel에 주입하는 방식으로 사용합니다.