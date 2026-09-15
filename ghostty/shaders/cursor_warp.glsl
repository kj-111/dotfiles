// Cursor trail voor ghostty.
//
// Origineel: cursor_warp.glsl uit sahaj-b/ghostty-cursor-shaders (MIT).
//
// De animatielogica is volledig overgezet uit de broncode van neovide 0.16.2:
// src/renderer/cursor_renderer/mod.rs en src/renderer/animation_utils.rs.
// Daar komen de veerformule, de duren per hoek, de sortering die bepaalt welke
// hoek achterblijft en de regel voor korte sprongen vandaan. Wie deze shader
// ooit vervangt door een nieuwere upstreamversie, moet die twee bestanden er
// weer naast leggen.

const float DURATION = 0.15;
const float SHORT_DURATION = 0.04;
const float TRAIL_SIZE = 1.0;
const float CELL_ASPECT = 20.0 / 39.0;

const vec2 CORNERS[4] = vec2[4](
    vec2(0.0, 0.0), vec2(1.0, 0.0), vec2(1.0, 1.0), vec2(0.0, 1.0)
);

vec2 cellSize() {
    vec2 size = iCurrentCursor.zw;
    if (iCurrentCursorStyle == CURSORSTYLE_BAR) size.x = size.y * CELL_ASPECT;
    if (iCurrentCursorStyle == CURSORSTYLE_UNDERLINE) size.y = size.x / CELL_ASPECT;
    return size;
}

int rankOf(vec4 alignment, int i) {
    int rank = 0;
    for (int j = 0; j < 4; j++) {
        if (alignment[j] < alignment[i] || (alignment[j] == alignment[i] && j < i)) rank++;
    }
    return rank;
}

float durationFromRank(int rank) {
    float leading = DURATION * clamp(1.0 - TRAIL_SIZE, 0.0, 1.0);
    return rank >= 2 ? leading : (rank == 1 ? (leading + DURATION) * 0.5 : DURATION);
}

vec2 springOffset(vec2 delta, float elapsed, float duration) {
    if (duration == 0.0) return vec2(0.0);
    float ot = 4.0 * elapsed / duration;
    vec2 offset = delta * (1.0 + ot) * exp(-ot);
    if (abs(offset.x) < 0.01) offset.x = 0.0;
    if (abs(offset.y) < 0.01) offset.y = 0.0;
    return offset;
}

bool animateCorners(vec2 size, float elapsed, out vec2 vertices[4]) {
    vec2 origin = iCurrentCursor.xy - vec2(0.0, iCurrentCursor.w);
    vec2 previousOrigin = iPreviousCursor.xy - vec2(0.0, iPreviousCursor.w);
    vec2 cellOrigin = iCurrentCursor.xy - vec2(0.0, size.y);
    vec2 delta[4];
    vec4 alignment;
    for (int i = 0; i < 4; i++) {
        vec2 destination = origin + CORNERS[i] * iCurrentCursor.zw;
        vec2 previous = previousOrigin + CORNERS[i] * iPreviousCursor.zw;
        delta[i] = destination - previous;
        vec2 relative = (destination - cellOrigin) / size - 0.5;
        float distance = length(delta[i]);
        alignment[i] = distance > 0.0 ? dot(normalize(relative), delta[i] / distance) : 0.0;
    }

    bool animating = false;
    for (int i = 0; i < 4; i++) {
        vec2 jump = delta[i] / size;
        float duration = durationFromRank(rankOf(alignment, i));
        if (abs(jump.x) <= 2.001 && abs(jump.y) <= 0.001) duration = min(DURATION, SHORT_DURATION);
        vec2 offset = springOffset(delta[i], elapsed, duration);
        vec2 position = origin + CORNERS[i] * iCurrentCursor.zw - offset;
        vertices[i] = sign(position) * floor(abs(position) + 0.5);
        animating = animating || any(notEqual(offset, vec2(0.0)));
    }
    return animating;
}

float getSdfRectangle(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(vec2 p, vec2 a, vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 nearest = a + e * clamp(dot(w, e) / max(dot(e, e), 1e-8), 0.0, 1.0);
    d = min(d, dot(p - nearest, p - nearest));

    if ((a.y > p.y) != (b.y > p.y)) {
        if (p.x < a.x + e.x * w.y / e.y) s = -s;
    }
    return d;
}

float getSdfQuad(vec2 p, vec2 vertices[4]) {
    float s = 1.0;
    float d = dot(p - vertices[0], p - vertices[0]);
    for (int i = 0; i < 4; i++) {
        d = seg(p, vertices[i], vertices[(i + 1) % 4], s, d);
    }
    return s * sqrt(d);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
    if (iFocus == 0 || iCursorVisible == 0) return;
    if (iCurrentCursorStyle != CURSORSTYLE_BLOCK &&
        iCurrentCursorStyle != CURSORSTYLE_BAR &&
        iCurrentCursorStyle != CURSORSTYLE_UNDERLINE) return;
    if (any(lessThanEqual(iPreviousCursor.zw, vec2(0.0)))) return;

    vec2 size = cellSize();
    vec2 jump = (iCurrentCursor.xy - iPreviousCursor.xy) / size;
    if (abs(jump.x) <= 2.001 && abs(jump.y) <= 0.001) return;

    float elapsed = iTime - iTimeCursorChange;
    if (elapsed < 0.0 || iTimeCursorChange < iTimeFocus) return;
    vec2 vertices[4];
    if (!animateCorners(size, elapsed, vertices)) return;

    vec2 center = iCurrentCursor.xy + vec2(iCurrentCursor.z, -iCurrentCursor.w) * 0.5;
    if (getSdfRectangle(fragCoord, center, iCurrentCursor.zw * 0.5) <= 0.0) return;

    float coverage = clamp(0.5 - getSdfQuad(fragCoord, vertices), 0.0, 1.0);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, iCurrentCursorColor.a * coverage);
}
