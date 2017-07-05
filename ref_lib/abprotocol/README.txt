./proto_print tdata/dpcreq.cap -p GTP -s 82 -v
./proto_print tdata/cpcreq.cap -p GTP -s 82 -v
# ip --> tcp 분석 테스트
./proto_print tdata/tcptest_0.test -p IP -v -c
# diameter
./proto_print tdata/LIR.cap -p DIAMETER -s 102 -v -c
./proto_print tdata/LIA.cap -p DIAMETER -s 326 -v -c
./proto_print tdata/DWR.cap -p DIAMETER -s 102 -v -c
./proto_print tdata/DWA.cap -p DIAMETER -s 118 -v -c 
./proto_print tdata/DWA-1.cap -p DIAMETER -s 118 -v -c 
./proto_print tdata/UAR.cap -p DIAMETER -s 102 -v -c
./proto_print tdata/UAA.cap -p DIAMETER -s 118 -v -c 
./proto_print tdata/UAA-1.cap -p DIAMETER -s 118 -v -c 
./proto_print tdata/SAR.cap -p DIAMETER -s 102 -v -c 
./proto_print tdata/SAA.cap -p DIAMETER -s 102 -v -c 
./proto_print tdata/MAR.cap -p DIAMETER -s 102 -v -c 
./proto_print tdata/MAA.cap -p DIAMETER -s 102 -v -c 
# gtp_p
./proto_print tdata/gtp_p_cdreq.cap -p GTP_P -s 82 -v -c
./proto_print tdata/gtp_p_echoreq.cap -p GTP_P -s 82 -v -c
./proto_print tdata/gtp_p_nodealivereq.cap -p GTP_P -s 82 -v -c
#gtp_map
./proto_print tdata/gtp_map_req.cap -p GTP -s 82 -v -c
./proto_print tdata/gtp_map_notereq.cap -p GTP -s 82 -v -c

