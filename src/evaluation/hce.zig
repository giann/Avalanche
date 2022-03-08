const Position = @import("../board/position.zig");
const Piece = @import("../board/piece.zig");
const C = @import("../c.zig");

// Hand-Crafted Evaluation

pub const PieceValues: [12]i16 = .{
    95, // P
    370, // N
    390, // B
    590, // R
    1100, // Q
    0, // K
    -95, // p
    -370, // n
    -390, // b
    -590, // r
    -1100, // q
    -0, // k
};

pub const PieceValuesEg: [12]i16 = .{
    115, // P
    310, // N
    270, // B
    680, // R
    1300, // Q
    0, // K
    -115, // p
    -310, // n
    -270, // b
    -680, // r
    -1300, // q
    -0, // k
};

// ^ 56 for black
// zig fmt: off
pub const PSQT: [6][64]i16 = .{
    // Pawn
    .{
        000, 000, 000, 000, 000, 000, 000, 000,
        150, 120, 120, 130, 130, 120, 120, 150,
        090, 060, 060, 070, 070, 060, 050, 090,
        012, 010, 015, 035, 032, -05, 005, 012,
        004, 003, 011, 020, 020, 008, -08, 003,
        005, 015, -02, 008, 008, -06, 013, 005,
        004, 005, 007, -09, -09, 010, 006, 004,
        000, 000, 000, 000, 000, 000, 000, 000,
    },
    // Knight
    .{
        -50, -40, -30, -30, -30, -30, -40, -50,
        -40, -20, 000, 000, 000, 000, -20, -40,
        -30, 000, 010, 015, 015, 010, 000, -30,
        -30, 000, 015, 020, 020, 015, 000, -30,
        -30, 000, 015, 017, 017, 015, 000, -30,
        -30, -20, 006, 015, 015, 010, -20, -30,
        -40, -20, 000, 000, 000, 000, -20, -40,
        -50, -40, -30, -30, -30, -30, -40, -50,
    },
    // Bishop
    .{
        -20, -10, -10, -10, -10, -10, -10, -20,
        -10, 000, 000, 000, 000, 000, 000, -10,
        -10, 000, 005, 010, 010, 005, 000, -10,
        -10, 017, 005, 012, 012, 005, 017, -10,
        -10, 000, 015, 012, 012, 015, 000, -10,
        -10, 010, 010, 010, 010, 010, 010, -10,
        -10, 016, 000, 000, 000, 000, 016, -10,
        -20, -10, -10, -10, -10, -10, -10, -20,
    },
    // Rook
    .{
        000, 000, 000, 003, 003, 000, 000, 000,
        005, 010, 014, 014, 014, 014, 010, 005,
        -05, 000, 000, 000, 000, 000, 000, -05,
        -05, 000, 000, 000, 000, 000, 000, -05,
        -05, 000, 000, 000, 000, 000, 000, 002,
        001, 002, 000, 000, 000, 000, 004, 001,
        -05, 000, 000, 000, 000, 000, 000, -05,
        000, 000, 000, 007, 008, 003, 002, 000,
    },
    // Queen
    .{
        -20, -10, -10, -03, -03, -10, -10, -20,
        -10, 000, 000, 000, 000, 000, 000, -10,
        -10, 000, 005, 010, 010, 005, 000, -10,
        -01, 005, 005, 010, 010, 005, 005, -02,
        002, 000, 010, 010, 010, 010, 000, 000,
        -10, 010, 012, 010, 010, 010, 010, -10,
        -10, 005, 000, 000, 000, 000, 005, -10,
        -20, -10, -10, -01, -03, -10, -10, -20,
    },
    // King
    .{
        -10, 000, -05, -10, -10, -05, 000, -10,
        -03, 000, -05, -10, -10, -05, 000, -03,
        -05, 000, -10, -20, -20, -10, 000, -05,
        -05, -05, -10, -20, -20, -10, -05, -05,
        -05, -05, -10, -20, -20, -10, -05, -05,
        -05, -05, -10, -20, -20, -10, -05, -05,
        -05, -05, -10, -10, -08, -04, -05, -05,
        001, 012, 010, 000, 000, 004, 011, 003,
    }
};

pub const PSQT_EG: [6][64]i16 = .{
    // Pawn
    .{
        000, 000, 000, 000, 000, 000, 000, 000,
        250, 330, 350, 380, 380, 350, 330, 250,
        090, 110, 120, 135, 135, 120, 110, 090,
        050, 040, 045, 050, 050, 045, 040, 050,
        020, 020, 015, 020, 020, 015, 020, 020,
        005, 005, 005, 010, 010, 005, 005, 005,
        -20, -20, -10, -05, -05, -10, -20, -20,
        000, 000, 000, 000, 000, 000, 000, 000,
    },
    // Knight
    .{
        -50, -40, -30, -30, -30, -30, -40, -50,
        -40, -20, 000, 000, 000, 000, -20, -40,
        020, 050, 050, 055, 055, 050, 050, 020,
        000, 010, 015, 020, 020, 015, 010, 000,
        -30, 000, 015, 017, 017, 015, 000, -30,
        -30, -20, 000, 015, 015, 000, -20, -30,
        -40, -20, 000, 000, 000, 000, -20, -40,
        -50, -40, -30, -30, -30, -30, -40, -50,
    },
    // Bishop
    .{
        -20, -10, -10, -10, -10, -10, -10, -20,
        -10, 000, 000, 000, 000, 000, 000, -10,
        -10, 000, 005, 010, 010, 005, 000, -10,
        -10, 005, 005, 010, 010, 005, 005, -10,
        -10, 000, 015, 010, 010, 015, 000, -10,
        -10, 010, 010, 010, 010, 010, 010, -10,
        -10, 015, 000, 000, 000, 000, 015, -10,
        -20, -10, -10, -10, -10, -10, -10, -20,
    },
    // Rook
    .{
        020, 020, 020, 020, 020, 020, 020, 020,
        005, 010, 020, 030, 030, 020, 010, 005,
        -05, 000, 000, 010, 010, 000, 000, -05,
        -05, 000, 000, 000, 000, 000, 000, -05,
        -05, 000, 000, 000, 000, 000, 000, 002,
        001, 002, 000, 000, 000, 000, 004, 001,
        -05, 000, 000, 000, 000, 000, 000, -05,
        000, 000, 000, 000, 000, 000, 000, 000,
    },
    // Queen
    .{
        -20, -10, -10, -03, -03, -10, -10, -20,
        -10, 000, 000, 000, 000, 000, 000, -10,
        -10, 000, 005, 010, 010, 005, 000, -10,
        -01, 005, 005, 010, 010, 005, 005, -02,
        002, 000, 010, 010, 010, 010, 000, 000,
        -10, 010, 012, 010, 010, 010, 010, -10,
        -10, 005, 000, 000, 000, 000, 005, -10,
        -20, -10, -10, -01, -03, -10, -10, -20,
    },
    // King
    .{
        000, 000, -05, -10, -10, -05, 000, 000,
        -10, 030, -05, 000, 000, -05, 030, -10,
        -20, 000, 020, 030, 030, 020, 000, -20,
        -30, -05, 030, 040, 040, 030, -05, -30,
        -30, -05, 030, 040, 040, 030, -05, -30,
        -30, -05, 020, 030, 030, 020, -05, -30,
        -30, -25, -20, -05, -05, -20, -25, -30,
        -50, -40, -40, -30, -30, -40, -40, -50,
    }
};

// zig fmt: on

pub const BISHOP_PAIR: i16 = 40;

pub fn evaluate(position: *Position.Position) i16 {
    var score: i16 = 0;

    var eg = position.phase() <= 7;

    for (position.mailbox) |p, i| {
        if (p == null) {
            continue;
        }
        if (eg) {
            score += PieceValuesEg[@enumToInt(p.?)];
        } else {
            score += PieceValues[@enumToInt(p.?)];
        }
        if (p.?.color() == Piece.Color.White) {
            if (eg) {
                score += PSQT_EG[@enumToInt(p.?) % 6][i];
            } else {
                score += PSQT[@enumToInt(p.?) % 6][i];
            }
        } else {
            if (eg) {
                score -= PSQT_EG[@enumToInt(p.?) % 6][i ^ 56];
            } else {
                score -= PSQT[@enumToInt(p.?) % 6][i ^ 56];
            }
        }
    }

    // Bishop pair
    if (@popCount(u64, position.bitboards.WhiteBishops) >= 2) {
        score += BISHOP_PAIR;
    }
    if (@popCount(u64, position.bitboards.BlackBishops) >= 2) {
        score -= BISHOP_PAIR;
    }

    return score;
}
