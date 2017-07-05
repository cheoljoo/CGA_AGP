#/**		file  		README.TXT
# *
# *     Copyright (c) 2006~ by Upresto Inc, Korea
# *     All rights reserved.
# * 
# * 	$Id: README.TXT,v 1.1 2006/08/03 10:48:21 dark264sh Exp $
# * 
# *     @Author      $Author: dark264sh $
# *     @version     $Revision: 1.1 $
# *     @date        $Date: 2006/08/03 10:48:21 $
# *     @todo        먼저 읽어보시기 바랍니다. 
# *
# *     @section     Intro(소개)
# *      - memg 라는 프로젝트이다. 
# *
# *     @section     Requirement Tool
# *      @li doxygen 
# *      @li gcc 
# *
# **/

/*****************************
* Tue Apr 11 16:44:40 KST 2006
2006.04.11

실행 순서 :
$ ./configure
$ ./make
$ 실행 화일 (실행)  - hashg
$ ./make doc

문서명 : [철주] HASH and Timer 정의 v1.0.doc

files :
Doxyfile	 - doxygen configuration file
HISTORY.TXT
Makefile	
README.TXT
configure	- configure file 미리 실행하여 structg등을 CVS에서 가져오고 compile함.
hash.c		- hash library file
hash.stg	- hash에서 사용하는 structure 모음.

/*****************************
* Wed Apr 12 08:25:13 KST 2006
2006.04.12
시스템 전반적인 내용을 적어본다.

hashg 와 structg 에 대한 PT를 작성해야 할 것이다.

program 규칙과 어떻게 사용할지 등에 대해서 나열을 해야 할 것이라 본다.



상무님에게 제시한 문제점들에게 대한 나의 의견에 답을 달아두는 것도 한가지 방법이 될수 있을 것이다.

볼 책들에 대한 고민을 해보자.

백과 사전을 받아두어야 하는데.... (ipop)







방법 일단 세부적으로 잘라보자.

framework에서 우리가 개발하는 방법을 살펴보자

Product = NTAF  +  NTAM + GUI

NTAF = Protocol Process + ManageMent Process

NTAM = Signal Process + DB Process + Management Process

GUI = beacon | JSP ....



NTAF 본연의 기능 - 관련 protocol에 대한 처리를 수행

NTAM - NTAF에서 들어오는 정보를 DB에 저장

GUI - NTAF/NTAM의 정보를 고객이 원하는 모양으로 보내줌.



이런 형태에서

문제를 다뤄봅시다. 

system들간 사용하는 것들이 뭐가 잇는지?

NTA[FM] 간의 인터페이스

NTAM - GUI간의 interface



NTAF에서는 어떤 것들을 주로 사용하는가?

Process간의 인터페이스

NTAM으로의 인터페이스

GUI와 interface

제품화를 위한 Process의 stackable한 구조 관리



NTAF의 Process안에서 이용되는 것들은 무엇이 있을까?

Timer ,  자료구조 , 파서



NTAM에서 무엇이 필요할까?

최대한 단순한 호 처리 (or NTAF에서 모두 처리)

DB에 삽입

GUI와 interface



interface들간에 무엇이 있으면 편리하게 사용할수 있을까?

정해진 structure로 전송하는게 전부 아닐까? (자동화 가능하지 않을까?)



GUI : 1개를 잡는다. (JSP or ActiveX)  - Web은 무조건 지원해야 함.

저는 해보니 ActiveX가 훨 좋았습니다.

추후 고객의 요청이 있을시 개발을 한다든지.



위의 상당 부분은 자동화가 가능하다고 보여지며, 

그렇게 하지 않으면 엄청난 노가다들이 뒤따르겠죠.



자동화 예.  NTAF에서 생성되는 data는 NTAM의 DB에 들어갈수 있게 자동화 가능

- struct에 대한 endian , print 문 자동 가능

- 정형화를 잘 할 경우에 NTAM에서는 툴을 돌린 결과를 compile만 하면 적용끝.


###########################################

hasho라른 것을 만들 예정이다.

hashg : main memory에서 구현한 것 
hasho : offset을 가지고 하는 것 (main mem or shared mem : 사이즈 일정) - 이게 프로그램할때 한계등에 대해서 명확히 정의가 됨

2006.04.17
memg를 만들었다.
memg라는 것은 memroy의 일정 buffer를 할당한후에 그 안에서 일정 크기들로만 사용하는 것을 의미하는 것으로
sharedmemory에서도 사용하기 위해서 만들었다.
init , alloc , free를 기본으로 가지게 만들었다.

* 더 추가해야 할 부분
shared memory에서 할당 받는 부분을 추가해야 할 것이다.
garbage collection에 대한 처리도 고려해주어야 할 것으로 보인다.  



#/** file			README.TXT
# *     $Log: README.TXT,v $
# *     Revision 1.1  2006/08/03 10:48:21  dark264sh
# *     no message
# *
# *     Revision 1.1  2006/08/03 10:23:11  dark264sh
# *     INIT
# *
# *     Revision 1.1  2006/08/02 02:09:22  dark264sh
# *     no message
# *
# *     Revision 1.2  2006/04/19 07:41:30  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.1  2006/03/17 07:23:14  cjlee
# *     INIT
# *
# *
# *     */
