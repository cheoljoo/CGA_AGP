#/**		file  		README.TXT
# *
# *     Copyright (c) 2006~ by Upresto Inc, Korea
# *     All rights reserved.
# * 
# * 	$Id: README.TXT,v 1.1 2006/05/11 01:37:42 cjlee Exp $
# * 
# *     @Author      $Author: cjlee $
# *     @version     $Revision: 1.1 $
# *     @date        $Date: 2006/05/11 01:37:42 $
# *     @todo        먼저 읽어보시기 바랍니다. 
# *
# *     @section     Intro(소개)
# *      - 기본 생각들을 여기에 적어두었습니다.
# *
# *     @section     Requirement Tool
# *      @li doxygen 
# *      @li gcc 
# *
# **/

>>>/*****************************
>>>* 2006.04.21
>>>시작  - timerg 
>>>
>>>hashg를 가지고 timerg를 만들 것이다.  
>>>
>>>timerg를 o 가 아닌 g 모양으로 만들어도 무방한 이유 
>>>: 기존 DB를 shared memory를 사용하므로 start시 여기서 값을 읽어서 timer를 재구성하면 된다.
>>>: reload를 해주는 것은 timerg를 사용하는 process에서 해주어야 한다.  
>>>
>>>가정 : 
>>>- timer는 한개의 process에서만 돈다. 해당 timer를 수행하는 놈은 1놈이다. 
>>>- shared mem을 사용하는 것과 연동하여도 timerg를 수행하는 process가 살아있는동안에는 절대 address가 변하지 않는다. 
>>>
>>>Primitives :
>>>- stTIMERGINFO * = timerg_init(최대 Node수,call timeout 시간(초) , 하루에 재 조절할 횟수 , sizeof(*arg))
>>>- id = timerg_add(*func,*arg,절대시간)
>>>- timerg_del(id)
>>>- timerg_invoke()
>>>- timerg_relocation() : 장시간으로 된 것들에 대해서 다시 재배치를 시켜준다.  
>>>
>>>
>>>구조 
>>>            +------------------------------------+
>>>            |    timerg_info (stTIMERGINFO)        
>>>            |         node_count
>>>            |         max_node_count
>>>            |         timeout
>>>            |         ptr_long_timeout
>>>            +------------------------------------+
>>>여기서는 연속적인 메모리는 필요하지 않다. 
>>>각각에 대해서 필요하면 alloc처리하면 될 것이다.
>>>*arg 를 달아야 하는데 , type을 넣고, 일정  size를 잡아주어 여기에 copy를 해야 할 것으로 보인다. 
>>>*arg size를 입력하는 것으로 해야  할 것이다. 
>>>
>>>
>>>/*****************************
>>>* 2006.04.26
>>>기본적인 prototype을 마쳤다. 
>>>ONE_DAY , ONE_MINUTE를 변경하면  작은 범위에서도 동작을 한다. 
>>>main 안에 comment를 달아두었다.
>>>
>>>미진한 부분 :
>>>error 처리를 좀더 해야 할 것이고, (이건 항시 따라다니는 문제 )
>>>timerg_init의변수중에서 uitimeout을 사용하지 않는다. 이런 것들은 빼는게 좋을 것이다.
>>>일단  놓아둔다. 
>>>
>>>
>>>*2006.05.03
>>>Cnt 문제 되는 것 해결
>>>timerg_init 변경 완료
>>>comment 추가
>>>
>>>*2006.05.10
>>>timerg_del 에서 long 과 1일 이내에 대해서 문제가 발생
>>>서로 옮겨다니는데 , 기존 pointer방식으로 하면 간단하기는 하나
>>>invoke되어졌을때 address를 찾지 못하는 문제가 발생
>>>(나중에 필요시 hasho를 사용하여 address의 error로부터 해방아 되며,
>>>그리로뛰어 그 안의 값을 비교하여 원했던 값이 아닐 경우에는 처리를 하지 않는 것으로 하면 되지 않을까 한다.)
>>>이때는 pointer (4byte와 id 4 byte)를 합쳐서 사용하면 될 것으로 보인다.
>>>hashg를 사용하였던 것을 hasho로 변경하고 약간을 추가를 하면 장시간의 timeout에 대해서도 처리를 할수 있을 것으로 보인다. )


*2006.05.11 INIT TimerN
TimerN을 쓴 내용이며 이 내용은 위의 timerg에서 timeout이 현재부터 1일 이내의 것들만을
처리할수 있는 것을 만든다.
갯수는 32bit개까지 사용할수 있다. 


#/** file			README.TXT
# *     $Log: README.TXT,v $
# *     Revision 1.1  2006/05/11 01:37:42  cjlee
# *     INIT
# *
# *     Revision 1.3  2006/05/10 00:43:15  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.2  2006/05/03 06:12:40  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.1  2006/04/26 07:56:19  cjlee
# *     INIT
# *
# *
# *
# *     */
