const std = @import("std");

const c = @cImport({
  @cInclude("SDL3/SDL.h");
});

const WIDTH = 640;
const HEIGHT = 480;

var framebuffer: [WIDTH * HEIGHT]u32 = undefined;

fn putPixel(x: i32, y: i32, color: u32) void {
  if (x < 0 or x >= WIDTH or y < 0 or y >= HEIGHT) {
    return;
  }
  framebuffer[@intCast(y * WIDTH + x)] = color;
}

fn clear(color: u32) void {
  for (&framebuffer) |*pixel| {
    pixel.* = color;
  }
}

fn rgb(r: u8, g: u8, b: u8) u32 {
  return (@as(u32, r) << 16) | (@as(u32, g) << 8) | @as(u32, b);
}

pub fn main() !void {
  if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
    std.debug.print(
      "SDL_Init failed: {s}\n",
      .{c.SDL_GetError()},
    );
    return;
  }

  defer c.SDL_Quit();

  const window = c.SDL_CreateWindow(
    "Zig SDL3 Framebuffer",
    WIDTH,
    HEIGHT,
    0,
  ) orelse {
    std.debug.print(
      "SDL_CreateWindow failed: {s}\n",
      .{c.SDL_GetError()},
    );
    return;
  };

  defer c.SDL_DestroyWindow(window);

  const renderer = c.SDL_CreateRenderer(
    window,
    null,
  ) orelse {
    std.debug.print(
      "SDL_CreateRenderer failed: {s}\n",
      .{c.SDL_GetError()},
    );
    return;
  };

  defer c.SDL_DestroyRenderer(renderer);

  const texture = c.SDL_CreateTexture(
    renderer,
    c.SDL_PIXELFORMAT_XRGB8888,
    c.SDL_TEXTUREACCESS_STREAMING,
    WIDTH,
    HEIGHT,
  ) orelse {
    std.debug.print(
      "SDL_CreateTexture failed: {s}\n",
      .{c.SDL_GetError()},
    );
    return;
  };

  defer c.SDL_DestroyTexture(texture);

  var running = true;
  var frame: u32 = 0;

  const target_frame_time: f64 = 1.0 / 60.0;

  while (running) {
    const start = c.SDL_GetPerformanceCounter();

    var event: c.SDL_Event = undefined;

    while (c.SDL_PollEvent(&event)) {
      if (event.type == c.SDL_EVENT_QUIT) {
        running = false;
      }
    }

    clear(0x000000);
    
    var y: i32 = 0;
    while (y < HEIGHT) : (y += 1) {
      var x: i32 = 0;

      while (x < WIDTH) : (x += 1) {
        const r: u8 = @intCast((x + @as(i32, @intCast(frame))) & 255);
        const g: u8 = @intCast((y + @as(i32, @intCast(frame))) & 255);
        const b: u8 = @intCast((x + y + @as(i32, @intCast(frame))) & 255);

        putPixel(x, y, rgb(r, g, b));
      }
    }
    
    frame += 1;

    _ = c.SDL_UpdateTexture(
      texture,
      null,
      &framebuffer,
      WIDTH * @sizeOf(u32),
    );

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderTexture(renderer, texture, null, null);
    _ = c.SDL_RenderPresent(renderer);

    const end = c.SDL_GetPerformanceCounter();
    const elapsed = @as(f64, @floatFromInt(end - start)) / @as(f64, @floatFromInt(c.SDL_GetPerformanceFrequency()));

    if (elapsed < target_frame_time) {
      const delay_ms = @as(u32, @intFromFloat((target_frame_time - elapsed) * 1000.0));
      c.SDL_Delay(delay_ms);
    }
  }
}
