const InterruptDescriptorTable = packed struct {};

const IDTEntry = packed struct { ptr_low: u16, gdt_selector: u16, zero: u8, flags: u8, ptr_high: u16 };
const IDTRegister = packed struct { limit: u16, base: *[256]IDTEntry };

var idt_table: [256]IDTEntry = undefined;
const idtr = IDTRegister{ .limit = @sizeOf(idt_table), .base = &idt_table };

// const EntryOptions = packed struct {
// self: u16,

// inline fn minimal() @This() {
// return .{ .self = 0b1110_0000_0000 };
// }
// };
