pub fn kmain() callconv(.C) void {
    const gdt = @import("gdt.zig");
    const vga = @import("./vga.zig");
    vga.initialize();
    vga.setColor(vga.vgaEntryColor(.Black, .Green));

    vga.printf("OK from {s}!", .{"rkos"});
    gdt.initGdt();
    vga.printf("OK from {s}!", .{"gdt"});
    hang();
}

fn hang() void {
    asm volatile ("hlt");
}
