 1e095fa:    b0 04             	r0 = r2.l (s)
 1e095fc:    20 00             	rts
 1e095fe:    74 01             	[--sp] = {rets, r4}
 1e09600:    21 f7 04 00       	r1 = h[r0 + 0x4] (s)
 1e09604:    03 fb 20 d1       	r3 = -0x2ee0
 1e09608:    12 70             	r2 = 0x1
 1e0960a:    31 f2 01 b0       	ifs (r1 < r3) goto 0x2
 1e0960e:    02 70             	r2 = 0x0
 1e09610:    93 c0             	r3 = r2 << 0x2
 1e09612:    04 fb e0 2e       	r4 = 0x2ee0
 1e09616:    82 70             	r2 = 0x8
 1e09618:    41 f2 01 c0       	ifs (r1 > r4) goto 0x2
 1e0961c:    32 08             	r2 = r3
 1e0961e:    23 f7 06 00       	r3 = h[r0 + 0x6] (s)
 1e09622:    11 98             	r1 = r4 + 0x1
 1e09624:    13 f2 03 b0       	ifs (r3 < r1) goto 0x6
 1e09628:    01 fd 01 29       	r1 = r2 | 0x1
 1e0962c:    07 18             	goto 0xe
 1e0962e:    01 fd 02 29       	r1 = r2 | 0x2
 1e09632:    04 fb 20 d1       	r4 = -0x2ee0
 1e09636:    43 f2 01 b0       	ifs (r3 < r4) goto 0x2
 1e0963a:    21 08             	r1 = r2
 1e0963c:    23 f7 08 00       	r3 = h[r0 + 0x8] (s)
 1e09640:    02 fb e1 2e       	r2 = 0x2ee1
 1e09644:    23 f2 04 b0       	ifs (r3 < r2) goto 0x8
 1e09648:    02 fb 80 ff       	r2 = -0x80
 1e0964c:    52 b2             	r2 |= r1
 1e0964e:    07 18             	goto 0xe
 1e09650:    02 fd 40 19       	r2 = r1 | 0x40
 1e09654:    04 fb 20 d1       	r4 = -0x2ee0
 1e09658:    43 f2 01 b0       	ifs (r3 < r4) goto 0x2
 1e0965c:    12 08             	r2 = r1
 1e0965e:    20 f7 0a 00       	r0 = h[r0 + 0xa] (s)
 1e09662:    01 fb e1 2e       	r1 = 0x2ee1
 1e09666:    10 f2 04 b0       	ifs (r0 < r1) goto 0x8
 1e0966a:    00 fd 10 29       	r0 = r2 | 0x10
 1e0966e:    00 04             	r0 = r0.b0 (u)
 1e09670:    54 01             	{pc, r4} = [sp++]
 1e09672:    01 fd 20 29       	r1 = r2 | 0x20
 1e09676:    03 fb 20 d1       	r3 = -0x2ee0
 1e0967a:    30 f2 01 b0       	ifs (r0 < r3) goto 0x2
 1e0967e:    21 08             	r1 = r2
 1e09680:    40 04             	r0 = r1.b0 (u)
 1e09682:    54 01             	{pc, r4} = [sp++]
 1e0cee6:    d0 08             	r0 = r13
 1e0cee8:    bf f3 89 e3       	call -0x38ee
 1e0ceec:    01 f9 17 f0       	r1 = b[r15 + 0x17] (u)
 1e0cef0:    06 08             	r6 = r0
 1e0cef2:    16 f2 03 00       	if (r6 == r1) goto 0x6
 1e0cef6:    16 f9 17 f0       	b[r15 + 0x17] = r6
 1e0cefa:    15 70             	r5 = 0x1
 1e0cefc:    00 f9 85 e0       	r0 = b[r14 + 0x85] (u)
 1e0cf00:    08 30             	if (r0 != 0x0) goto 0x10
 1e0cf02:    8f f3 0d cd       	call 0x1f9a1a
 1e0cf06:    10 f6 8c e0       	[r14 + 0x8c] = r0
 1e0cf0a:    8f f3 09 cd       	call 0x1f9a12
 1e0cf0e:    10 f6 88 e0       	[r14 + 0x88] = r0
 1e0cf12:    05 e0 58 06       	if (r5 == 0x0) goto 0xcb0
