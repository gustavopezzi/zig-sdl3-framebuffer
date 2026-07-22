const std = @import("std");

const SDL = @import("sdl.zig");
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const rgb = @import("framebuffer.zig").rgb;

const WIDTH = 640;
const HEIGHT = 480;

pub fn main() !void {
  var pixels: [WIDTH * HEIGHT]u32 = undefined;

  var fb = Framebuffer.init(pixels[0..], WIDTH, HEIGHT);

  var window = try SDL.Window.init("Zig Framebuffer", WIDTH, HEIGHT);

  defer window.deinit();

  var frame: u32 = 0;

  const target_frame_time: f64 = 1.0 / 60.0;

  while (window.pollEvents()) {
    const start = SDL.getPerformanceCounter();

    fb.clear(0x202040);

    var y: i32 = 0;

    while (y < HEIGHT) : (y += 1) {
      var x: i32 = 0;

      while (x < WIDTH) : (x += 1) {
        const f: i32 = @intCast(frame);

        const r: u8 = @intCast((x + f) & 255);
        const g: u8 = @intCast((y + f) & 255);
        const b: u8 = @intCast((x + y + f) & 255);

        fb.putPixel(x, y, rgb(r, g, b));
      }
    }

    try window.present(fb.pixels, WIDTH);

    frame += 1;

    const end = SDL.getPerformanceCounter();
    const elapsed = @as(f64, @floatFromInt(end - start)) / @as(f64, @floatFromInt(SDL.getPerformanceFrequency()));

    if (elapsed < target_frame_time) {
      const seconds = target_frame_time - elapsed;
      const milliseconds: u32 = @intFromFloat(seconds * 1000.0);
      if (milliseconds > 0) {
        SDL.delay(milliseconds);
      }
    }
  }

  _ = std;
}