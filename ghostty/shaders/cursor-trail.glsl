// Neovide-like Ghostty cursor smear.
// Adapted from sahaj-b/ghostty-cursor-shaders cursor_warp.glsl.
// Reference: https://github.com/sahaj-b/ghostty-cursor-shaders

const float ANIMATION_LENGTH = 0.150;
const float SHORT_ANIMATION_LENGTH = 0.040;
const float TRAIL_SIZE = 1.0;
const float THRESHOLD_MIN_DISTANCE = 0.05;
const float BLUR = 1.0;
const float TRAIL_THICKNESS = 1.0;
const float TRAIL_THICKNESS_X = 1.0;
const float FADE_ENABLED = 0.0;
const float FADE_EXPONENT = 5.0;

const float PI = 3.14159265359;

float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
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

float animation_duration(vec2 move_vec, vec4 current_cursor) {
    float line_length = length(move_vec);
    float short_distance = current_cursor.z * 2.25;
    float same_row = 1.0 - step(current_cursor.w * 0.25, abs(move_vec.y));
    float is_short_horizontal = same_row * (1.0 - step(short_distance, line_length));
    return mix(ANIMATION_LENGTH, SHORT_ANIMATION_LENGTH, is_short_horizontal);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);

    float elapsed = iTime - iTimeCursorChange;
    if (elapsed >= ANIMATION_LENGTH || iCursorVisible.x <= 0.0) {
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
    float duration = animation_duration(move_vec, current_cursor);

    if (line_length <= min_distance || elapsed >= duration) {
        return;
    }

    vec4 new_color = vec4(fragColor);
    float sdf_current_cursor = get_sdf_rectangle(vu, center_current, half_current);

    float cc_half_height = current_cursor.w * 0.5;
    float cc_center_y = current_cursor.y - cc_half_height;
    float cc_new_half_height = cc_half_height * TRAIL_THICKNESS;
    float cc_new_top_y = cc_center_y + cc_new_half_height;
    float cc_new_bottom_y = cc_center_y - cc_new_half_height;

    float cc_half_width = current_cursor.z * 0.5;
    float cc_center_x = current_cursor.x + cc_half_width;
    float cc_new_half_width = cc_half_width * TRAIL_THICKNESS_X;
    float cc_new_left_x = cc_center_x - cc_new_half_width;
    float cc_new_right_x = cc_center_x + cc_new_half_width;

    vec2 cc_tl = vec2(cc_new_left_x, cc_new_top_y);
    vec2 cc_tr = vec2(cc_new_right_x, cc_new_top_y);
    vec2 cc_bl = vec2(cc_new_left_x, cc_new_bottom_y);
    vec2 cc_br = vec2(cc_new_right_x, cc_new_bottom_y);

    float cp_half_height = previous_cursor.w * 0.5;
    float cp_center_y = previous_cursor.y - cp_half_height;
    float cp_new_half_height = cp_half_height * TRAIL_THICKNESS;
    float cp_new_top_y = cp_center_y + cp_new_half_height;
    float cp_new_bottom_y = cp_center_y - cp_new_half_height;

    float cp_half_width = previous_cursor.z * 0.5;
    float cp_center_x = previous_cursor.x + cp_half_width;
    float cp_new_half_width = cp_half_width * TRAIL_THICKNESS_X;
    float cp_new_left_x = cp_center_x - cp_new_half_width;
    float cp_new_right_x = cp_center_x + cp_new_half_width;

    vec2 cp_tl = vec2(cp_new_left_x, cp_new_top_y);
    vec2 cp_tr = vec2(cp_new_right_x, cp_new_top_y);
    vec2 cp_bl = vec2(cp_new_left_x, cp_new_bottom_y);
    vec2 cp_br = vec2(cp_new_right_x, cp_new_bottom_y);

    float duration_trail = duration;
    float duration_lead = max(0.001, duration * (1.0 - TRAIL_SIZE));
    float duration_side = (duration_lead + duration_trail) * 0.5;

    vec2 direction = sign(move_vec);

    float dot_tl = dot(vec2(-1.0, 1.0), direction);
    float dot_tr = dot(vec2(1.0, 1.0), direction);
    float dot_bl = dot(vec2(-1.0, -1.0), direction);
    float dot_br = dot(vec2(1.0, -1.0), direction);

    float dur_tl = get_duration_from_dot(dot_tl, duration_lead, duration_side, duration_trail);
    float dur_tr = get_duration_from_dot(dot_tr, duration_lead, duration_side, duration_trail);
    float dur_bl = get_duration_from_dot(dot_bl, duration_lead, duration_side, duration_trail);
    float dur_br = get_duration_from_dot(dot_br, duration_lead, duration_side, duration_trail);

    float is_moving_right = step(0.5, direction.x);
    float is_moving_left = step(0.5, -direction.x);

    float dot_right_edge = (dot_tr + dot_br) * 0.5;
    float dur_right_edge = get_duration_from_dot(dot_right_edge, duration_lead, duration_side, duration_trail);

    float dot_left_edge = (dot_tl + dot_bl) * 0.5;
    float dur_left_edge = get_duration_from_dot(dot_left_edge, duration_lead, duration_side, duration_trail);

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

    vec4 trail = iCurrentCursorColor;
    if (FADE_ENABLED > 0.5) {
        vec2 frag_vec = vu - center_previous;
        float fade_progress = clamp(dot(frag_vec, move_vec) / (dot(move_vec, move_vec) + 0.000001), 0.0, 1.0);
        trail.a *= pow(fade_progress, FADE_EXPONENT);
    }

    float final_alpha = trail.a * shape_alpha;
    new_color = mix(new_color, vec4(trail.rgb, new_color.a), final_alpha);
    new_color = mix(new_color, fragColor, step(sdf_current_cursor, 0.0));

    fragColor = new_color;
}
