const std = @import("std");
const rl = @import("raylib");

const planet = struct {
    id: i64,
    pos: struct { x: f64, y: f64 },
    vel: struct { x: f64, y: f64 },
    acc: struct { x: f64, y: f64 },
    size: f32,
    mass: f64,
    color: rl.Color,
};

pub fn main() !void {
    const width = 1280;
    const height = 1280;

    rl.initWindow(width, height, "Planets");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const rand = std.crypto.random;
    var planets: [2000]planet = undefined;

    const MAX_MASS: f64 = 3000;
    const MIN_MASS: f64 = 3000;

    const MAX_DIST: f64 = 1000;
    const MIN_DIST: f64 = 100;

    const MAX_VEL: f32 = 45;
    const MIN_VEL: f32 = 45;

    for (0.., &planets) |idx, *elem| {
        elem.id = @intCast(idx);

        elem.mass = MIN_MASS + ((MAX_MASS - MIN_MASS) * rand.float(f64));

        elem.size = 5;

        elem.color = rl.Color.white;

        const dist = MIN_DIST + ((MAX_DIST - MIN_DIST) * rand.floatNorm(f64));
        const alpha = rand.float(f64) * 2 * std.math.pi;
        elem.pos = .{
            .x = width / 2 + dist * std.math.sin(alpha),
            .y = height / 2 + dist * std.math.cos(alpha),
        };

        const vel = MIN_VEL + ((MAX_VEL - MIN_VEL) * rand.float(f64));
        const beta = alpha + std.math.pi / 2.0;
        elem.vel = .{
            .x = vel * std.math.sin(beta) * (dist / MAX_DIST),
            .y = vel * std.math.cos(beta) * (dist / MAX_DIST),
        };
    }

    var camera = rl.Camera2D{
        .target = .{ .x = width / 2.0, .y = height / 2.0 },
        .offset = .{ .x = width / 2.0, .y = height / 2.0 },
        .rotation = 0.0,
        .zoom = 1.0,
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        camera.zoom += rl.getMouseWheelMove() * 0.05;

        rl.clearBackground(rl.Color.black);

        {
            rl.beginMode2D(camera);
            defer rl.endMode2D();

            // draw all the planets
            for (&planets) |*elem| {
                rl.drawCircle(
                    @intFromFloat(elem.pos.x),
                    @intFromFloat(elem.pos.y),
                    elem.size,
                    elem.color,
                );
            }
        }
        // update vel vectors
        const dt = rl.getFrameTime();
        for (0..planets.len) |i| {
            var elem = &planets[i];
            for (i + 1..planets.len) |j| {
                var other = &planets[j];

                const dx = elem.pos.x - other.pos.x;
                const dy = elem.pos.y - other.pos.y;

                const mag_sq = dx * dx + dy * dy;
                const mag = std.math.sqrt(mag_sq);

                const clamp_mag = @max(mag, elem.size + other.size);
                const mag_c = clamp_mag * clamp_mag * clamp_mag;

                const acc_x = dx / mag_c;
                const acc_y = dy / mag_c;

                elem.acc.x -= acc_x * other.mass;
                elem.acc.y -= acc_y * other.mass;

                other.acc.x += acc_x * elem.mass;
                other.acc.y += acc_y * elem.mass;

                if (elem.size + other.size >= mag) {
                    const unit_rx = dx / mag;
                    const unit_ry = dy / mag;

                    const edot = elem.mass * elem.acc.x * -unit_rx + elem.mass * elem.acc.y * -unit_ry;
                    const odot = other.mass * other.acc.x * unit_rx + other.mass * other.acc.y * unit_ry;

                    const ex = -edot * unit_rx / elem.mass;
                    const ey = -edot * unit_ry / elem.mass;

                    const ox = odot * unit_rx / other.mass;
                    const oy = odot * unit_ry / other.mass;

                    elem.acc.x += ox - ex;
                    elem.acc.y += oy - ey;

                    other.acc.x += ex - ox;
                    other.acc.y += ey - oy;
                }
            }
        }

        for (&planets) |*elem| {
            elem.vel.x += elem.acc.x * dt;
            elem.vel.y += elem.acc.y * dt;

            elem.pos.x += elem.vel.x * dt;
            elem.pos.y += elem.vel.y * dt;

            elem.acc.x = 0;
            elem.acc.y = 0;
        }
    }
}
