 1e05ac8:    04 70             	r4 = 0x0
 1e05aca:    20 e0 01 80       	if (r0 > 0x2) goto 0x2
 1e05ace:    04 08             	r4 = r0
 1e05ad0:    a0 c2             	r0 = r4 << 0xa
 1e05ad2:    c8 ff 20 31 00 00 	r8 = 0x3120
 1e05ad8:    80 09             	r0 += r8
 1e05ada:    01 fc 44 00       	r1 = r0 + 0x44
 1e05ade:    cc ff 50 48 00 00 	r12 = 0x4850
 1e05ae4:    11 f6 b0 c1       	[r12 + 0x1b0] = r1
 1e05ae8:    c0 ff 9a 76 e2 01 	r0 = 0x1e2769a
 1e05aee:    02 79             	r2 = 0x90
 1e05af0:    80 f3 51 cb       	call 0x196a2
 1e05af4:    00 f6 b0 c1       	r0 = [r12 + 0x1b0]
 1e05af8:    19 17             	call -0x1ce
