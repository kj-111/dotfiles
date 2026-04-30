// Neovide-like Ghostty cursor smear.
// Adapted from sahaj-b/ghostty-cursor-shaders cursor_warp.glsl.
// Reference: https://github.com/sahaj-b/ghostty-cursor-shaders
//
// Notes:
// This shader is tuned as a Ghostty approximation of Neovide's cursor feel,
// not as a full reimplementation. Neovide owns the editor surface directly,
// while Ghostty only receives terminal cursor cells. That means some motions,
// such as viewport-only scrolls where Neovim keeps the cursor on the same
// terminal cell, cannot produce a shader animation here.
//
// Intended behavior:
// - normal/block cursor keeps a subtle smear for real jumps and navigation;
// - insert/bar cursor remains visually calm while typing;
// - small horizontal moves, including typing and h/l, are instant/no-smear;
// - larger jumps, including split/window navigation, still animate;
// - block/bar shape changes get a short best-effort morph overlay.
//
// Commit notes:
// - 4bfe918: added the baseline Ghostty cursor smear shader.
// - 55d054c: added early exit when cursor animation is done or hidden.
// - f510840: removed short typing/h-l smear; documented Ghostty limits.
// - fc1b12c: tuned main cursor smear from 150ms to 175ms.
// - c955c3c: added the insert-mode block/bar shape morph overlay.

const float ANIMATION_LENGTH = 0.130;
// Tiny non-zero lead duration: keeps the front edge instant without divide-by-zero.
const float LEAD_DURATION = 0.001;
const float THRESHOLD_MIN_DISTANCE = 0.05;
const float BLUR = 1.0;
const float SHAPE_ANIMATION_LENGTH = 0.05;
const float SHAPE_MIN_DELTA = 0.08;
const float SHAPE_LOCAL_DISTANCE = 1.25;
const float SHAPE_MASK_ALPHA = 0.95;
const float SHAPE_OVERLAY_ALPHA = 1.0;
const float SHAPE_BLUR = 1.0;

float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float ease_shape(float x) {
    return x * x * (3.0 - 2.0 * x);
}

float get_sdf_rectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float all_cond = c0 * c1 * c2;
    float none_cond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, all_cond + none_cond));
    s *= flip;
    return d;
}

float get_sdf_convex_quad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);

    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float is_position) {
    return (value * 2.0 - (iResolution.xy * is_position)) / iResolution.y;
}

float antialiasing(float distance, float blur_amount) {
    return 1.0 - smoothstep(0.0, normalize(vec2(blur_amount, blur_amount), 0.0).x, distance);
}

float get_duration_from_dot(float dot_value, float duration_lead, float duration_side, float duration_trail) {
    float is_lead = step(0.5, dot_value);
    float is_side = step(-0.5, dot_value) * (1.0 - is_lead);

    float duration = mix(duration_trail, duration_side, is_side);
    return mix(duration, duration_lead, is_lead);
}

float is_short_horizontal_move(vec2 move_vec, vec4 current_cursor, float line_length) {
    float cell_width_estimate = max(current_cursor.z, current_cursor.w * 0.5);
    float short_distance = cell_width_estimate * 2.25;
    float same_row = 1.0 - step(current_cursor.w * 0.25, abs(move_vec.y));
    return same_row * (1.0 - step(short_distance, line_length));
}

vec4 apply_shape_morph(vec4 color, vec2 vu, vec4 current_cursor, vec4 previous_cursor, vec2 offset_factor, float elapsed) {
    if (elapsed >= SHAPE_ANIMATION_LENGTH) {
        return color;
    }

    vec2 center_current = current_cursor.xy - (current_cursor.zw * offset_factor);
    vec2 center_previous = previous_cursor.xy - (previous_cursor.zw * offset_factor);
    vec2 size_delta = abs(current_cursor.zw - previous_cursor.zw);
    float cursor_extent = max(max(current_cursor.z, current_cursor.w), max(previous_cursor.z, previous_cursor.w));
    float shape_changed = step(cursor_extent * SHAPE_MIN_DELTA, max(size_delta.x, size_delta.y));
    float local_change = 1.0 - step(cursor_extent * SHAPE_LOCAL_DISTANCE, length(center_current - center_previous));

    if (shape_changed * local_change <= 0.0) {
        return color;
    }

    float progress = ease_shape(clamp(elapsed / SHAPE_ANIMATION_LENGTH, 0.0, 1.0));
    vec4 morph_cursor = mix(previous_cursor, current_cursor, progress);
    vec2 center_morph = morph_cursor.xy - (morph_cursor.zw * offset_factor);

    float sdf_current = get_sdf_rectangle(vu, center_current, current_cursor.zw * 0.5);
    float sdf_morph = get_sdf_rectangle(vu, center_morph, morph_cursor.zw * 0.5);
    float current_alpha = antialiasing(sdf_current, SHAPE_BLUR);
    float morph_alpha = antialiasing(sdf_morph, SHAPE_BLUR);
    float is_expanding = step(previous_cursor.z * previous_cursor.w, current_cursor.z * current_cursor.w);

    color = mix(color, vec4(iBackgroundColor, color.a), current_alpha * (1.0 - morph_alpha) * is_expanding * SHAPE_MASK_ALPHA);

    vec4 cursor_color = mix(iPreviousCursorColor, iCurrentCursorColor, progress);
    color = mix(color, vec4(cursor_color.rgb, color.a), morph_alpha * cursor_color.a * SHAPE_OVERLAY_ALPHA);

    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);

    float elapsed = iTime - iTimeCursorChange;
    if (elapsed >= max(ANIMATION_LENGTH, SHAPE_ANIMATION_LENGTH) || iCursorVisible.x <= 0.0) {
        return;
    }

    vec2 vu = normalize(fragCoord, 1.0);
    vec2 offset_factor = vec2(-0.5, 0.5);

    vec4 current_cursor = vec4(normalize(iCurrentCursor.xy, 1.0), normalize(iCurrentCursor.zw, 0.0));
    vec4 previous_cursor = vec4(normalize(iPreviousCursor.xy, 1.0), normalize(iPreviousCursor.zw, 0.0));

    vec2 center_current = current_cursor.xy - (current_cursor.zw * offset_factor);
    vec2 half_current = current_cursor.zw * 0.5;
    vec2 center_previous = previous_cursor.xy - (previous_cursor.zw * offset_factor);

    vec2 move_vec = center_current - center_previous;
    float line_length = length(move_vec);
    float min_distance = max(current_cursor.z, current_cursor.w) * THRESHOLD_MIN_DISTANCE;
    vec4 new_color = apply_shape_morph(vec4(fragColor), vu, current_cursor, previous_cursor, offset_factor, elapsed);

    if (line_length <= min_distance || is_short_horizontal_move(move_vec, current_cursor, line_length) > 0.5) {
        fragColor = new_color;
        return;
    }

    vec2 current_cursor_delta = abs(vu - center_current) - half_current;
    float is_current_cursor = step(max(current_cursor_delta.x, current_cursor_delta.y), 0.0);

    vec2 cc_tl = current_cursor.xy;
    vec2 cc_tr = current_cursor.xy + vec2(current_cursor.z, 0.0);
    vec2 cc_br = current_cursor.xy + vec2(current_cursor.z, -current_cursor.w);
    vec2 cc_bl = current_cursor.xy - vec2(0.0, current_cursor.w);

    vec2 cp_tl = previous_cursor.xy;
    vec2 cp_tr = previous_cursor.xy + vec2(previous_cursor.z, 0.0);
    vec2 cp_br = previous_cursor.xy + vec2(previous_cursor.z, -previous_cursor.w);
    vec2 cp_bl = previous_cursor.xy - vec2(0.0, previous_cursor.w);

    float duration_side = (LEAD_DURATION + ANIMATION_LENGTH) * 0.5;

    vec2 direction = sign(move_vec);

    float dot_tl = dot(vec2(-1.0, 1.0), direction);
    float dot_tr = dot(vec2(1.0, 1.0), direction);
    float dot_bl = dot(vec2(-1.0, -1.0), direction);
    float dot_br = dot(vec2(1.0, -1.0), direction);

    float dur_tl = get_duration_from_dot(dot_tl, LEAD_DURATION, duration_side, ANIMATION_LENGTH);
    float dur_tr = get_duration_from_dot(dot_tr, LEAD_DURATION, duration_side, ANIMATION_LENGTH);
    float dur_bl = get_duration_from_dot(dot_bl, LEAD_DURATION, duration_side, ANIMATION_LENGTH);
    float dur_br = get_duration_from_dot(dot_br, LEAD_DURATION, duration_side, ANIMATION_LENGTH);

    float is_moving_right = step(0.5, direction.x);
    float is_moving_left = step(0.5, -direction.x);

    float dot_right_edge = (dot_tr + dot_br) * 0.5;
    float dur_right_edge = get_duration_from_dot(dot_right_edge, LEAD_DURATION, duration_side, ANIMATION_LENGTH);

    float dot_left_edge = (dot_tl + dot_bl) * 0.5;
    float dur_left_edge = get_duration_from_dot(dot_left_edge, LEAD_DURATION, duration_side, ANIMATION_LENGTH);

    float final_dur_tl = mix(dur_tl, dur_left_edge, is_moving_left);
    float final_dur_bl = mix(dur_bl, dur_left_edge, is_moving_left);
    float final_dur_tr = mix(dur_tr, dur_right_edge, is_moving_right);
    float final_dur_br = mix(dur_br, dur_right_edge, is_moving_right);

    float prog_tl = ease(clamp(elapsed / final_dur_tl, 0.0, 1.0));
    float prog_tr = ease(clamp(elapsed / final_dur_tr, 0.0, 1.0));
    float prog_bl = ease(clamp(elapsed / final_dur_bl, 0.0, 1.0));
    float prog_br = ease(clamp(elapsed / final_dur_br, 0.0, 1.0));

    vec2 v_tl = mix(cp_tl, cc_tl, prog_tl);
    vec2 v_tr = mix(cp_tr, cc_tr, prog_tr);
    vec2 v_br = mix(cp_br, cc_br, prog_br);
    vec2 v_bl = mix(cp_bl, cc_bl, prog_bl);

    float sdf_trail = get_sdf_convex_quad(vu, v_tl, v_tr, v_br, v_bl);
    float shape_alpha = antialiasing(sdf_trail, BLUR);

    float final_alpha = iCurrentCursorColor.a * shape_alpha;
    new_color = mix(new_color, vec4(iCurrentCursorColor.rgb, new_color.a), final_alpha);
    new_color = mix(new_color, fragColor, is_current_cursor);

    fragColor = new_color;
}
