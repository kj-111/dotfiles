// Cursor trail voor ghostty, met de animatielogica van neovide.
//
// Origineel: cursor_warp.glsl uit sahaj-b/ghostty-cursor-shaders (MIT).
// Hier is elke waarde en elke beslissing nagelopen tegen neovide 0.16.2 als
// enige bron van waarheid: src/renderer/cursor_renderer/mod.rs en
// src/renderer/animation_utils.rs. Waar de shader afweek van neovide is de
// shader aangepast, ook als het origineel op zichzelf verdedigbaar was. De
// afwijkingen staan per plek in commentaar, met regelverwijzing.
//
// Wat principieel niet over te zetten is: neovide bewaart de snelheid van de
// veer tussen sprongen, waardoor ingedrukte j/k gaat golven. Ghostty geeft een
// shader geen toestand tussen frames, dus elke sprong start hier vanuit
// stilstand. En neovide tekent één pad door de vier hoeken dat zelf de cursor
// ís, terwijl ghostty de cursor al verplaatst heeft en dit er een vorm achter
// tekent — vandaar het gat dat onderaan uit de trail wordt geponst.
//
// Geen sRGB->lineair conversie: die zat in het origineel, maar geldt alleen bij
// alpha-blending = linear. Op de default `native` kiest ghostty het
// pixelformaat bgra8unorm en niet bgra8unorm_srgb (Metal.zig:204-212), dus de
// shader werkt al in sRGB. Lineariseren maakte #88c0d0 tot (63,134,161).

// --- CONFIGURATION ---
vec4 TRAIL_COLOR = iCurrentCursorColor; // for custom color: vec4(0.2, 0.6, 1.0, 0.5);
// DURATION en TRAIL_SIZE staan op neovide's animation_length en trail_size
// (cursor_renderer/mod.rs). Origineel stond hier 0.2 en 0.8.
const float DURATION = 0.15; // total animation time
// De veer komt asymptotisch aan: op x=1 rest er nog 9%. Neovide loopt door tot
// onder 0.01 px; hier tekenen we tot 2.5x de duur, waar nog 0.05% rest.
const float SETTLE = 2.5;
const float TRAIL_SIZE = 1.0; // 0.0 = all corners move together. 1.0 = max smear (leading corners jump instantly)
// Op 0 omdat j/k precies één cursorhoogte is en met de oorspronkelijke 1.5 dus
// nooit een trail kreeg. Typen wordt verderop apart afgevangen.
const float THRESHOLD_MIN_DISTANCE = 0.0; // min distance to show trail (units of cursor height)
const float BLUR = 1.0; // blur size in pixels (for antialiasing)
const float TRAIL_THICKNESS = 1.0;  // 1.0 = full cursor height, 0.0 = zero height, >1.0 = funky aah
// 1.0 en niet de oorspronkelijke 0.9: neovide's draw_rectangle (mod.rs:537)
// trekt het pad door de vier hoeken zelf, zonder de vorm smaller te maken.
const float TRAIL_THICKNESS_X = 1.0;

const float FADE_ENABLED = 0.0; // 1.0 to enable fade gradient along the trail, 0.0 to disable
const float FADE_EXPONENT = 5.0; // exponent for fade gradient along the trail

// --- CONSTANTS for easing functions ---
const float PI = 3.14159265359;
const float C1_BACK = 1.70158;
const float C2_BACK = C1_BACK * 1.525;
const float C3_BACK = C1_BACK + 1.0;
const float C4_ELASTIC = (2.0 * PI) / 3.0;
const float C5_ELASTIC = (2.0 * PI) / 4.5;
const float SPRING_STIFFNESS = 9.0;
const float SPRING_DAMPING = 0.9;

// --- EASING FUNCTIONS ---

// // Linear
// float ease(float x) {
//     return x;
// }

// // EaseOutQuad
// float ease(float x) {
//     return 1.0 - (1.0 - x) * (1.0 - x);
// }

// // EaseOutCubic
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 3.0);
// }

// // EaseOutQuart
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 4.0);
// }

// // EaseOutQuint
// float ease(float x) {
//     return 1.0 - pow(1.0 - x, 5.0);
// }

// // EaseOutSine
// float ease(float x) {
//     return sin((x * PI) / 2.0);
// }

// // EaseOutExpo
// float ease(float x) {
//     return x == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * x);
// }

// Neovide's kritisch gedempte veer (animation_utils.rs:104-114). Bij een sprong
// vanuit stilstand is velocity 0, dus b = position*omega en blijft er van de
// analytische oplossing dit over:
//     position(t) = delta * (1 + omega*t) * exp(-omega*t),  omega = 4/duur
// Met x = t/duur wordt omega*t exact 4x. Niet klemmen op 1: de staart is
// asymptotisch, net als bij neovide, dat pas stopt onder 0.01 px.
float ease(float x) {
    float ot = 4.0 * x;
    return 1.0 - (1.0 + ot) * exp(-ot);
}

// // EaseOutBack
// float ease(float x) {
//     return 1.0 + C3_BACK * pow(x - 1.0, 3.0) + C1_BACK * pow(x - 1.0, 2.0);
// }

// // EaseOutElastic
// float ease(float x) {
//     return x == 0.0 ? 0.0
//          : x == 1.0 ? 1.0
//                     : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * C4_ELASTIC) + 1.0;
// }

// // Parametric Spring
// float ease(float x) {
//     x = clamp(x, 0.0, 1.0);
//     float decay = exp(-SPRING_DAMPING * SPRING_STIFFNESS * x);
//     float freq = sqrt(SPRING_STIFFNESS * (1.0 - SPRING_DAMPING * SPRING_DAMPING));
//     float osc = cos(freq * 6.283185 * x) + (SPRING_DAMPING * sqrt(SPRING_STIFFNESS) / freq) * sin(freq * 6.283185 * x);
//     return 1.0 - decay * osc;
// }

// Neovide rangschikt de vier hoeken door hun uitlijning met de bewegings-
// richting oplopend te sorteren, met de index als tiebreak (mod.rs:462-481).
// Er is dus altijd precies één hoek met rang 0 en één met rang 1, ook bij een
// zuiver horizontale of verticale sprong. Volgorde van STANDARD_CORNERS:
// 0 linksboven, 1 rechtsboven, 2 rechtsonder, 3 linksonder.
float rankOf(float ai, int i, float a0, float a1, float a2, float a3) {
    float r = 0.0;
    r += (a0 < ai || (a0 == ai && 0 < i)) ? 1.0 : 0.0;
    r += (a1 < ai || (a1 == ai && 1 < i)) ? 1.0 : 0.0;
    r += (a2 < ai || (a2 == ai && 2 < i)) ? 1.0 : 0.0;
    r += (a3 < ai || (a3 == ai && 3 < i)) ? 1.0 : 0.0;
    return r;
}

// rang 2 en 3 leiden, rang 1 zit ertussenin, rang 0 sleept (mod.rs:174-181)
float durationFromRank(float rank) {
    const float TRAIL = DURATION;
    const float LEAD = DURATION * (1.0 - TRAIL_SIZE);
    const float SIDE = (LEAD + TRAIL) / 2.0;
    return rank >= 2.0 ? LEAD : (rank >= 1.0 ? SIDE : TRAIL);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfConvexQuad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);

    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance, float blurAmount) {
  return 1. - smoothstep(0., normalize(vec2(blurAmount, blurAmount), 0.).x, distance);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // normalization & setup(-1, 1 coords)
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 halfSizeCC = currentCursor.zw * 0.5;
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);
    vec2 halfSizeCP = previousCursor.zw * 0.5;

    float sdfCurrentCursor = getSdfRectangle(vu, centerCC, halfSizeCC);
    
    float lineLength = distance(centerCC, centerCP);
    float minDist = currentCursor.w * THRESHOLD_MIN_DISTANCE;
    
    vec4 newColor = vec4(fragColor);

    float baseProgress = iTime - iTimeCursorChange;

    // Korte sprong volgens neovide (mod.rs:165): tot twee tekens op dezelfde
    // regel. Daar tekenen we niets. Neovide schuift in dat geval de cursor zelf
    // in 0.04s, maar ghostty verplaatst de cursor al meteen — een trail erbij
    // zou een tweede rechthoek naast de cursor zetten, zichtbaar bij het typen.
    // Gemeten in celhoogtes en niet in cursorbreedtes: ghostty geeft als breedte
    // de sprite van de cursor (generic.zig:2141), dus bij een balkcursor de
    // balkdikte in plaats van de cel. Neovide deelt door de celmaat, die niet
    // van de vorm afhangt. De hoogte is voor blok en balk wel de cel, en met
    // Monaspace is 2 cellen breed gelijk aan 1.03 celhoogte; 1.05 houdt marge
    // en blijft ruim onder de 1.54 van drie cellen.
    vec2 jumpVec = centerCC - centerCP;
    float sameLine = 1.0 - step(0.0001, abs(jumpVec.y));
    float isShortJump = sameLine * step(abs(jumpVec.x), 1.05 * currentCursor.w);

    if (lineLength > minDist && isShortJump < 0.5 && baseProgress < DURATION * SETTLE - 0.001) {
        // defining corners of cursors

        // Y (Height) with TRAIL_THICKNESS
        float cc_half_height = currentCursor.w * 0.5;
        float cc_center_y = currentCursor.y - cc_half_height;
        float cc_new_half_height = cc_half_height * TRAIL_THICKNESS;
        float cc_new_top_y = cc_center_y + cc_new_half_height;
        float cc_new_bottom_y = cc_center_y - cc_new_half_height;

        // X (Width) with TRAIL_THICKNESS
        float cc_half_width = currentCursor.z * 0.5;
        float cc_center_x = currentCursor.x + cc_half_width;
        float cc_new_half_width = cc_half_width * TRAIL_THICKNESS_X;
        float cc_new_left_x = cc_center_x - cc_new_half_width;
        float cc_new_right_x = cc_center_x + cc_new_half_width;

        vec2 cc_tl = vec2(cc_new_left_x, cc_new_top_y);
        vec2 cc_tr = vec2(cc_new_right_x, cc_new_top_y);
        vec2 cc_bl = vec2(cc_new_left_x, cc_new_bottom_y);
        vec2 cc_br = vec2(cc_new_right_x, cc_new_bottom_y);

        // same thing for previous cursor
        float cp_half_height = previousCursor.w * 0.5;
        float cp_center_y = previousCursor.y - cp_half_height;
        float cp_new_half_height = cp_half_height * TRAIL_THICKNESS;
        float cp_new_top_y = cp_center_y + cp_new_half_height;
        float cp_new_bottom_y = cp_center_y - cp_new_half_height;

        float cp_half_width = previousCursor.z * 0.5;
        float cp_center_x = previousCursor.x + cp_half_width;
        float cp_new_half_width = cp_half_width * TRAIL_THICKNESS_X;
        float cp_new_left_x = cp_center_x - cp_new_half_width;
        float cp_new_right_x = cp_center_x + cp_new_half_width;

        vec2 cp_tl = vec2(cp_new_left_x, cp_new_top_y);
        vec2 cp_tr = vec2(cp_new_right_x, cp_new_top_y);
        vec2 cp_bl = vec2(cp_new_left_x, cp_new_bottom_y);
        vec2 cp_br = vec2(cp_new_right_x, cp_new_bottom_y);

        vec2 moveVec = jumpVec;
        vec2 s = sign(moveVec);

        // Uitlijning per hoek: het genormaliseerde dotproduct met de reisrichting
        // (mod.rs:197-214). Op het sprongmoment staan alle hoeken nog op de vorige
        // rechthoek, dus is de reisrichting voor alle vier gelijk aan moveVec.
        vec2 td = normalize(moveVec);
        float a_tl = dot(vec2(-1.,  1.), td);
        float a_tr = dot(vec2( 1.,  1.), td);
        float a_br = dot(vec2( 1., -1.), td);
        float a_bl = dot(vec2(-1., -1.), td);

        float final_dur_tl = durationFromRank(rankOf(a_tl, 0, a_tl, a_tr, a_br, a_bl));
        float final_dur_tr = durationFromRank(rankOf(a_tr, 1, a_tl, a_tr, a_br, a_bl));
        float final_dur_br = durationFromRank(rankOf(a_br, 2, a_tl, a_tr, a_br, a_bl));
        float final_dur_bl = durationFromRank(rankOf(a_bl, 3, a_tl, a_tr, a_br, a_bl));

        // calculate progress for each corner based on the duration and time since cursor change
        // max() vangt de leidende hoek af: die heeft duur 0 bij TRAIL_SIZE 1.0,
        // en delen door nul geeft inf en daarna NaN in ease().
        float prog_tl = ease(baseProgress / max(final_dur_tl, 1e-5));
        float prog_tr = ease(baseProgress / max(final_dur_tr, 1e-5));
        float prog_bl = ease(baseProgress / max(final_dur_bl, 1e-5));
        float prog_br = ease(baseProgress / max(final_dur_br, 1e-5));

        // get the trial corner positions based on progress
        vec2 v_tl = mix(cp_tl, cc_tl, prog_tl);
        vec2 v_tr = mix(cp_tr, cc_tr, prog_tr);
        vec2 v_br = mix(cp_br, cc_br, prog_br);
        vec2 v_bl = mix(cp_bl, cc_bl, prog_bl);

        // DRAWING THE TRAIL
        float sdfTrail = getSdfConvexQuad(vu, v_tl, v_tr, v_br, v_bl);

        // --- FADE GRADIENT CALCULATION ---
        vec2 fragVec = vu - centerCP;
        
        // project fragment onto movement vector, normalize to [0, 1]
        // 0.0 at tail, 1.0 at head
        // tiny epsilon to avoid division by zero if moveVec is (0,0)
        float fadeProgress = clamp(dot(fragVec, moveVec) / (dot(moveVec, moveVec) + 1e-6), 0.0, 1.0);

        vec4 trail = TRAIL_COLOR;
        
        // Neovide antialiast onvoorwaardelijk (mod.rs:347), dus geen uitzondering
        // voor horizontaal/verticaal. Die stond hier wel, maar deed niets: de
        // binnenste declaratie overschaduwde de buitenste.
        float shapeAlpha = antialising(sdfTrail, BLUR); // shape mask

        if (FADE_ENABLED > 0.5) {
            // apply fade gradient along the trail
            // float fadeStart = 0.2;
            // float easedProgress = smoothstep(fadeStart, 1.0, fadeProgress);
            // easedProgress = pow(2.0, 10.0 * (fadeProgress - 1.0));
            float easedProgress = pow(fadeProgress, FADE_EXPONENT);
            trail.a *= easedProgress;
        }

        float finalAlpha = trail.a * shapeAlpha;

        // newColor.a to preserve the background alpha.
        newColor = mix(newColor, vec4(trail.rgb, newColor.a), finalAlpha);

        // punch hole on the trail, so current cursor is drawn on top
        newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));

    }

    fragColor = newColor;
}
