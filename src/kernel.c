/*
 * daley_os kernel entry point. Freestanding C — no libc. For now it brings up a
 * VGA text terminal and prints a banner; everything else is roadmap (see
 * docs/ARCHITECTURE.md).
 */
#include <stddef.h>
#include <stdint.h>

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
static uint16_t *const VGA_BUFFER = (uint16_t *)0xB8000;

enum vga_color {
    COLOR_BLACK = 0,
    COLOR_GREEN = 2,
    COLOR_CYAN = 3,
    COLOR_RED = 4,
    COLOR_LIGHT_GREY = 7,
    COLOR_YELLOW = 14,
    COLOR_WHITE = 15,
};

static inline uint8_t vga_color(enum vga_color fg, enum vga_color bg) {
    return (uint8_t)fg | (uint8_t)(bg << 4);
}

static inline uint16_t vga_entry(unsigned char ch, uint8_t color) {
    return (uint16_t)ch | (uint16_t)(color << 8);
}

static size_t term_row;
static size_t term_col;
static uint8_t term_color;

static size_t kstrlen(const char *s) {
    size_t n = 0;
    while (s[n]) n++;
    return n;
}

static void term_init(void) {
    term_row = 0;
    term_col = 0;
    term_color = vga_color(COLOR_LIGHT_GREY, COLOR_BLACK);
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            VGA_BUFFER[y * VGA_WIDTH + x] = vga_entry(' ', term_color);
        }
    }
}

static void term_setcolor(uint8_t color) { term_color = color; }

static void term_newline(void) {
    term_col = 0;
    if (++term_row == VGA_HEIGHT) term_row = 0;  // TODO: scroll instead of wrap
}

static void term_putchar(char c) {
    if (c == '\n') {
        term_newline();
        return;
    }
    VGA_BUFFER[term_row * VGA_WIDTH + term_col] = vga_entry((unsigned char)c, term_color);
    if (++term_col == VGA_WIDTH) term_newline();
}

static void term_write(const char *s) {
    for (size_t i = 0; i < kstrlen(s); i++) term_putchar(s[i]);
}

void kernel_main(void) {
    term_init();

    term_setcolor(vga_color(COLOR_GREEN, COLOR_BLACK));
    term_write("daley_os\n");
    term_setcolor(vga_color(COLOR_LIGHT_GREY, COLOR_BLACK));
    term_write("a from-scratch, security-first OS for AI workloads\n\n");

    term_write("[ok] multiboot kernel loaded at 1 MiB\n");
    term_write("[ok] VGA text terminal online\n");
    term_setcolor(vga_color(COLOR_YELLOW, COLOR_BLACK));
    term_write("[..] next: GDT, IDT, paging, physical memory manager\n");
}
