pub fn kmain() callconv(.C) void {
    // const gdt = @import("gdt.zig");
    const idt = @import("./idt.zig");
    const vga = @import("./vga.zig");
    vga.initialize();
    vga.setColor(vga.vgaEntryColor(.Black, .Green));

    for (0..10) |i| {
        vga.printf("say {d}\n", .{i});
    }
    vga.printf("OK from {s}!\n", .{"rkos"});
    // gdt.initGdt();
    vga.printf("OK from {s}!\n", .{"gdt"});
    idt.idt_init();
    vga.printf("OK from {s}!\n", .{"idt"});
    hang();
}

fn hang() void {
    asm volatile ("hlt");
}
