#ifndef __ASN1_DD_H__
#define __ASN1_DD_H__

#include "asn1per.h"

extern void DD_BINARY(char *desc, OSUINT32 numocts, const OSOCTET *data);
extern void DD_STRING(char *desc, OSUINT32 numocts, const OSOCTET *data);
extern void DD_BITSTRING(char *desc, OSUINT32 numbits, const OSOCTET *data);
extern void DD_VALUE_U8(char *desc, OSUINT8 value);
extern void DD_VALUE_S8(char *desc, OSINT8 value);
extern void DD_VALUE_U16(char *desc, OSUINT16 value);
extern void DD_VALUE_S16(char *desc, OSINT16 value);
extern void DD_VALUE_U32(char *desc, OSUINT32 value);
extern void DD_VALUE_S32(char *desc, OSINT32 value);

#endif /* __ASN1_DD_H__ */
