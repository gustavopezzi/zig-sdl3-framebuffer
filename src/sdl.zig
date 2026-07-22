const std = @import("std");

const c = @cImport({
  @cInclude("SDL3/SDL.h");
});

pub const Window = struct {
  window: *c.SDL_Window,
  renderer: *c.SDL_Renderer,
  texture: *c.SDL_Texture,

  pub fn init(title: [:0]const u8, width: i32, height: i32) !Window {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
      return error.SDLInitFailed;
    }

    const window = c.SDL_CreateWindow(
      title,
      width,
      height,
      0,
    ) orelse {
      return error.WindowFailed;
    };

    const renderer = c.SDL_CreateRenderer(
      window,
      null,
    ) orelse {
      c.SDL_DestroyWindow(window);
      return error.RendererFailed;
    };

    const texture = c.SDL_CreateTexture(
      renderer,
      c.SDL_PIXELFORMAT_XRGB8888,
      c.SDL_TEXTUREACCESS_STREAMING,
      width,
      height,
    ) orelse {
      c.SDL_DestroyRenderer(renderer);
      c.SDL_DestroyWindow(window);
      return error.TextureFailed;
    };

    return .{
      .window = window,
      .renderer = renderer,
      .texture = texture,
    };
  }

  pub fn deinit(self: *Window) void {
    c.SDL_DestroyTexture(self.texture);
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.SDL_Quit();
  }

  pub fn pollEvents(self: *Window) bool {
    _ = self;
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event)) {
      if (event.type == c.SDL_EVENT_QUIT) {
        return false;
      }
    }

    return true;
  }

  pub fn present(self: *Window, pixels: []u32, width: usize) !void {
    if (!c.SDL_UpdateTexture(
      self.texture,
      null,
      pixels.ptr,
      @intCast(width * @sizeOf(u32)),
    )) {
      return error.TextureUpdateFailed;
    }

    _ = c.SDL_RenderClear(self.renderer);

    if (!c.SDL_RenderTexture(
      self.renderer,
      self.texture,
      null,
      null,
    )) {
      return error.RenderFailed;
    }
    _ = c.SDL_RenderPresent(self.renderer);
  }
};

pub fn getPerformanceCounter() u64 {
  return c.SDL_GetPerformanceCounter();
}

pub fn getPerformanceFrequency() u64 {
  return c.SDL_GetPerformanceFrequency();
}

pub fn delay(milliseconds: u32) void {
  c.SDL_Delay(milliseconds);
}