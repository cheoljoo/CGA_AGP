#include "asn1_DD.h"

void 
DD_BINARY(char *desc, OSUINT32 numocts, const OSOCTET *data)
{
	int			i;

	printf("%s (B) :", desc);
	for (i = 0; i < numocts; i++) {
		printf(" 0x%02x", data[i]);
	}
	printf("\n");
}

void 
DD_STRING(char *desc, OSUINT32 numocts, const OSOCTET *data)
{
	int			i;

	printf("%s (S) :", desc);
	for (i = 0; i < numocts; i++) {
		printf(" 0x%02x", data[i]);
	}
	printf("\n");
}

void 
DD_BITSTRING(char *desc, OSUINT32 numbits, const OSOCTET *data)
{
	int		i;
	int		numocts;

	numocts = (numbits/8) + ((numbits%8) ? 1 : 0);

	printf("%s (BS) :", desc);
	for (i = 0; i < numocts; i++) {
		printf(" 0x%02x", data[i]);
	}
	printf("\n");
}

void 
DD_VALUE_U8(char *desc, OSUINT8 value)
{
	printf("%s : %u\n", desc, value);
}

void 
DD_VALUE_S8(char *desc, OSINT8 value)
{
	printf("%s : %d\n", desc, value);
}

void 
DD_VALUE_U16(char *desc, OSUINT16 value)
{
	printf("%s : %u\n", desc, value);
}

void 
DD_VALUE_S16(char *desc, OSINT16 value)
{
	printf("%s : %d\n", desc, value);
}

void 
DD_VALUE_U32(char *desc, OSUINT32 value)
{
	printf("%s : %u\n", desc, value);
}

void 
DD_VALUE_S32(char *desc, OSINT32 value)
{
	printf("%s : %d\n", desc, value);
}


