 1e0d590:    22 e0 83 00       	if (r2 == 0x2) goto 0x106
 1e0d594:    20 70             	r0 = 0x2
 1e0d596:    7d 18             	goto 0xfa
 1e0d598:    00 70             	r0 = 0x0
 1e0d59a:    01 f9 85 e0       	r1 = b[r14 + 0x85] (u)
 1e0d59e:    31 e2 03 30       	if (r1 < 0x23) goto 0x6
 1e0d5a2:    bf f3 1b e9       	call -0x2dca
 1e0d5a6:    0f 1b             	goto 0x61e
 1e0d5a8:    60 ff ff 09 26 00 	if ((r0 & 0xff) == 0) goto 0x4c
 1e0d5ae:    8f f3 b7 c9       	call 0x1f936e
 1e0d5b2:    e5 fc 84 00       	r5 = r14 + 0x84
 1e0d5b6:    11 4a             	r1 = [r5 + 0x4]
 1e0d5b8:    60 b0             	r0 = r0 - r1
 1e0d5ba:    c1 d0             	r1 = r0 >> 0x3
 1e0d5bc:    62 04             	r2 = r1.l (u)
 1e0d5be:    00 fb ff 0f       	r0 = 0xfff
 1e0d5c2:    08 ff fe 2f 01 00 	if (r2 > 0xffe) goto 0x2
 1e0d5c8:    10 08             	r0 = r1
 1e0d5ca:    21 6a             	r1 = b[r5 + 0x2] (u)
 1e0d5cc:    c2 7d             	r2 = 0xdc
 1e0d5ce:    b3 08             	r3 = r11
 1e0d5d0:    80 fe 20 34       	r3 += r4 * r2
 1e0d5d4:    f1 8f             	r1 += -0x1
 1e0d5d6:    62 70             	r2 = 0x6
 1e0d5d8:    80 fe 20 31       	r3 += r1 * r2
 1e0d5dc:    a2 66             	r2 = b[r3 + 0xa] (u)
 1e0d5de:    22 fd 0f 29       	r2 = r2 & 0xf
 1e0d5e2:    dc fd 20 20       	r2 <= insert(r0, p:0x4, l:0x1c)
 1e0d5e6:    aa 66             	b[r3 + 0xa] = r2
 1e0d5e8:    22 04             	r2 = r0.l (u)
 1e0d5ea:    10 d1             	r0 = r2 >> 0x4
 1e0d5ec:    b8 66             	b[r3 + 0xb] = r0
 1e0d5ee:    c0 ff f1 75 e2 01 	r0 = 0x1e275f1
 1e0d5f4:    80 f3 cf 8d       	call 0x11b9e
 1e0d5f8:    11 6a             	r1 = b[r5 + 0x1] (u)
 1e0d5fa:    c2 7d             	r2 = 0xdc
 1e0d5fc:    b0 08             	r0 = r11
 1e0d5fe:    80 fe 20 04       	r0 += r4 * r2
 1e0d602:    63 70             	r3 = 0x6
 1e0d604:    05 08             	r5 = r0
 1e0d606:    80 fe 30 51       	r5 += r1 * r3
 1e0d60a:    a2 6a             	r2 = b[r5 + 0xa] (u)
 1e0d60c:    72 b0             	r2 &= 0xfffffffe
 1e0d60e:    aa 6a             	b[r5 + 0xa] = r2
 1e0d610:    02 f6 d4 e1       	r2 = [r14 + 0x1d4]
 1e0d614:    ca 6a             	b[r5 + 0xc] = r2
 1e0d616:    17 d4             	r7 = r2 >> 0x10
 1e0d618:    ef 6a             	b[r5 + 0xe] = r7
 1e0d61a:    17 d2             	r7 = r2 >> 0x8
 1e0d61c:    df 6a             	b[r5 + 0xd] = r7
 1e0d61e:    36 c6             	r6 = r6 << 0x18
 1e0d620:    52 bc             	r2 |= r6
 1e0d622:    16 d6             	r6 = r2 >> 0x18
 1e0d624:    fe 6a             	b[r5 + 0xf] = r6
 1e0d626:    21 e2 25 10       	if (r1 != 0x22) goto 0x4a
 1e0d62a:    05 f9 86 e0       	r5 = b[r14 + 0x86] (u)
 1e0d62e:    80 fe 30 05       	r0 += r5 * r3
 1e0d632:    f3 60             	r3 = b[r0 + 0xf] (u)
 1e0d634:    e6 60             	r6 = b[r0 + 0xe] (u)
 1e0d636:    d7 60             	r7 = b[r0 + 0xd] (u)
 1e0d638:    c0 60             	r0 = b[r0 + 0xc] (u)
 1e0d63a:    c8 fd 40 63       	r6 <= insert(r3, p:0x8, l:0x8)
 1e0d63e:    c8 fd 40 07       	r0 <= insert(r7, p:0x8, l:0x8)
 1e0d642:    d0 fd 80 06       	r0 <= insert(r6, p:0x10, l:0x10)
 1e0d646:    ad 21             	if (r0 == 0x0) goto -0xa6
 1e0d648:    c3 7d             	r3 = 0xdc
 1e0d64a:    80 fe 30 b4       	r11 += r4 * r3
 1e0d64e:    63 70             	r3 = 0x6
 1e0d650:    80 fe 30 b5       	r11 += r5 * r3
 1e0d654:    03 f9 03 b0       	r3 = b[r11 + 0x3] (u)
 1e0d658:    04 f9 02 b0       	r4 = b[r11 + 0x2] (u)
 1e0d65c:    05 f9 01 b0       	r5 = b[r11 + 0x1] (u)
 1e0d660:    06 f9 00 b0       	r6 = b[r11 + 0x0] (u)
 1e0d664:    c8 fd 40 43       	r4 <= insert(r3, p:0x8, l:0x8)
 1e0d668:    c8 fd 40 65       	r6 <= insert(r5, p:0x8, l:0x8)
 1e0d66c:    d0 fd 80 64       	r6 <= insert(r4, p:0x10, l:0x10)
 1e0d670:    60 f2 97 0f       	if (r0 == r6) goto -0xd2
 1e0d674:    a0 08             	r0 = r10
 1e0d676:    80 f3 8e 8d       	call 0x11b1c
