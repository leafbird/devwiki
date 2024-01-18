## container

 * dict : {}. 반복문을 돌 땐 .keys(), .values(), .items()을 쓴다.
 * list : []
 * tuple : (). list가 기본이고 tuple은 리스트와 유사하지만 수정할 수 없다. 주로 readonly인 리스트 용도로 쓴다.

## etc

 * 파이썬은 파일을 직접 실행했는지, import되었는지를 분간할 수 있다.
```
   if __name__ == '__main__':
    main()
```

## datetime

 * pymongo에서 받은 시간 데이터는 datetime에서 구해야 한다. mongodb 자체가 UTC시간만 저장하게 되어 있으므로, datetime.datetime.utcnow()를 사용한다.

## see also

 * http://api.mongodb.org/python/current/tutorial.html