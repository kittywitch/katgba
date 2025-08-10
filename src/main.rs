#![no_std]
#![no_main]

use core::{error::Error, num::{NonZero, NonZeroI32}, ptr};

use gba::prelude::*;

const SCREEN_WIDTH: u16 = 240;
const SCREEN_HEIGHT: u16 = 160;

#[panic_handler]
fn panic_handler(_: &core::panic::PanicInfo) -> ! {
    loop {}
}

#[derive(Copy,Clone,PartialEq, Eq)]
struct Position(u16, u16);

#[derive(Copy,Clone,PartialEq, Eq)]
struct Dimensions(u16, u16);

#[derive(Copy,Clone,PartialEq,Eq)]
struct Render {
    position: Position,
    dimensions: Dimensions,
    color: Color,
}

impl Render {
    fn draw(&self) {
        draw_rect(self.position.0, self.position.1, self.dimensions.0, self.dimensions.1, self.color);
    }
}

#[derive(Copy,Clone,PartialEq,Eq)]
struct Player(Render);
impl Player {
    fn spawn() -> Player {
        Self(Render {
            position: Position(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2),
            dimensions: Dimensions(24, 24),
            color: Color::WHITE,
        })
    }
    fn update(&mut self) {
        
    }
    fn draw(&self) {
        self.0.draw();
    }
}

#[derive(Copy,Clone,PartialEq,Eq)]
enum Entity {
    Player(Player),
}

#[derive(Copy,Clone)]
struct Engine {
    player: Option<Player>,
}



static mut ENGINE: Engine = Engine {
    player: None,
};


impl Engine {
    fn start(mut self) {
        self.player = Some(Player::spawn());
    }

    fn update(mut self) {
        if let Some(player) = &mut self.player {
            player.update();
        }
    }

    fn draw(self) {
        if let Some(player) = self.player {
            player.draw();
            video3_clear_to(Color::WHITE);
        }
    }
}


#[unsafe(no_mangle)]
fn main() -> ! {
    DISPCNT.write(
        DisplayControl::new().with_video_mode(VideoMode::_3).with_show_bg2(true),
    );

    RUST_IRQ_HANDLER.write(Some(draw_sprites));
    DISPSTAT.write(DisplayStatus::new().with_irq_vblank(true));
    IE.write(IrqBits::VBLANK);
    IME.write(true);

    unsafe { ENGINE.start(); };


    loop {
        unsafe { ENGINE.update(); };
        VBlankIntrWait();
    }
}

#[unsafe(link_section = ".iwram.draw_sprites")]
extern "C" fn draw_sprites(_bits: IrqBits) {
    video3_clear_to(Color::BLACK);

    unsafe { ENGINE.draw(); };
}


#[unsafe(link_section = ".iwram.draw_rect")]
fn draw_rect(x: u16, y: u16, width: u16, height: u16, color: Color) {
  for i in 0..width {
    for j in 0..height {
      VIDEO3_VRAM.index((x + i) as usize, (y + j) as usize).write(color);
    }
  }
}
