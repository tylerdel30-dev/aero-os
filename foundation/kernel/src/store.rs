//! Built-in Aero Store catalog (mirrors store/index.json for the UEFI desktop).

#[derive(Clone, Copy)]
pub struct StoreApp {
    pub id: &'static str,
    pub name: &'static str,
    pub category: &'static str,
    pub description: &'static str,
    /// Builtin action: 0=hello, 1=about, 2=control, 3=setup
    pub action: u8,
}

pub const APPS: &[StoreApp] = &[
    StoreApp {
        id: "dev.aero.hello",
        name: "Hello Aero",
        category: "Utilities",
        description: "Example .aero app bundle",
        action: 0,
    },
    StoreApp {
        id: "dev.aero.about",
        name: "About Aero",
        category: "System",
        description: "System about panel",
        action: 1,
    },
    StoreApp {
        id: "dev.aero.control",
        name: "Control Center",
        category: "System",
        description: "Quick look controls",
        action: 2,
    },
    StoreApp {
        id: "dev.aero.setup",
        name: "Setup",
        category: "System",
        description: "Run Setup again",
        action: 3,
    },
];
