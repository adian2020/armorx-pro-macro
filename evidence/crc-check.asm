 1e05748:    75 01             	[--sp] = {rets, r5, r4}
 1e0574a:    c3 ff ff ff 00 00 	r3 = 0xffff
 1e05750:    1a 22             	if (r1 == 0x0) goto 0x34
 1e05752:    c2 ff 00 99 e2 01 	r2 = 0x1e29900
 1e05758:    84 f9 01 00       	r4 = b[r0 ++= 0x1] (u)
 1e0575c:    e1 fd 30 54       	r5 = r4 ^ r3
 1e05760:    25 fd 0f 59       	r5 = r5 & 0xf
 1e05764:    45 f8 00 25       	r5 = h[r2+r5<<1] (u)
 1e05768:    8c fd 20 33       	r3 = uextra(r3, p:0x4, l:0xc)
 1e0576c:    d3 ba             	r3 ^= r5
 1e0576e:    25 fd 0f 39       	r5 = r3 & 0xf
 1e05772:    24 d1             	r4 = r4 >> 0x4
 1e05774:    d4 ba             	r4 ^= r5
 1e05776:    44 f8 00 24       	r4 = h[r2+r4<<1] (u)
 1e0577a:    8c fd 20 33       	r3 = uextra(r3, p:0x4, l:0xc)
 1e0577e:    f1 8f             	r1 += -0x1
 1e05780:    65 04             	r5 = r1.l (u)
 1e05782:    d3 b8             	r3 ^= r4
 1e05784:    e9 3b             	if (r5 != 0x0) goto -0x2e
 1e05786:    e0 04             	r0 = r3.l (u)
 1e05788:    55 01             	{pc, r5, r4} = [sp++]
 1e0578a:    75 01             	[--sp] = {rets, r5, r4}
 1e0578c:    22 60             	r2 = b[r0 + 0x2] (u)
 1e0578e:    34 60             	r4 = b[r0 + 0x3] (u)
 1e05790:    c8 fd 40 42       	r4 <= insert(r2, p:0x8, l:0x8)
 1e05794:    44 e0 18 30       	if (r4 < 0x4) goto 0x30
 1e05798:    14 f2 16 80       	if (r4 > r1) goto 0x2c
 1e0579c:    01 60             	r1 = b[r0 + 0x0] (u)
 1e0579e:    15 60             	r5 = b[r0 + 0x1] (u)
 1e057a0:    20 80             	r0 += 0x2
 1e057a2:    c8 fd 40 51       	r5 <= insert(r1, p:0x8, l:0x8)
 1e057a6:    c1 ff fe ff 00 00 	r1 = 0xfffe
 1e057ac:    41 09             	r1 += r4
 1e057ae:    61 04             	r1 = r1.l (u)
 1e057b0:    cb 17             	call -0x6a
 1e057b2:    01 08             	r1 = r0
 1e057b4:    10 70             	r0 = 0x1
 1e057b6:    15 f2 0d 00       	if (r5 == r1) goto 0x1a
 1e057ba:    c0 ff 13 72 e2 01 	r0 = 0x1e27213
 1e057c0:    42 08             	r2 = r4
 1e057c2:    80 f3 e8 cc       	call 0x199d0
 1e057c6:    05 18             	goto 0xa
 1e057c8:    c0 ff 06 72 e2 01 	r0 = 0x1e27206
