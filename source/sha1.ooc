import structs/ArrayList

SHA1: class{
    _K0 := const static 0x5A827999
    _K1 := const static 0x6ED9EBA1
    _K2 := const static 0x8F1BBCDC
    _K3 := const static 0xCA62C1D6

    chunkSize := const static 64
    dataLength: UInt64 = 0

    A, B, C, D, E: UInt32

    rem: UInt8[64]
    remSize: UInt = 0

    init: func{
        (A, B, C, D, E) = (
            0x67452301, 0xEFCDAB89,
            0x98BADCFE, 0x10325476,
            0xC3D2E1F0
        )
    }

    reset: func{
        (A, B, C, D, E) = (
            0x67452301, 0xEFCDAB89,
            0x98BADCFE, 0x10325476,
            0xC3D2E1F0
        )

        remSize = 0
        dataLength = 0
    }

    block: func(data: UInt8*, length: UInt64) -> UInt{
        if(length < chunkSize) return length

        pos := 0
        w: UInt32[16]

        // cache
        (h0, h1, h2, h3, h4) := (A, B, C, D, E)

        while(pos < length){
            for(i in 0..16){
                j := pos + i * 4
                w[i] = (data[j] << 24) | (data[j+1] << 16) | (data[j+2] << 8) | data[j+3]
            }
            (a, b, c, d, e) := (h0, h1, h2, h3, h4)
            for(i in 0..16){
                    f := (b & c) | ((~b) & d)
                    a5 := (a<<5) | (a>>(32-5))
                    b30 := (b<<30) | (b>>(32-30))
                    t := a5 + f + e + w[i & 0xf] + _K0
                    (a, b, c, d, e) = (t, a, b30, c, d)
            }
            for(i in 16..20){
                    tmp := w[(i-3) & 0xf] ^ w[(i-8) & 0xf] ^ w[(i-14) & 0xf] ^ w[i & 0xf]
                    w[i & 0xf] = (tmp<<1) | (tmp>>(32-1))

                    f := (b & c) | ((~b) & d)
                    a5 := (a<<5) | (a>>(32-5))
                    b30 := (b<<30) | (b>>(32-30))
                    t := a5 + f + e + w[i & 0xf] + _K0
                    (a, b, c, d, e) = (t, a, b30, c, d)
            }
            for(i in 20..40){
                    tmp := w[(i-3) & 0xf] ^ w[(i-8) & 0xf] ^ w[(i-14) & 0xf] ^ w[i & 0xf]
                    w[i & 0xf] = (tmp<<1) | (tmp>>(32-1))
                    f := b ^ c ^ d
                    a5 := (a<<5) | (a>>(32-5))
                    b30 := (b<<30) | (b>>(32-30))
                    t := a5 + f + e + w[i & 0xf] + _K1
                    (a, b, c, d, e) = (t, a, b30, c, d)
            }
            for(i in 40..60){
                    tmp := w[(i-3) & 0xf] ^ w[(i-8) & 0xf] ^ w[(i-14) & 0xf] ^ w[i & 0xf]
                    w[i & 0xf] = (tmp<<1) | (tmp>>(32-1))
                    f := ((b | c) & d) | (b & c)

                    a5 := (a<<5) | (a>>(32-5))
                    b30 := (b<<30) | (b>>(32-30))
                    t := a5 + f + e + w[i & 0xf] + _K2
                    (a, b, c, d, e) = (t, a, b30, c, d)
            }
            for(i in 60..80){
                    tmp := w[(i-3) & 0xf] ^ w[(i-8) & 0xf] ^ w[(i-14) & 0xf] ^ w[i & 0xf]
                    w[i & 0xf] = (tmp<<1) | (tmp>>(32-1))
                    f := b ^ c ^ d
                    a5 := (a<<5) | (a>>(32-5))
                    b30 := (b<<30) | (b>>(32-30))
                    t := a5 + f + e + w[i & 0xf] + _K3
                    (a, b, c, d, e) = (t, a, b30, c, d)
            }

            h0 += a
            h1 += b
            h2 += c
            h3 += d
            h4 += e

            pos += chunkSize
        }

        (A, B, C, D, E) = (h0, h1, h2, h3, h4)

        length - pos
    }

    write: func(b: UInt8*, length: UInt64){
        dataLength += length

        startPos := 0
        if(remSize > 0){
            startPos = chunkSize - remSize >  length ? length : chunkSize - remSize
            for(i in 0..startPos){
                rem[i + remSize] = b[i]
            }
            remSize += startPos
            if(remSize == chunkSize) block(rem as UInt8*, chunkSize)
        }
        if(length - startPos > 0){
            remSize = block(b[startPos]&, length - startPos)
            if(remSize > 0){
                for(i in 0..remSize){
                    rem[i] = b[length - ( remSize - i )]
                }
            }
        }
    }

    checksum: func{
        lengthinBit: UInt64 = (8 * dataLength) & 0xFFFFFFFFFFFFFFFF
        tmp := ArrayList<UInt8> new()
        tmp add(0x80)
        for(i in 0..63) tmp add(0)
        if(dataLength % 64 < 56){
            write(tmp data as UInt8*, 56 - dataLength%64)
        } else {
            write(tmp data as UInt8*, 64 + 56 - dataLength%64)
        }
        for(i in 0..8){
            write((lengthinBit& as UInt8*)[7-i]&, 1)
        }
    }
}
