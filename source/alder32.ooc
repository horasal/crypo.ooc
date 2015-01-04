Alder32: class {
    a: UInt32 = 1
    b: UInt32 = 0

    hash: UInt32 = 0

    prime: const UInt32 = 65521

    init: func

    reset: func{
        a = 1
        b = 0
        hash = 0
    }

    write: func(data: UInt8*, length: UInt64){
        for(i in 0..length){
            a = (a + data[i]) % prime
            b = (b + a) % prime
        }
    }

    checksum: func -> UInt32 { hash = b << 16 | a }
}
