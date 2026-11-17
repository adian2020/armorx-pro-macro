 1e093ac:    10 70             	r0 = 0x1
 1e093ae:    d0 f5 c0 02       	b[sp+704] = r0
 1e093b2:    96 fc 04 00       	r6 = r9 + 0x4
 1e093b6:    c1 7d             	r1 = 0xdc
 1e093b8:    c4 7d             	r4 = 0xdc
 1e093ba:    60 08             	r0 = r6
 1e093bc:    bf f3 e5 e1       	call -0x3c36
 1e093c0:    bd 20             	if (r0 == 0x0) goto 0x17a
 1e093c2:    00 f6 b8 81       	r0 = [r8 + 0x1b8]
 1e093c6:    01 f9 06 90       	r1 = b[r9 + 0x6] (u)
 1e093ca:    02 08             	r2 = r0
 1e093cc:    80 fe 40 21       	r2 += r1 * r4
 1e093d0:    31 64             	r1 = b[r2 + 0x3] (u)
 1e093d2:    22 64             	r2 = b[r2 + 0x2] (u)
 1e093d4:    c8 fd 40 21       	r2 <= insert(r1, p:0x8, l:0x8)
 1e093d8:    30 fb 00 12       	r1 = rev8(r2)
 1e093dc:    09 d4             	r1 = r1 >> 0x10
 1e093de:    c1 ed ad 80       	if (r1 > 0xdc) goto 0x15a
 1e093e2:    01 70             	r1 = 0x0
 1e093e4:    d1 f5 c0 02       	b[sp+704] = r1
 1e093e8:    01 f9 03 90       	r1 = b[r9 + 0x3] (u)
 1e093ec:    31 e0 0e 80       	if (r1 > 0x3) goto 0x1c
 1e093f0:    02 f9 07 90       	r2 = b[r9 + 0x7] (u)
 1e093f4:    03 f9 06 90       	r3 = b[r9 + 0x6] (u)
 1e093f8:    80 fe 40 01       	r0 += r1 * r4
 1e093fc:    c8 fd 40 32       	r3 <= insert(r2, p:0x8, l:0x8)
 1e09400:    30 fb 00 13       	r1 = rev8(r3)
 1e09404:    0a d4             	r2 = r1 >> 0x10
 1e09406:    61 08             	r1 = r6
 1e09408:    97 f3 6c ed       	call 0x2fdad8
 1e0940c:    00 f9 14 80       	r0 = b[r8 + 0x14] (u)
 1e09410:    bf f3 05 e5       	call -0x35f6
 1e09414:    00 f9 03 90       	r0 = b[r9 + 0x3] (u)
 1e09418:    01 f6 b8 81       	r1 = [r8 + 0x1b8]
 1e0941c:    c2 7d             	r2 = 0xdc
 1e0941e:    80 fe 20 10       	r1 += r0 * r2
 1e09422:    60 62             	r0 = b[r1 + 0x6] (u)
 1e09424:    00 e2 75 20       	if (r0 >= 0x20) goto 0xea
 1e09428:    05 f6 b0 81       	r5 = [r8 + 0x1b0]
 1e0942c:    01 ba             	r1 = r5 + r0
 1e0942e:    10 f9 70 10       	b[r1 + 0x70] = r0
 1e09432:    f1 07             	r1 = -0x1
 1e09434:    25 f3 06 00       	if ((r0 & 0x20) != 0) goto 0xc
 1e09438:    20 fd 1f 09       	r0 = r0 & 0x1f
 1e0943c:    11 70             	r1 = 0x1
 1e0943e:    f8 fd 00 01       	r0 = r1 << r0
 1e09442:    d1 b1             	r1 = ~r0
 1e09444:    00 f6 d0 81       	r0 = [r8 + 0x1d0]
 1e09448:    50 b3             	r0 &= r1
 1e0944a:    10 f6 d0 81       	[r8 + 0x1d0] = r0
 1e0944e:    30 fb 00 00       	r0 = rev8(r0)
 1e09452:    51 fc 51 00       	r1 = r5 + 0x51
 1e09456:    08 62             	b[r1 + 0x0] = r0
 1e09458:    02 d6             	r2 = r0 >> 0x18
 1e0945a:    3a 62             	b[r1 + 0x3] = r2
 1e0945c:    02 d4             	r2 = r0 >> 0x10
 1e0945e:    2a 62             	b[r1 + 0x2] = r2
 1e09460:    00 d2             	r0 = r0 >> 0x8
 1e09462:    18 62             	b[r1 + 0x1] = r0
 1e09464:    58 18             	goto 0xb0
