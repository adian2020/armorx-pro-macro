 1e09170:    01 f9 02 90       	r1 = b[r9 + 0x2] (u)
 1e09174:    10 fc 2c ff       	r0 = r1 + -0xd4
 1e09178:    5a be             	r10 |= r7
 1e0917a:    50 e0 cd 80       	if (r0 > 0x5) goto 0x19a
 1e0917e:    41 c0             	r1 = r0 << 0x1
 1e09180:    b1 00             	tbh [r1]
 1e09182:    06 00             	hbkpt
 1e09184:    cd 00             	pfetch [r13]
 1e09186:    dd 00             	iflush [r13]
 1e09188:    e8 00             	flush [r8]
 1e0918a:    15 01             	{rets, r5, r4} = [sp++]
 1e0918c:    72 01             	[--sp] = {rets, r3, r2}
