const std = @import("std");
const rl = @import("raylib");

const planet = struct { id: u32, x: f32, y: f32, vx: f32, vy: f32, mass: f32, color: rl.Color };

pub fn main() !void {
    const width = 1280;
    const height = 720;

    rl.initWindow(width, height, "Planets");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const rand = std.crypto.random;
    var planets = [_]planet{
        planet{
            .id = rand.int(u32),
            .x = width / 2 - 200,
            .y = height / 2,
            .vx = 0,
            .vy = -30,
            .mass = 30,
            .color = rl.Color.red,
        },
        planet{
            .id = rand.int(u32),
            .x = width / 2 + 200,
            .y = height / 2,
            .vx = 0,
            .vy = 30,
            .mass = 20,
            .color = rl.Color.blue,
        },
        planet{
            .id = rand.int(u32),
            .x = width / 2,
            .y = height / 2,
            .vx = 0,
            .vy = 0,
            .mass = 3000,
            .color = rl.Color.green,
        },
    };

    const G: f32 = 200;

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        for (&planets) |*elem| {
            rl.drawCircle(@intFromFloat(elem.x), @intFromFloat(elem.y), 10, elem.color);

            for (planets) |other| {
                if (elem.id == other.id) {
                    continue;
                }

                const dx = other.x - elem.x;
                const dy = other.y - elem.y;
                const dist = std.math.sqrt(dx * dx + dy * dy);

                if (dist == 0) {
                    continue;
                }

                const alpha = std.math.atan2(dy, dx);
                const grav = G * elem.mass * other.mass / (dist * dist);

                elem.x += grav * std.math.cos(alpha) / elem.mass * rl.getFrameTime();
                elem.y += grav * std.math.sin(alpha) / elem.mass * rl.getFrameTime();
            }

            elem.x += elem.vx * rl.getFrameTime();
            elem.y += elem.vy * rl.getFrameTime();
        }
    }
}
