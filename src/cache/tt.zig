pub const std = @import("std");

pub const MB: usize = 1 << 20;
pub const KB: usize = 1 << 10;

pub var TTArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub const TTFlag = enum(u3) {
    Invalid,
    Upper,
    Lower,
    Exact,
};

pub const TTData = packed struct {
    hash: u64,
    depth: u8,
    score: i16,
    bm: u24,
    flag: TTFlag,
};

pub const TT = struct {
    data: std.ArrayList(TTData),
    size: usize,

    pub fn new(mb: usize) TT {
        var tt = TT{
            .data = std.ArrayList(TTData).init(TTArena.allocator()),
            .size = mb * MB / @sizeOf(TTData),
        };

        tt.data.ensureTotalCapacity(tt.size) catch {};
        tt.data.expandToCapacity();

        std.debug.print("Allocated {} KB, {} items for TT\n", .{ tt.size * @sizeOf(TTData) / KB, tt.size });

        return tt;
    }

    pub fn reset(self: *TT) void {
        for (self.data.items) |*ptr| {
            ptr.* = std.mem.zeroes(TTData);
        }
    }

    pub fn deinit(self: *TT) void {
        self.data.deinit();
    }

    pub fn probe(self: *TT, hash: u64) ?*TTData {
        var entry = &self.data.items[hash % self.size];

        if (entry.hash == hash and entry.flag != TTFlag.Invalid and entry.bm != 0 and entry.depth != 0) {
            return entry;
        }

        return null;
    }

    pub fn insert(self: *TT, hash: u64, depth: u8, score: i16, flag: TTFlag, bm: u24) void {
        self.data.items[hash % self.size] = TTData{
            .hash = hash,
            .depth = depth,
            .score = score,
            .flag = flag,
            .bm = bm,
        };
    }

    pub fn hashfull(self: *TT) usize {
        var count: usize = 0;
        if (self.size <= 10000) {
            var i: usize = @minimum(self.size, 1000) / 2 - 500;
            const to: usize = i + 1000;
            while (i < to) : (i += 1) {
                if (self.data.items[i].flag != TTFlag.Invalid and self.data.items[i].hash != 0) {
                    count += 1;
                }
            }
        } else {
            var i: usize = self.size / 2 - 2000;
            const to: usize = i + 4000;
            while (i < to) : (i += 1) {
                if (self.data.items[i].flag != TTFlag.Invalid and self.data.items[i].hash != 0) {
                    count += 1;
                }
            }
            count >>= 2;
        }
        return count;
    }
};
