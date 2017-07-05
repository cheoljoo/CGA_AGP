#!/bin/sh
flex -PLogKunReqHdr LOG_KUN_REQ_HDR.l
cc -g3 -c -DTEST lex.LogKunReqHdr.c
cc -o LogKunReqHdr lex.LogKunReqHdr.o ../LOG_KUN_Prt.o -lfl

flex -PLogKunRespHdr LOG_KUN_RESP_HDR.l
cc -g3 -c -DTEST lex.LogKunRespHdr.c
cc -o LogKunRespHdr lex.LogKunRespHdr.o ../LOG_KUN_Prt.o -lfl

./LogKunReqHdr
./LogKunRespHdr


flex -PLogMEReqHdr LOG_ME_REQ_HDR.l
cc -g3 -c -DTEST lex.LogMEReqHdr.c
cc -o LogMEReqHdr lex.LogMEReqHdr.o ../LOG_ME_Prt.o -lfl

flex -PLogMERespHdr LOG_ME_RESP_HDR.l
cc -g3 -c -DTEST lex.LogMERespHdr.c
cc -o LogMERespHdr lex.LogMERespHdr.o ../LOG_ME_Prt.o -lfl

./LogMEReqHdr
./LogMERespHdr

flex -PBODY BODY.l
cc -g3 -c -DTEST lex.BODY.c
cc -o BODY lex.BODY.o -L./  -L../../../  -lSTGL7 -lfl
./BODY
