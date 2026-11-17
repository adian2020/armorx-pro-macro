 1e05d86:    76 01             	[--sp] = {rets, r6-r4}
 1e05d88:    15 08             	r5 = r1
 1e05d8a:    04 08             	r4 = r0
 1e05d8c:    c0 ff 4c 75 e2 01 	r0 = 0x1e2754c
 1e05d92:    80 f3 00 ca       	call 0x19400
 1e05d96:    c0 7d             	r0 = 0xdc
 1e05d98:    80 fe 00 45       	r4 += r5 * r0
 1e05d9c:    01 70             	r1 = 0x0
 1e05d9e:    c2 7d             	r2 = 0xdc
 1e05da0:    06 70             	r6 = 0x0
 1e05da2:    40 08             	r0 = r4
 1e05da4:    98 f3 a4 08       	call 0x301148
 1e05da8:    5d 68             	b[r4 + 0x5] = r5
 1e05daa:    00 72             	r0 = 0x20
 1e05dac:    68 68             	b[r4 + 0x6] = r0
 1e05dae:    a0 70             	r0 = 0xa
 1e05db0:    38 68             	b[r4 + 0x3] = r0
 1e05db2:    2e 68             	b[r4 + 0x2] = r6
 1e05db4:    20 98             	r0 = r4 + 0x2
 1e05db6:    81 70             	r1 = 0x8
 1e05db8:    c7 14             	call -0x672
 1e05dba:    30 fb 00 00       	r0 = rev8(r0)
 1e05dbe:    01 d6             	r1 = r0 >> 0x18
 1e05dc0:    19 68             	b[r4 + 0x1] = r1
 1e05dc2:    00 d4             	r0 = r0 >> 0x10
 1e05dc4:    08 68             	b[r4 + 0x0] = r0
 1e05dc6:    c0 ff 50 48 00 00 	r0 = 0x4850
 1e05dcc:    31 70             	r1 = 0x3
 1e05dce:    11 f6 b4 01       	[r0 + 0x1b4] = r1
 1e05dd2:    56 01             	{pc, r6-r4} = [sp++]
 1e05dd4:    78 01             	[--sp] = {rets, r8-r4}
 1e05dd6:    04 08             	r4 = r0
 1e05dd8:    05 70             	r5 = 0x0
 1e05dda:    c8 ff 62 75 e2 01 	r8 = 0x1e27562
 1e05de0:    46 08             	r6 = r4
 1e05de2:    07 70             	r7 = 0x0
 1e05de4:    c1 7d             	r1 = 0xdc
 1e05de6:    60 08             	r0 = r6
 1e05de8:    d0 14             	call -0x660
 1e05dea:    12 30             	if (r0 != 0x0) goto 0x24
 1e05dec:    41 05             	r1 = r5.b0 (u)
 1e05dee:    40 08             	r0 = r4
 1e05df0:    ca 17             	call -0x6c
 1e05df2:    10 6c             	r0 = b[r6 + 0x1] (u)
 1e05df4:    02 6c             	r2 = b[r6 + 0x0] (u)
 1e05df6:    31 6c             	r1 = b[r6 + 0x3] (u)
 1e05df8:    23 6c             	r3 = b[r6 + 0x2] (u)
 1e05dfa:    c8 fd 40 20       	r2 <= insert(r0, p:0x8, l:0x8)
 1e05dfe:    c8 fd 40 31       	r3 <= insert(r1, p:0x8, l:0x8)
 1e05e02:    30 fb 00 03       	r0 = rev8(r3)
 1e05e06:    03 d4             	r3 = r0 >> 0x10
 1e05e08:    80 08             	r0 = r8
 1e05e0a:    71 08             	r1 = r7
 1e05e0c:    80 f3 c3 c9       	call 0x19386
 1e05e10:    15 80             	r5 += 0x1
 1e05e12:    17 80             	r7 += 0x1
 1e05e14:    66 fc dc 00       	r6 = r6 + 0xdc
 1e05e18:    47 e0 e4 1f       	if (r7 != 0x4) goto -0x38
 1e05e1c:    58 01             	{pc, r8-r4} = [sp++]
 1e05e1e:    83 c2             	r3 = r0 << 0xa
 1e05e20:    01 70             	r1 = 0x0
 1e05e22:    02 70             	r2 = 0x0
 1e05e24:    20 e0 01 80       	if (r0 > 0x2) goto 0x2
 1e05e28:    32 08             	r2 = r3
 1e05e2a:    c0 ff 20 31 00 00 	r0 = 0x3120
 1e05e30:    20 09             	r0 += r2
 1e05e32:    00 fc d4 00       	r0 = r0 + 0xd4
 1e05e36:    c2 ff 04 4a 00 00 	r2 = 0x4a04
 1e05e3c:    18 44             	[r2 + 0x4] = r0
 1e05e3e:    c9 64             	b[r2 + 0xc] = r1
 1e05e40:    09 44             	[r2 + 0x0] = r1
 1e05e42:    c8 1f             	goto -0x70
