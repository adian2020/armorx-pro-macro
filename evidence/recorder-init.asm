 1e0ba76:    36 e0 20 80       	if (r6 > 0x3) goto 0x40
 1e0ba7a:    04 f6 b8 f1       	r4 = [r15 + 0x1b8]
 1e0ba7e:    e0 fc 84 00       	r0 = r14 + 0x84
 1e0ba82:    01 70             	r1 = 0x0
 1e0ba84:    c2 70             	r2 = 0xc
 1e0ba86:    07 70             	r7 = 0x0
 1e0ba88:    97 f3 32 da       	call 0x2fb464
 1e0ba8c:    c0 7d             	r0 = 0xdc
 1e0ba8e:    80 fe 00 46       	r4 += r6 * r0
 1e0ba92:    01 70             	r1 = 0x0
 1e0ba94:    c2 7d             	r2 = 0xdc
 1e0ba96:    40 08             	r0 = r4
 1e0ba98:    97 f3 2a da       	call 0x2fb454
 1e0ba9c:    16 f9 84 e0       	b[r14 + 0x84] = r6
 1e0baa0:    4f 68             	b[r4 + 0x4] = r7
 1e0baa2:    5e 68             	b[r4 + 0x5] = r6
 1e0baa4:    6d 68             	b[r4 + 0x6] = r5
 1e0baa6:    1a f9 07 40       	b[r4 + 0x7] = r10
 1e0baaa:    d0 70             	r0 = 0xd
 1e0baac:    98 68             	b[r4 + 0x9] = r0
 1e0baae:    8f 68             	b[r4 + 0x8] = r7
 1e0bab0:    a0 70             	r0 = 0xa
 1e0bab2:    38 68             	b[r4 + 0x3] = r0
 1e0bab4:    2f 68             	b[r4 + 0x2] = r7
 1e0bab6:    1a f6 b4 f1       	[r15 + 0x1b4] = r10
