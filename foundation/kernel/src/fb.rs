//! Framebuffer helpers over UEFI GOP (software alpha blit).

use uefi::proto::console::gop::PixelFormat;
use noto_sans_mono_bitmap::{get_raster, get_raster_width, FontWeight, RasterHeight};

#[derive(Clone, Copy)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Color {
    pub const fn rgb(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b, a: 255 }
    }
    pub const fn rgba(r: u8, g: u8, b: u8, a: u8) -> Self {
        Self { r, g, b, a }
    }
}

pub struct Frame {
    ptr: *mut u8,
    len: usize,
    width: usize,
    height: usize,
    stride: usize,
    format: PixelFormat,
}

impl Frame {
    /// # Safety
    /// `ptr` must point to a live GOP framebuffer of `len` bytes for the rest of the process.
    pub unsafe fn from_raw(
        ptr: *mut u8,
        len: usize,
        width: usize,
        height: usize,
        stride: usize,
        format: PixelFormat,
    ) -> Self {
        Self {
            ptr,
            len,
            width,
            height,
            stride,
            format,
        }
    }

    pub fn width(&self) -> usize {
        self.width
    }
    pub fn height(&self) -> usize {
        self.height
    }

    pub fn clear(&mut self, c: Color) {
        for y in 0..self.height {
            for x in 0..self.width {
                self.put_pixel(x, y, c);
            }
        }
    }

    fn bytes_per_pixel(&self) -> usize {
        match self.format {
            PixelFormat::Rgb | PixelFormat::Bgr => 4,
            PixelFormat::Bitmask | PixelFormat::BltOnly => 4,
        }
    }

    unsafe fn pixel_ptr(&self, x: usize, y: usize) -> *mut u8 {
        let bpp = self.bytes_per_pixel();
        self.ptr.add((y * self.stride + x) * bpp)
    }

    pub fn put_pixel(&mut self, x: usize, y: usize, c: Color) {
        if x >= self.width || y >= self.height {
            return;
        }
        let bpp = self.bytes_per_pixel();
        let off = (y * self.stride + x) * bpp;
        if off + bpp > self.len {
            return;
        }
        unsafe {
            let p = self.pixel_ptr(x, y);
            match self.format {
                PixelFormat::Rgb => {
                    *p = c.r;
                    *p.add(1) = c.g;
                    *p.add(2) = c.b;
                    if bpp > 3 {
                        *p.add(3) = 0;
                    }
                }
                PixelFormat::Bgr => {
                    *p = c.b;
                    *p.add(1) = c.g;
                    *p.add(2) = c.r;
                    if bpp > 3 {
                        *p.add(3) = 0;
                    }
                }
                _ => {
                    *p = c.b;
                    *p.add(1) = c.g;
                    *p.add(2) = c.r;
                }
            }
        }
    }

    pub fn get_pixel(&self, x: usize, y: usize) -> Color {
        if x >= self.width || y >= self.height {
            return Color::rgb(0, 0, 0);
        }
        unsafe {
            let p = self.pixel_ptr(x, y);
            match self.format {
                PixelFormat::Rgb => Color::rgb(*p, *p.add(1), *p.add(2)),
                PixelFormat::Bgr => Color::rgb(*p.add(2), *p.add(1), *p),
                _ => Color::rgb(*p.add(2), *p.add(1), *p),
            }
        }
    }

    pub fn blend_pixel(&mut self, x: usize, y: usize, c: Color) {
        if c.a == 255 {
            self.put_pixel(x, y, c);
            return;
        }
        if c.a == 0 {
            return;
        }
        let dst = self.get_pixel(x, y);
        let a = c.a as u16;
        let inv = 255 - a;
        self.put_pixel(
            x,
            y,
            Color::rgb(
                ((c.r as u16 * a + dst.r as u16 * inv) / 255) as u8,
                ((c.g as u16 * a + dst.g as u16 * inv) / 255) as u8,
                ((c.b as u16 * a + dst.b as u16 * inv) / 255) as u8,
            ),
        );
    }

    pub fn fill_round_rect(
        &mut self,
        x: usize,
        y: usize,
        w: usize,
        h: usize,
        radius: usize,
        c: Color,
    ) {
        let r2 = radius * radius;
        for yy in y..y.saturating_add(h).min(self.height) {
            for xx in x..x.saturating_add(w).min(self.width) {
                let lx = xx.saturating_sub(x);
                let ly = yy.saturating_sub(y);
                let in_h = lx >= radius && lx < w.saturating_sub(radius);
                let in_v = ly >= radius && ly < h.saturating_sub(radius);
                let corner = if lx < radius && ly < radius {
                    let dx = radius - lx;
                    let dy = radius - ly;
                    dx * dx + dy * dy <= r2
                } else if lx >= w.saturating_sub(radius) && ly < radius {
                    let dx = lx - (w - radius);
                    let dy = radius - ly;
                    dx * dx + dy * dy <= r2
                } else if lx < radius && ly >= h.saturating_sub(radius) {
                    let dx = radius - lx;
                    let dy = ly - (h - radius);
                    dx * dx + dy * dy <= r2
                } else if lx >= w.saturating_sub(radius) && ly >= h.saturating_sub(radius) {
                    let dx = lx - (w - radius);
                    let dy = ly - (h - radius);
                    dx * dx + dy * dy <= r2
                } else {
                    true
                };
                if in_h || in_v || corner {
                    self.blend_pixel(xx, yy, c);
                }
            }
        }
    }

    /// Frosted glass: average nearby pixels, then tint.
    pub fn fill_glass_round_rect(
        &mut self,
        x: usize,
        y: usize,
        w: usize,
        h: usize,
        radius: usize,
        tint: Color,
    ) {
        let r2 = radius * radius;
        let samples: [(isize, isize); 5] = [(0, 0), (-5, 0), (5, 0), (0, -5), (0, 5)];
        for yy in y..y.saturating_add(h).min(self.height) {
            for xx in x..x.saturating_add(w).min(self.width) {
                let lx = xx.saturating_sub(x);
                let ly = yy.saturating_sub(y);
                let in_h = lx >= radius && lx < w.saturating_sub(radius);
                let in_v = ly >= radius && ly < h.saturating_sub(radius);
                let corner = if radius == 0 {
                    true
                } else if lx < radius && ly < radius {
                    let dx = radius - lx;
                    let dy = radius - ly;
                    dx * dx + dy * dy <= r2
                } else if lx >= w.saturating_sub(radius) && ly < radius {
                    let dx = lx - (w - radius);
                    let dy = radius - ly;
                    dx * dx + dy * dy <= r2
                } else if lx < radius && ly >= h.saturating_sub(radius) {
                    let dx = radius - lx;
                    let dy = ly - (h - radius);
                    dx * dx + dy * dy <= r2
                } else if lx >= w.saturating_sub(radius) && ly >= h.saturating_sub(radius) {
                    let dx = lx - (w - radius);
                    let dy = ly - (h - radius);
                    dx * dx + dy * dy <= r2
                } else {
                    true
                };
                if !(in_h || in_v || corner) {
                    continue;
                }

                let mut sr = 0u32;
                let mut sg = 0u32;
                let mut sb = 0u32;
                let mut n = 0u32;
                for (dx, dy) in samples {
                    let sx = (xx as isize + dx).clamp(0, self.width as isize - 1) as usize;
                    let sy = (yy as isize + dy).clamp(0, self.height as isize - 1) as usize;
                    let p = self.get_pixel(sx, sy);
                    sr += p.r as u32;
                    sg += p.g as u32;
                    sb += p.b as u32;
                    n += 1;
                }
                let fr = (sr / n) as u8;
                let fg = (sg / n) as u8;
                let fb = (sb / n) as u8;
                let a = tint.a as u16;
                let inv = 255 - a;
                self.put_pixel(
                    xx,
                    yy,
                    Color::rgb(
                        ((tint.r as u16 * a + fr as u16 * inv) / 255) as u8,
                        ((tint.g as u16 * a + fg as u16 * inv) / 255) as u8,
                        ((tint.b as u16 * a + fb as u16 * inv) / 255) as u8,
                    ),
                );
            }
        }
    }

    pub fn draw_text(&mut self, mut x: usize, y: usize, text: &str, c: Color) {
        for ch in text.chars() {
            let width = get_raster_width(FontWeight::Regular, RasterHeight::Size16);
            if let Some(raster) = get_raster(ch, FontWeight::Regular, RasterHeight::Size16) {
                for (row_i, row) in raster.raster().iter().enumerate() {
                    for (col_i, pixel) in row.iter().enumerate() {
                        if *pixel > 0 {
                            let col = Color::rgba(
                                c.r,
                                c.g,
                                c.b,
                                ((c.a as u16 * *pixel as u16) / 255) as u8,
                            );
                            self.blend_pixel(x + col_i, y + row_i, col);
                        }
                    }
                }
            }
            x += width;
        }
    }

    pub fn blit_cover(&mut self, img: &crate::brand::RgbaImage) {
        let dw = self.width.max(1);
        let dh = self.height.max(1);
        let sw = img.width.max(1);
        let sh = img.height.max(1);
        for y in 0..dh {
            let sy = y * sh / dh;
            for x in 0..dw {
                let sx = x * sw / dw;
                let i = (sy * sw + sx) * 4;
                if i + 3 >= img.pixels.len() {
                    continue;
                }
                self.put_pixel(
                    x,
                    y,
                    Color::rgb(img.pixels[i], img.pixels[i + 1], img.pixels[i + 2]),
                );
            }
        }
    }

    /// Fit image inside the framebuffer (letterbox), preserving aspect ratio.
    pub fn blit_contain(&mut self, img: &crate::brand::RgbaImage) {
        let dw = self.width.max(1);
        let dh = self.height.max(1);
        let sw = img.width.max(1);
        let sh = img.height.max(1);
        let scale_num = (dw * sh).min(dh * sw);
        let out_w = (sw * scale_num) / (sw * sh).max(1);
        let out_h = (sh * scale_num) / (sw * sh).max(1);
        let out_w = out_w.max(1).min(dw);
        let out_h = out_h.max(1).min(dh);
        let ox = dw.saturating_sub(out_w) / 2;
        let oy = dh.saturating_sub(out_h) / 2;
        for y in 0..out_h {
            let sy = y * sh / out_h;
            for x in 0..out_w {
                let sx = x * sw / out_w;
                let i = (sy * sw + sx) * 4;
                if i + 3 >= img.pixels.len() {
                    continue;
                }
                self.put_pixel(
                    ox + x,
                    oy + y,
                    Color::rgb(img.pixels[i], img.pixels[i + 1], img.pixels[i + 2]),
                );
            }
        }
    }

    pub fn blit_rgba(&mut self, img: &crate::brand::RgbaImage, dx: usize, dy: usize) {
        self.blit_rgba_scaled(img, dx, dy, img.width, img.height);
    }

    pub fn blit_rgba_scaled(
        &mut self,
        img: &crate::brand::RgbaImage,
        dx: usize,
        dy: usize,
        dw: usize,
        dh: usize,
    ) {
        if dw == 0 || dh == 0 || img.width == 0 || img.height == 0 {
            return;
        }
        for y in 0..dh {
            let sy = y * img.height / dh;
            for x in 0..dw {
                let sx = x * img.width / dw;
                let i = (sy * img.width + sx) * 4;
                if i + 3 >= img.pixels.len() {
                    continue;
                }
                let a = img.pixels[i + 3];
                if a == 0 {
                    continue;
                }
                self.blend_pixel(
                    dx + x,
                    dy + y,
                    Color::rgba(img.pixels[i], img.pixels[i + 1], img.pixels[i + 2], a),
                );
            }
        }
    }

    pub fn draw_wallpaper_fallback(&mut self) {
        let w = self.width.max(1);
        let h = self.height.max(1);
        for y in 0..h {
            for x in 0..w {
                let ty = (y * 255) / h;
                let tx = (x * 255) / w;
                let r = (8 + tx / 12 + (255 - ty) / 20) as u8;
                let g = (18 + (255 - ty) / 6 + tx / 16) as u8;
                let b = (36 + (255 - ty) / 3 + tx / 10) as u8;
                self.put_pixel(x, y, Color::rgb(r, g, b));
            }
        }
    }
}
