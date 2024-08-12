const std = @import("std");
const rl = @import("raylib");

const planet = struct {
    id: i64,
    pos: struct { x: f32, y: f32 },
    vel: struct { x: f32, y: f32 },
    size: f32,
    mass: f32,
    color: rl.Color,
};

pub fn main() !void {
    const width = 1280;
    const height = 720;

    rl.initWindow(width, height, "Planets");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var planets = [_]planet{
        .{
            .id = 0,
            .pos = .{ .x = width / 2, .y = height / 2 },
            .vel = .{ .x = 0, .y = 0 },
            .mass = 300,
            .size = 10,
            .color = rl.Color.purple,
        },
        .{
            .id = 1,
            .pos = .{
                .x = width / 2 - 150,
                .y = height / 2,
            },
            .vel = .{ .x = 0, .y = -50 },
            .mass = 30,
            .size = 10,
            .color = rl.Color.red,
        },
        .{
            .id = 2,
            .pos = .{
                .x = width / 2,
                .y = height / 2 + 150,
            },
            .vel = .{ .x = -50, .y = 0 },
            .mass = 30,
            .size = 10,
            .color = rl.Color.blue,
        },
    };

    const G: f32 = 1000;

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        // draw all the planets
        for (&planets) |*elem| {
            rl.drawCircle(
                @intFromFloat(elem.pos.x),
                @intFromFloat(elem.pos.y),
                elem.size,
                elem.color,
            );
        }

        // update vel vectors
        const dt = rl.getFrameTime();
        for (&planets) |*elem| {
            for (&planets) |*other| {
                if (elem.id == other.id) {
                    continue;
                }

                const dy = other.pos.y - elem.pos.y;
                const dx = other.pos.x - elem.pos.x;
                const dist = std.math.sqrt(dx * dx + dy * dy);

                const alpha = std.math.atan2(dy, dx);
                const grav = G * elem.mass * other.mass / (dist * dist);
                const accel = grav / elem.mass;

                elem.vel.x += accel * std.math.cos(alpha) * dt;
                elem.vel.y += accel * std.math.sin(alpha) * dt;
            }
        }

        for (&planets) |*elem| {
            elem.pos.x += elem.vel.x * dt;
            elem.pos.y += elem.vel.y * dt;
        }
    }
}
