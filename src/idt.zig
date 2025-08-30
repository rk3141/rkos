const IDTEntry = packed struct { isr_low: u16, kernel_cs: u16, reserved: u8, attributes: u8, isr_high: u16 };
const IDTRegister = packed struct { limit: u16, base: *IDTEntry };

var idt_table: [256]IDTEntry align(16) = undefined;
const size_of_idt_table = @sizeOf(@TypeOf(idt_table));

var idtr: IDTRegister = undefined;

fn exception_handler() callconv(.Naked) noreturn {
    asm volatile (
        \\cli
        \\hlt
    );
}

var isr_stub_table: [32]*const fn () callconv(.Naked) void = .{
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_err_stub,
    isr_no_err_stub,
    isr_err_stub,
    isr_err_stub,
    isr_err_stub,
    isr_err_stub,
    isr_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_no_err_stub,
    isr_err_stub,
    isr_no_err_stub,
};

fn isr_err_stub() callconv(.Naked) void {
    asm volatile (
        \\call %[exception_handler:P] 
        \\iret
        :
        : [exception_handler] "X" (&exception_handler),
    );
}
fn isr_no_err_stub() callconv(.Naked) void {
    asm volatile (
        \\call %[exception_handler:P] 
        \\iret
        :
        : [exception_handler] "X" (&exception_handler),
    );
}

fn idt_set_descriptor(vector: usize, isr: *const fn () callconv(.Naked) void, flags: u8) void {
    idt_table[vector].isr_low = @truncate(@intFromPtr(isr));
    idt_table[vector].isr_high = @truncate(@intFromPtr(isr) >> 16);
    idt_table[vector].kernel_cs = 0x08;
    idt_table[vector].attributes = flags;
    idt_table[vector].reserved = 0;
}

var vectors: [idt_table.len]bool = undefined;

pub fn idt_init() void {
    idtr.limit = size_of_idt_table - 1;
    idtr.base = &idt_table[0];

    for (0..32) |vector| {
        idt_set_descriptor(vector, isr_stub_table[vector], 0x8e);
        vectors[vector] = true;
    }

    asm volatile (
        \\lidt %[idtr]
        :
        : [idtr] "m" (idtr),
    );
    // asm volatile ("sti");
}
