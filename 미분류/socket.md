## socket의 TIME_WAIT 상태

소켓을 재사용하기로 결정한 경우, close를 먼저 호출하는 쪽은 소켓이 TIME_WAIT상태에서 2분간 사용불가능해지는 상태를 겪게된다.

* http://stackoverflow.com/questions/4306372/preventing-time-wait-using-net-async-api
* http://tech.kakao.com/2016/04/21/closewait-timewait/

## buffer size zero
from : http://gpgstudy.com/forum/viewtopic.php?t=22260

```
<소켓 버퍼에 대한 몇 가지 첨언>

출처는 하도 오래돼서 기억나지 않습니다만, send buffer와 recv buffer를 0으로 만들 때의 주의사항이 또 있습니다.
- send buffer를 0으로 만들 경우 win32 socket 계층에서 사용자 메모리를 직접 접근합니다. 이때 send buffer가 있는 메모리 페이지(약 2048k) 전체를 잠금합니다. 서버에서 send buffer가 메모리 여기저기 산재해 있을 경우 각 send buffer를 접근하기 위해 메모리 페이지 단위로 잠금을 자주 하게 됩니다. 이러한 경우 win32 working set의 양이 엄청나게 늘어나게 되며, 서버 메모리가 불충분한 경우 송신 블러킹이 심하게 발생합니다.
따라서 send buffer들은 웬만하면 적은 수의 메모리 페이지에 최대한 뭉쳐있을 수 있게 해야 합니다. 
- recv buffer를 0으로 만들 경우, 이유가 기억은 잘 나지 않습니다만, 위험합니다. 웬만해서는 0으로 만들어서 얻는 이익보다는 손실이 큽니다.

- imays
```
    
## Sliding Window

출처 : http://blog.naver.com/an5234.do?Redirect=Log&logNo=80012016026 

See Also : 
GPG 3권 보안소켓. 예제에 Sliding Window가 구현되어 있다. 

개념

TCP는 한 컴퓨터의 응용프로그램에서 원격 컴퓨터의 응용프로그램으로 직접 연결을 제공하기 때문에 끝 대 끝 프로토콜이라 불려진다. TCP는 메시지를 전송하기 위해 IP 사용해 데이터 그램으로 캡슐화되어 인터넷을 통해 전송된다. 데이터그램이 목적 호스트에 도착했을 때 IP는 내용물이 TCP에 넘겨준다. TCP가 메시지를 전송하는데 IP를 사용하지만 IP는 목적지까지 데이터를 전송해주는 역할만 하고 메시지의 내용은 알 수 없다. TCP에서는 메시지 손실, 중복, 지연에 따른 다양한 경우에 대해 원활하고, 효율적인 패킷 송,수신을 위한 신뢰성을 제공한다. 신뢰성을 제공하기 위해 여러가지 방법이 있는데 그 중에서 링크 효율을 높이면서 보다 신뢰성 있는 송수신을 가능하게 하는 방법이 Sliding Window Protocol이다. 

원리

TCP는 자료의 흐름 제어를 위해 window 체계를 사용한다. 연결이 구축되면, 연결의 각 끝은 들어오는 자료를 저장할 버퍼를 할당하고, 버퍼의 크기를 연결의 각 다른 끝에게 전송한다. 자료가 도착하면, 수신자는 응낙을 보내며, 이 응낙은 또한 남아있는 버퍼의 크기를 명시한다. 언제나 사용 가능한 버퍼 공간의 크기를 window이라 부르며, 그 크기를 명시하는 통고를 창통고(window advertisement)라 부른다. 수신자는 각 응낙과 함께 창통고를 전송한다. 
TCP/IP를 사용하는 모든 호스트들은 각각 2개의 window를 가지고 있다. 하나는 보내기 위한 window, 또 다른 하나는 받기 위한 Window이다. 
호스트들은 실제 패킷를 보내기 전에 먼저 "TCP 3-way handshaking"을 통하여 수신컴퓨터의 receive window size에 자신의 send window size를 맞추게 된다. 상대방이 받을 수 있는 크기에 맞추어 전송한다. 
호스트는 자신이 보내야할 전체 패킷 중에서 사용가능한 Window size만큼 패킷를 전송하기 시작한다. 
TCP는 window size만큼 한번에 패킷를 전송하고, 받는 쪽에서의 Ack신호가 오면 오는대로 바로바로 window를 Sliding시키고 다음 패킷을 수신측의 window size 만큼 보낸다. 
Delay Acknowledgement Timer기능을 수신측에 넣어 만일에 연속으로 보낸 패킷이 도중에 손실되거나 지연되면 손실되기 전 패킷에 대한 응답신호를 송신측에 보낸다. 이 기능을 통해 송신측은 보낸 데이터의 전부를 다시 보내는 것이 아니라, 수신된 부분을 제외한 나머지 부분을 전송함으로 네트워크 링크 효율을 개선한다. 
만일에 하나 송신측에서 보낸 패킷에 대한 응답이 하나도 오지 않을 경우를 대비해 송신측은 Retransmission Timer 시간이 만료되면 재전송을 시도한다. 
두 컴퓨터 사이에 자료 전송이 완료되었다면 3-메시지 교환을 사용하여 신뢰성 있는 종료를 한다. 종료에 대한 신호를 수신측에 전송하고 수신측은 종료요구를 받았다는 응답을 송측에 보낸다. 마지막으로 송신자는 수신측에서 종료에 대해 응답신호를 받았다는 신호를 최종적으로 수신측에 보내는 것으로 자료 전송을 종료합니다. 

결론

기존에 stop-and-wait은 송신측에서 보낸 데이터의 ACK신호를 받아야 다음 패킷을 보낼 수 있어 송신측은 ACK신호를 받을 때까지 휴지시간을 가지기 때문에 링크 효율이 떨어진다. 또한 go-back-N은 하나의 패킷에 하나의 응답을 받는 것이 아니라 연속해서 패킷을 보내고 수신측은 받은 패킷에 대해 연속해서 ACK신호를 보낸다. 이 방법은 기존에 stop-and-wait방식보다 효율적일 수 있지만, 도중에 하나의 패킷이 수신되지 않으면 다시 전부를 보내야 하는 비효율성이 존재한다. 이런 점에서 sliding window protocol은 응답을 기다리지 않고 연속적으로 패킷을 보내어 링크 효율을 높일 수 있다. 또한 window를 Sliding 방식에 문제가 될 수 있는 패킷손실, NO ACK에 대해 "Delay Acknowledgement Timer"와 "Retransmission Timer"를 이용해서 대비책을 마련해 두고 있는 것이다. 

마지막으로 window창과 네트워크 전송률의 관계는 비례적으로 네트워크의 트래픽이 많아서 속도가 느려지면 기대되는 응답시간보다 더 오랜시간이 걸려야만 Ack신호를 받을 수 있다. 결국엔 송신측 컴퓨터는 미처 Ack신호를 받지 못하고 "Retransmission Timer"의 시간이 만료되어 같은 데이터를 재전송해야 하는 일이 많아지게 될 것이다. 당연히 비효율적인 네트워크가 운영이 될 것이다. 즉 전송률이 낮으면 “Retransmission Timer” 만료되지 않을 만큼의 작은 window size를 설정해야 한다. 

링크

[http]Sliding Window Protocol(http://blog.naver.com/an5234.do?Redirect=Log&logNo=80012016026) 
[http]3.TCP/IP Sliding Window(http://blog.naver.com/yoon2323/80010265511) 
[http]4.Windows Size의 크기에 따른 영향(http://blog.naver.com/yoon2323/80010265536)