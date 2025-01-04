pub const GdtEntry = packed struct {
    limit: u16,
    base_low: u16,
    base_mid: u8,
    access: u8,
    flags: u8,
    base_high: u8,
};

pub const GdtPtr = packed struct {
    limit: u16,
    base: usize,
};

var gdt_entries: [5]GdtEntry = undefined;
var gdt_ptr: GdtPtr = undefined;

extern fn loadGDT(*GdtPtr) void;

pub fn initGdt() void {
    gdt_ptr.limit = @sizeOf(@TypeOf(gdt_entries)) - 1;
    gdt_ptr.base = @intFromPtr(&gdt_entries[0]);

    setGdtGate(0, 0, 0, 0, 0); // Null Segment
    setGdtGate(1, 0, 0xffffffff, 0x9a, 0xcf); // Kernel code segment
    setGdtGate(2, 0, 0xffffffff, 0x92, 0xcf); // kernel data segment
    setGdtGate(3, 0, 0xffffffff, 0xfa, 0xcf); // user code segment
    setGdtGate(4, 0, 0xffffffff, 0xf2, 0xcf); // user data segment

    loadGDT(&gdt_ptr);
}

pub fn setGdtGate(num: u32, base: u32, limit: u32, access: u8, gran: u8) void {
    gdt_entries[num].base_low = @intCast(base & 0xffff);
    gdt_entries[num].base_mid = @intCast((base >> 16) & 0xff);
    gdt_entries[num].base_high = @intCast((base >> 24) & 0xff);
    gdt_entries[num].limit = @intCast(limit & 0xffff);
    gdt_entries[num].flags = @intCast((limit >> 16) & 0x0f);
    gdt_entries[num].flags |= @intCast(gran & 0xf0);
    gdt_entries[num].access = access;
}
