typedef logic [6:0]       id_t;
typedef enum logic [1:0] {
	FIXED = 2'b00,
	INCR  = 2'b01,
	WRAP  = 2'b10,
	RESERVED = 2'b11
	} BURST_TYPE;

typedef enum logic [1:0] {
	OKAY = 2'b00,
	EXOKAY = 2'b01,
	DECERR = 2'b10,
	SLVERR = 2'b11
	} RESPONSE_TYPE;

typedef enum logic [1:0]{
	NORMAL_ACCESS = 2'b00,
	EXCLUSIVE_ACCESS = 2'b01,
	LOCKED_ACCESS = 2'b10,
	REVD = 2'b11
	} LOCK_TYPE;

typedef enum bit{
	WRITE = 0,
	READ  = 1
}TRANS_TYPE;
