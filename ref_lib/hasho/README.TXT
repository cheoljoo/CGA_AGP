#/**		@file  		README.TXT
# *
# *     Copyright (c) 2006~ by Upresto Inc, Korea
# *     All rights reserved.
# * 
# * 	$Id: README.TXT,v 1.3 2006/06/09 06:54:24 cjlee Exp $
# * 
# *     @Author      $Author: cjlee $
# *     @version     $Revision: 1.3 $
# *     @date        $Date: 2006/06/09 06:54:24 $
# *     @todo        ���� �о�ñ� �ٶ��ϴ�. 
# *
# *     @section     Intro(�Ұ�)
# *      - hashg�� main memory���� ���� �� �Դϴ�. (malloc����  memory�Ҵ�)
# *		   hasho�� memg�� �̿��� memory ���� �ȿ��� �̸� �ذ��մϴ�. 	
# *
# *     @section     Requirement Tool
# *      @li doxygen 
# *      @li gcc 
# *      @li graphviz 
# *      @li perl 
# *
# **/

/*****************************
* Tue Apr 11 16:44:40 KST 2006
2006.04.11

���� ���� :
$ ./configure
$ ./make
$ ���� ȭ�� (����)  - hashg
$ ./make doc

������ : [ö��] HASH and Timer ���� v1.0.doc

files :
Doxyfile	 - doxygen configuration file
HISTORY.TXT
Makefile	
README.TXT
configure	- configure file �̸� �����Ͽ� structg���� CVS���� �������� compile��.
hasho.c		- hasho library file
hash.stg	- hasho���� ����ϴ� structure ����.

/*****************************
* 2006.04.18
hashg : main memory���� ������ �� 
hasho : offset�� ������ �ϴ� �� (main mem or shared mem : ������ ����) - �̰� ���α׷��Ҷ� �Ѱ� ���ؼ� ��Ȯ�� ���ǰ� ��

*����
- hashg�� offset�߽����� ������ ��Ų��. (pointer�� ���� ����ϸ� �ȵȴ�. )
  ���������� ����ϴ� primitives�� ������ ���� �ʴ� ������ �Ѵ�. 
  
/*****************************
* 2006.04.20
Makefile�ȿ��� LIBS    = $(LIBRARY) -lmemg -lSTGhasho -lSTGmemg  �̷��� �����ؾ� �ϴµ�,
������ �ٲٸ� ������ ���´�.
-l ... �϶� ���� �ͺ��� memory�� load �Ͽ� �δ� ������ ���δ�.
���� �⺻�� �Ǵ� ����  ���ʿ� �����ϴ� ���� �´� ������ �Ǵܵȴ�. 


TEST�� ��� ���� ���踦 �ؾ� �� ������ ���δ�.
������ TEST�� �ϰ� ����� ����� ���������� �ڵ����� üũ�� ����� ã�ƾ� �Ѵ�. ����� ������? 


/*
 *      - hash library ����  (offset�������� �ۼ�)
 *      - hasho_init���� �ʱ�ָ� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
 *      - primitives
 *      	@li hasho_init
 *      	@li hasho_add  , hasho_link_node
 *      	@li hasho_del  , hasho_unlink_node
 *      	@li hasho_find
 *      	@li hasho_print_info
 *      	@li hasho_print_node
 *      	@li hasho_print_all
 *      	@li Supplement 		: hasho_draw_all
@code
 *      - Hasho ����  (v1.1) 
 *      ��Ģ 0 : memg�ȿ����� offset�� pstMEMGINFO ���������� offset��.
 *   pstHASHOINFO = hasho_init(sizeof(stKEY)=8, sizeof(stKEY)=8, sizeof(stDATA)=4 , 4  :: hash size 0
 *
 *                        +----------------------------------+
 *                    48  |    memg_info (stMEMGINFO)        | [H]offset_memginfo = -48
 [M]offsetHeadRoom(48) -> +----------------------------------+
 *                    36  |    Head Room                     |  20 stHASHOINFO    
 *                        |                                  |  16 [H]offset_psthashnode = 20
 [M]offsetNodeStart(84)-> +----------------------------------+
 *                    16  |    memg node hdr1(stMEMGNODEHDR) |
 *                 +--28------+memg node data                |
 *                 |      +----------------------------------+
 *                 |  16  |    memg node hdr2(stMEMGNODEHDR) |
 *                 |  28  |    memg node data                |
 *                 |      +----------------------------------+
 *                 |      |    memg node hdr3(stMEMGNODEHDR) |
 *                 |      |    memg node data                |
 *                 |      +----------------------------------+
 *                 |
 *                 |
 *                 |    ��Ģ : hasho �� offset�� pstHASHOINFO���������� offset�� �ǹ���.
 *           [H]52 +----> +----------------------------------+
 *                     4  |    offset_next          +----------------------------+      
 *                     4  |    offset_prev                   |                   |      
 *                     4  |    offset_Key     +--------------------+             |      
 *                     4  |    offset_Data    +--------------------|---+         |      
 *          offset_Key    +----------------------------------+<----+   |         |      
 *                     8  |    Key (usKeyLen)                |         |         |      
 *          offset_Data   +----------------------------------+<--------+         |      
 *                     4  |    Data (usDataLen)              |                   |      
 *                        +----------------------------------+                   |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                        +----------------------------------+<------------------+      
 *                     4  |    offset_next                   |                          
 *                     4  |    offset_prev                   |                          
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *                        +----------------------------------+
 *                     4  |    offset_next                   |
 *                     4  |    offset_prev                   |
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *             [M] 1844   +----------------------------------+
 *
 *       offset ���� : 
 *       pstMEMGINFO      -> stMEMGINFO ����  offset ��
 *       pstHASHOINFO     -> stHASHOINFO , stHASHONODE ���� offset �� 
@endcode
*/


hasho������ ���� hasho_add�� �Ҷ� memcpy�� �ϴµ�
hasho_add���̵� ���� mem�� �Ҵ��ؼ� �� mem�� ����ϰ� �ϴ� ������ ���־����� ��.

�䱸����...
[������] �귯���� ����~~/���/ ���� �� :
���� hash_add�� ������ ���簡 ���Ͼ�� �޸��Ҵ縸 �ϰ�.. ���μ����� hash_add �� �޸𸮿� ���� �� �� �ֵ��� ����..

project �̸� : hashA
�䱸���� : ���� hash_add�� ������ ���簡 ���Ͼ�� �޸��Ҵ縸 �ϰ�.. ���μ����� hash_add �� �޸𸮿� ���� �� �� �ֵ��� ����
�� 1 : mem alloc�� ���� �Ͽ� NODE�� �Ҵ���� �Ŀ� , hashA_add�� �� NODE�� �� �Ѵ�.
-         Primitives
             pNODE = hashA_GetNode(INFO) �߰�         // key�� ���� �׳� node size��ŭ �Ҵ�
             fail or success = hashA_add(INFO , pNODE) ������� ����
-         �����
             pNODE = hashA_GetMem(pstHASHINFO);
             pNODE�� KEY�� DATA�� ���� ����
             hashA_add(pstHASHINFO , pNODE);
�� 2 : hashA_add()�� �Ͽ�  NODE�� �Ҵ�����Ŀ� , �� DATA�� ���� ��.
������ : hash�� �ֱ� ���ؼ��� key�� �̸� �˾ƾ� ��.  NODE�Ҵ��� �� ���� DATA�� �������� hash�� �޷������Ƿ� ū ������ ��������, ���� ��� ������ �߻� (����� ���� ������.)
-         Primitives
n         pNODE = hashA_add(pstHASHINFO , KEY);      // Ű�� memcpy�ؾ� �ϴ� �κ��� ��¿�� ����
-         �����
n         pNODE = hashA_add(pstHASHINFO , pKEY);
n         pNODE�� ���� ����.
��õ�� e �� 1 . 



#/** file			README.TXT
# *     $Log: README.TXT,v $
# *     Revision 1.3  2006/06/09 06:54:24  cjlee
# *     no message
# *
# *     Revision 1.2  2006/04/21 08:06:20  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.1  2006/04/21 02:19:49  cjlee
# *     INIT
# *
# *
# *     */