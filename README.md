crypo.ooc
=========

mostly translated from [Go-lang](https://code.google.com/p/go/)

## MD5: How to use

    import crypo/md5
	a := "test string"
	md5 := MD5 new()
	md5 write(a toCString() as UInt8*, a size)
	md5 checksum()
	"%.8x, %.8x, %.8x, %.8x" printfln(md5 A, md5 B, md5 C, md5 D)


## CRC32: How to Use

    import crypo/crc32
	a := "test string"
	crc32 := crc32 new()
	// crc32 makeTable(crc32 IEEE)
	crc32 write(a toCString() as UInt8*, a size)
	"%.8x" printfln(crc32 checksum())
