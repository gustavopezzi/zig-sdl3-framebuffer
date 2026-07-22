const std = @import("std");

pub const Framebuffer = struct {
  width: usize,
  height: usize,
  pixels: []u32,

  pub fn init(
    pixels: []u32,
    width: usize,
    height: usize,
  ) Framebuffer {
    return .{
      .pixels = pixels,
      .width = width,
      .height = height,
    };
  }

  pub fn clear(self: *Framebuffer, color: u32) void {
    @memset(self.pixels, color);
  }

  pub fn putPixel(
    self: *Framebuffer,
    x: i32,
    y: i32,
    color: u32,
  ) void {
    if (x < 0 or y < 0) {
      return;
    }
    if (x >= self.width or y >= self.height) {
      return;
    }
    self.pixels[@intCast(@as(usize, @intCast(y)) * self.width + @as(usize, @intCast(x)))] = color;
  }
};

pub fn rgb(
  r: u8,
  g: u8,
  b: u8,
) u32 {
  return (@as(u32, r) << 16) | (@as(u32, g) << 8) | @as(u32, b);
}