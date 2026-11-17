 1e0dad2:    00 f9 c0 f1       	r0 = b[r15 + 0x1c0] (u)
 1e0dad6:    77 20             	if (r0 == 0x0) goto 0xee
 1e0dad8:    8f f3 22 c7       	call 0x1f8e44
 1e0dadc:    05 f9 78 e0       	r5 = b[r14 + 0x78] (u)
 1e0dae0:    10 f6 58 f1       	[r15 + 0x158] = r0
 1e0dae4:    35 e0 6f 80       	if (r5 > 0x3) goto 0xde
 1e0dae8:    1d f5 18 00       	[sp+24] = r13
 1e0daec:    0a f6 b8 f1       	r10 = [r15 + 0x1b8]
 1e0daf0:    02 f5 38 04       	r2 = [sp+1080]
 1e0daf4:    c0 7d             	r0 = 0xdc
 1e0daf6:    a1 08             	r1 = r10
 1e0daf8:    80 fe 00 15       	r1 += r5 * r0
 1e0dafc:    30 62             	r0 = b[r1 + 0x3] (u)
 1e0dafe:    21 62             	r1 = b[r1 + 0x2] (u)
 1e0db00:    3d fd ff 2c       	r13 = r2 & 0xffffff
 1e0db04:    c8 fd 40 10       	r1 <= insert(r0, p:0x8, l:0x8)
 1e0db08:    30 fb 00 01       	r0 = rev8(r1)
 1e0db0c:    00 d4             	r0 = r0 >> 0x10
 1e0db0e:    01 fc f6 ff       	r1 = r0 + -0xa
 1e0db12:    60 70             	r0 = 0x6
 1e0db14:    c0 fe 00 01       	r0 = r1 / r0 (u)
 1e0db18:    20 04             	r0 = r0.l (u)
 1e0db1a:    34 72             	r4 = 0x23
 1e0db1c:    71 ed 01 80       	if (r1 > 0xd7) goto 0x2
 1e0db20:    04 08             	r4 = r0
 1e0db22:    14 e0 85 13       	if (r4 != 0x1) goto 0x70a
 1e0db26:    c0 7d             	r0 = 0xdc
 1e0db28:    a1 08             	r1 = r10
 1e0db2a:    80 fe 00 15       	r1 += r5 * r0
 1e0db2e:    63 62             	r3 = b[r1 + 0x6] (u)
 1e0db30:    10 70             	r0 = 0x1
 1e0db32:    c0 0c             	r0 <<= r3
 1e0db34:    20 f0 82 04       	if ((r0 & r2) == 0) goto 0x904
 1e0db38:    02 f9 79 e0       	r2 = b[r14 + 0x79] (u)
 1e0db3c:    60 70             	r0 = 0x6
 1e0db3e:    80 fe 00 12       	r1 += r2 * r0
 1e0db42:    a1 62             	r1 = b[r1 + 0xa] (u)
 1e0db44:    20 f3 83 14       	if ((r1 & 0x1) != 0) goto 0x906
 1e0db48:    c1 7d             	r1 = 0xdc
 1e0db4a:    80 fe 10 a5       	r10 += r5 * r1
 1e0db4e:    80 fe 00 a2       	r10 += r2 * r0
