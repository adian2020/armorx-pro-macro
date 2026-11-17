 1e0a7dc:    7f 01             	[--sp] = {rets, r15-r4}
 1e0a7de:    fe 0b             	sp += -0x4
 1e0a7e0:    ca ff 50 4c 00 00 	r10 = 0x4c50
 1e0a7e6:    0c f9 84 a0       	r12 = b[r10 + 0x84] (u)
 1e0a7ea:    3c e0 39 81       	if (r12 > 0x3) goto 0x272
 1e0a7ee:    c8 ff 50 48 00 00 	r8 = 0x4850
 1e0a7f4:    0b f6 b8 81       	r11 = [r8 + 0x1b8]
 1e0a7f8:    c0 7d             	r0 = 0xdc
 1e0a7fa:    b1 08             	r1 = r11
 1e0a7fc:    80 fe 00 1c       	r1 += r12 * r0
 1e0a800:    00 f9 87 a0       	r0 = b[r10 + 0x87] (u)
 1e0a804:    a1 80             	r1 += 0xa
 1e0a806:    62 70             	r2 = 0x6
 1e0a808:    13 08             	r3 = r1
 1e0a80a:    06 f9 86 a0       	r6 = b[r10 + 0x86] (u)
 1e0a80e:    80 fe 20 30       	r3 += r0 * r2
 1e0a812:    04 f9 fb 3f       	r4 = b[r3 + -0x5] (u)
 1e0a816:    03 f9 fa 3f       	r3 = b[r3 + -0x6] (u)
 1e0a81a:    60 fc ff ff       	r0 = r6 + -0x1
 1e0a81e:    80 fe 20 10       	r1 += r0 * r2
 1e0a822:    02 62             	r2 = b[r1 + 0x0] (u)
 1e0a824:    11 62             	r1 = b[r1 + 0x1] (u)
 1e0a826:    1d d1             	r5 = r3 >> 0x4
 1e0a828:    c8 fd 20 54       	r5 <= insert(r4, p:0x4, l:0x8)
 1e0a82c:    14 d1             	r4 = r2 >> 0x4
 1e0a82e:    c8 fd 20 41       	r4 <= insert(r1, p:0x4, l:0x8)
 1e0a832:    2f 2c             	if (r6 == 0x0) goto 0x5e
 1e0a834:    2e 38             	if (r4 != 0x0) goto 0x5c
 1e0a836:    c1 7d             	r1 = 0xdc
 1e0a838:    b6 08             	r6 = r11
 1e0a83a:    80 fe 10 6c       	r6 += r12 * r1
 1e0a83e:    64 70             	r4 = 0x6
 1e0a840:    61 08             	r1 = r6
 1e0a842:    80 fe 40 10       	r1 += r0 * r4
 1e0a846:    f0 62             	r0 = b[r1 + 0xf] (u)
 1e0a848:    e2 62             	r2 = b[r1 + 0xe] (u)
 1e0a84a:    d3 62             	r3 = b[r1 + 0xd] (u)
 1e0a84c:    c1 62             	r1 = b[r1 + 0xc] (u)
 1e0a84e:    c8 fd 40 20       	r2 <= insert(r0, p:0x8, l:0x8)
 1e0a852:    c8 fd 40 13       	r1 <= insert(r3, p:0x8, l:0x8)
 1e0a856:    d0 fd 80 12       	r1 <= insert(r2, p:0x10, l:0x10)
 1e0a85a:    1a 22             	if (r1 == 0x0) goto 0x34
 1e0a85c:    8f f3 60 e0       	call 0x1fc0c0
 1e0a860:    01 f9 86 a0       	r1 = b[r10 + 0x86] (u)
 1e0a864:    f1 8f             	r1 += -0x1
 1e0a866:    80 fe 40 61       	r6 += r1 * r4
 1e0a86a:    a2 6c             	r2 = b[r6 + 0xa] (u)
 1e0a86c:    03 f6 88 a0       	r3 = [r10 + 0x88]
 1e0a870:    22 fd 0f 29       	r2 = r2 & 0xf
 1e0a874:    e0 b0             	r0 = r0 - r3
 1e0a876:    c4 d0             	r4 = r0 >> 0x3
 1e0a878:    dc fd 20 24       	r2 <= insert(r4, p:0x4, l:0x1c)
 1e0a87c:    aa 6c             	b[r6 + 0xa] = r2
 1e0a87e:    c0 d1             	r0 = r0 >> 0x7
 1e0a880:    b8 6c             	b[r6 + 0xb] = r0
 1e0a882:    22 05             	r2 = r4.l (u)
 1e0a884:    c0 ff f1 75 e2 01 	r0 = 0x1e275f1
 1e0a88a:    80 f3 84 a4       	call 0x14908
 1e0a88e:    01 18             	goto 0x2
 1e0a890:    04 70             	r4 = 0x0
 1e0a892:    2f 3a             	if (r5 != 0x0) goto 0x5e
 1e0a894:    00 f9 87 a0       	r0 = b[r10 + 0x87] (u)
 1e0a898:    2c 20             	if (r0 == 0x0) goto 0x58
 1e0a89a:    c1 7d             	r1 = 0xdc
 1e0a89c:    b5 08             	r5 = r11
 1e0a89e:    80 fe 10 5c       	r5 += r12 * r1
 1e0a8a2:    66 70             	r6 = 0x6
 1e0a8a4:    51 08             	r1 = r5
 1e0a8a6:    80 fe 60 10       	r1 += r0 * r6
 1e0a8aa:    90 62             	r0 = b[r1 + 0x9] (u)
 1e0a8ac:    82 62             	r2 = b[r1 + 0x8] (u)
 1e0a8ae:    73 62             	r3 = b[r1 + 0x7] (u)
 1e0a8b0:    61 62             	r1 = b[r1 + 0x6] (u)
 1e0a8b2:    c8 fd 40 20       	r2 <= insert(r0, p:0x8, l:0x8)
 1e0a8b6:    c8 fd 40 13       	r1 <= insert(r3, p:0x8, l:0x8)
 1e0a8ba:    d0 fd 80 12       	r1 <= insert(r2, p:0x10, l:0x10)
 1e0a8be:    19 22             	if (r1 == 0x0) goto 0x32
 1e0a8c0:    8f f3 2e e0       	call 0x1fc05c
 1e0a8c4:    01 f9 87 a0       	r1 = b[r10 + 0x87] (u)
 1e0a8c8:    f1 8f             	r1 += -0x1
 1e0a8ca:    80 fe 60 51       	r5 += r1 * r6
 1e0a8ce:    a2 6a             	r2 = b[r5 + 0xa] (u)
 1e0a8d0:    03 f6 8c a0       	r3 = [r10 + 0x8c]
 1e0a8d4:    22 fd 0f 29       	r2 = r2 & 0xf
 1e0a8d8:    e0 b0             	r0 = r0 - r3
 1e0a8da:    c3 d0             	r3 = r0 >> 0x3
 1e0a8dc:    dc fd 20 23       	r2 <= insert(r3, p:0x4, l:0x1c)
 1e0a8e0:    aa 6a             	b[r5 + 0xa] = r2
 1e0a8e2:    c0 d1             	r0 = r0 >> 0x7
 1e0a8e4:    b8 6a             	b[r5 + 0xb] = r0
 1e0a8e6:    e2 04             	r2 = r3.l (u)
 1e0a8e8:    c0 ff 07 76 e2 01 	r0 = 0x1e27607
 1e0a8ee:    80 f3 52 a4       	call 0x148a4
 1e0a8f2:    02 f9 85 a0       	r2 = b[r10 + 0x85] (u)
 1e0a8f6:    c0 7d             	r0 = 0xdc
 1e0a8f8:    b1 08             	r1 = r11
 1e0a8fa:    80 fe 00 1c       	r1 += r12 * r0
 1e0a8fe:    20 fc ff ff       	r0 = r2 + -0x1
 1e0a902:    63 70             	r3 = 0x6
 1e0a904:    80 fe 30 10       	r1 += r0 * r3
 1e0a908:    f3 62             	r3 = b[r1 + 0xf] (u)
 1e0a90a:    e5 62             	r5 = b[r1 + 0xe] (u)
 1e0a90c:    d6 62             	r6 = b[r1 + 0xd] (u)
 1e0a90e:    c7 62             	r7 = b[r1 + 0xc] (u)
 1e0a910:    c8 fd 40 53       	r5 <= insert(r3, p:0x8, l:0x8)
 1e0a914:    c8 fd 40 76       	r7 <= insert(r6, p:0x8, l:0x8)
 1e0a918:    d0 fd 80 75       	r7 <= insert(r5, p:0x10, l:0x10)
 1e0a91c:    09 3e             	if (r7 != 0x0) goto 0x12
 1e0a91e:    a2 62             	r2 = b[r1 + 0xa] (u)
 1e0a920:    03 70             	r3 = 0x0
 1e0a922:    bb 62             	b[r1 + 0xb] = r3
 1e0a924:    22 fd 0e 29       	r2 = r2 & 0xe
 1e0a928:    aa 62             	b[r1 + 0xa] = r2
 1e0a92a:    10 f9 85 a0       	b[r10 + 0x85] = r0
 1e0a92e:    02 08             	r2 = r0
 1e0a930:    60 ff ff 29 4b 00 	if ((r2 & 0xff) == 0) goto 0x96
 1e0a936:    2f 05             	r15 = r4.l (u)
 1e0a938:    05 70             	r5 = 0x0
 1e0a93a:    c8 ff 21 76 e2 01 	r8 = 0x1e27621
 1e0a940:    c0 7d             	r0 = 0xdc
 1e0a942:    b6 08             	r6 = r11
 1e0a944:    80 fe 00 6c       	r6 += r12 * r0
 1e0a948:    6e 70             	r14 = 0x6
 1e0a94a:    cd ff 3c 76 e2 01 	r13 = 0x1e2763c
 1e0a950:    04 70             	r4 = 0x0
 1e0a952:    80 08             	r0 = r8
 1e0a954:    80 f3 1f a4       	call 0x1483e
 1e0a958:    67 08             	r7 = r6
 1e0a95a:    80 fe e0 75       	r7 += r5 * r14
 1e0a95e:    f0 6e             	r0 = b[r7 + 0xf] (u)
 1e0a960:    e1 6e             	r1 = b[r7 + 0xe] (u)
 1e0a962:    d2 6e             	r2 = b[r7 + 0xd] (u)
 1e0a964:    c3 6e             	r3 = b[r7 + 0xc] (u)
 1e0a966:    09 f9 0a 70       	r9 = b[r7 + 0xa] (u)
 1e0a96a:    c8 fd 40 10       	r1 <= insert(r0, p:0x8, l:0x8)
 1e0a96e:    c8 fd 40 32       	r3 <= insert(r2, p:0x8, l:0x8)
 1e0a972:    d0 fd 80 31       	r3 <= insert(r1, p:0x10, l:0x10)
 1e0a976:    22 fd 01 99       	r2 = r9 & 0x1
 1e0a97a:    0b 02             	[sp] = r3
 1e0a97c:    d0 08             	r0 = r13
 1e0a97e:    51 08             	r1 = r5
 1e0a980:    f3 08             	r3 = r15
 1e0a982:    80 f3 08 a4       	call 0x14810
 1e0a986:    a0 6e             	r0 = b[r7 + 0xa] (u)
 1e0a988:    20 f3 14 00       	if ((r0 & 0x1) != 0) goto 0x28
 1e0a98c:    c0 9e             	r0 = r7 + 0xc
 1e0a98e:    31 60             	r1 = b[r0 + 0x3] (u)
 1e0a990:    22 60             	r2 = b[r0 + 0x2] (u)
 1e0a992:    13 60             	r3 = b[r0 + 0x1] (u)
 1e0a994:    c5 6e             	r5 = b[r7 + 0xc] (u)
 1e0a996:    c8 fd 40 21       	r2 <= insert(r1, p:0x8, l:0x8)
 1e0a99a:    c8 fd 40 53       	r5 <= insert(r3, p:0x8, l:0x8)
 1e0a99e:    d0 fd 80 52       	r5 <= insert(r2, p:0x10, l:0x10)
 1e0a9a2:    30 fb 00 15       	r1 = rev8(r5)
 1e0a9a6:    c9 6e             	b[r7 + 0xc] = r1
 1e0a9a8:    0a d6             	r2 = r1 >> 0x18
 1e0a9aa:    3a 60             	b[r0 + 0x3] = r2
 1e0a9ac:    0a d4             	r2 = r1 >> 0x10
 1e0a9ae:    2a 60             	b[r0 + 0x2] = r2
 1e0a9b0:    09 d2             	r1 = r1 >> 0x8
 1e0a9b2:    19 60             	b[r0 + 0x1] = r1
 1e0a9b4:    07 f9 85 a0       	r7 = b[r10 + 0x85] (u)
 1e0a9b8:    14 80             	r4 += 0x1
 1e0a9ba:    05 05             	r5 = r4.b0 (u)
 1e0a9bc:    75 f2 c9 3f       	if (r5 < r7) goto -0x6e
 1e0a9c0:    01 fe 06 79       	r1 = r7 * 0x6
 1e0a9c4:    c8 ff 50 48 00 00 	r8 = 0x4850
 1e0a9ca:    02 18             	goto 0x4
 1e0a9cc:    07 70             	r7 = 0x0
 1e0a9ce:    01 70             	r1 = 0x0
 1e0a9d0:    c0 7d             	r0 = 0xdc
 1e0a9d2:    80 fe 00 bc       	r11 += r12 * r0
 1e0a9d6:    a4 92             	r4 = r1 + 0xa
 1e0a9d8:    20 d2             	r0 = r4 >> 0x8
 1e0a9da:    10 f9 02 b0       	b[r11 + 0x2] = r0
 1e0a9de:    22 c2             	r2 = r4 << 0x8
 1e0a9e0:    50 b4             	r0 |= r2
 1e0a9e2:    00 d2             	r0 = r0 >> 0x8
 1e0a9e4:    10 f9 03 b0       	b[r11 + 0x3] = r0
 1e0a9e8:    b0 fc 02 00       	r0 = r11 + 0x2
 1e0a9ec:    81 80             	r1 += 0x8
 1e0a9ee:    61 04             	r1 = r1.l (u)
 1e0a9f0:    bf f3 aa d6       	call -0x52ac
 1e0a9f4:    30 fb 00 00       	r0 = rev8(r0)
 1e0a9f8:    01 d6             	r1 = r0 >> 0x18
 1e0a9fa:    11 f9 01 b0       	b[r11 + 0x1] = r1
 1e0a9fe:    02 d4             	r2 = r0 >> 0x10
 1e0aa00:    12 f9 00 b0       	b[r11 + 0x0] = r2
 1e0aa04:    01 f9 84 a0       	r1 = b[r10 + 0x84] (u)
 1e0aa08:    c0 ff 53 76 e2 01 	r0 = 0x1e27653
 1e0aa0e:    0a 02             	[sp] = r2
 1e0aa10:    72 08             	r2 = r7
 1e0aa12:    43 08             	r3 = r4
 1e0aa14:    80 f3 bf a3       	call 0x1477e
 1e0aa18:    00 f9 85 a0       	r0 = b[r10 + 0x85] (u)
 1e0aa1c:    05 20             	if (r0 == 0x0) goto 0xa
 1e0aa1e:    40 70             	r0 = 0x4
 1e0aa20:    10 f6 b4 81       	[r8 + 0x1b4] = r0
 1e0aa24:    90 70             	r0 = 0x9
 1e0aa26:    04 18             	goto 0x8
 1e0aa28:    30 70             	r0 = 0x3
 1e0aa2a:    10 f6 b4 81       	[r8 + 0x1b4] = r0
 1e0aa2e:    a0 70             	r0 = 0xa
 1e0aa30:    bf f3 d0 f6       	call -0x1260
 1e0aa34:    10 70             	r0 = 0x1
 1e0aa36:    10 f9 e4 81       	b[r8 + 0x1e4] = r0
 1e0aa3a:    00 f6 b0 81       	r0 = [r8 + 0x1b0]
 1e0aa3e:    90 60             	r0 = b[r0 + 0x9] (u)
 1e0aa40:    21 fd 01 09       	r1 = r0 & 0x1
 1e0aa44:    c2 ff 50 4a 00 00 	r2 = 0x4a50
 1e0aa4a:    11 f9 d6 21       	b[r2 + 0x1d6] = r1
 1e0aa4e:    20 fd 02 09       	r0 = r0 & 0x2
 1e0aa52:    10 f9 db 21       	b[r2 + 0x1db] = r0
 1e0aa56:    00 70             	r0 = 0x0
 1e0aa58:    10 f9 16 80       	b[r8 + 0x16] = r0
 1e0aa5c:    bf f3 38 d6       	call -0x5390
 1e0aa60:    02 0a             	sp += 0x4
 1e0aa62:    5f 01             	{pc, r15-r4} = [sp++]
