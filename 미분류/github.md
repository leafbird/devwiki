# github

## workflow

### 특정 job을 비활성화 하고 싶을 때

```yaml
    push-to-nuget:
    needs: build
    runs-on: ubuntu-latest
    
    if: false # github package 테스트를 위해 잠시 비활성화
      
    steps:
```