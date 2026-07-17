//! Shared session preferences after Setup.

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum Look {
    Light,
    Dark,
    Night,
}

pub const REGIONS: &[&str] = &[
    "United States",
    "United Kingdom",
    "Canada",
    "Australia",
    "Germany",
    "France",
    "Japan",
];

pub const LOOKS: &[(Look, &str)] = &[
    (Look::Light, "Light"),
    (Look::Dark, "Dark"),
    (Look::Night, "Night"),
];

pub struct Session {
    pub region_idx: usize,
    pub look_idx: usize,
    pub look: Look,
    pub name: [u8; 24],
    pub name_len: usize,
}

impl Session {
    pub fn new() -> Self {
        Self {
            region_idx: 0,
            look_idx: 1,
            look: Look::Dark,
            name: [0; 24],
            name_len: 0,
        }
    }

    pub fn name_str(&self) -> &str {
        core::str::from_utf8(&self.name[..self.name_len]).unwrap_or("Aero")
    }

    pub fn display_name(&self) -> &str {
        if self.name_len == 0 {
            "Aero"
        } else {
            self.name_str()
        }
    }

    pub fn region_name(&self) -> &str {
        REGIONS.get(self.region_idx).copied().unwrap_or("Unknown")
    }

    pub fn look_name(&self) -> &str {
        LOOKS.get(self.look_idx).map(|l| l.1).unwrap_or("Dark")
    }
}
