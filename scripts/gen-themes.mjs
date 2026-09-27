// One-off generator for Raaga's preset themes. Given each theme's {accent, bg, fg, mode} it derives
// a full coherent OKLCH token set (the same token list :root defines) and prints the layout.css
// blocks plus the THEMES[] entries. Not shipped; kept in scripts/ so the palettes can be regenerated.

// --- colour maths: hex -> OKLCH ---------------------------------------------------------------
const srgbToLin = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
function hexToRgb(hex) {
	const h = hex.replace('#', '');
	return [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
}
function hexToOklch(hex) {
	const [r, g, b] = hexToRgb(hex).map(srgbToLin);
	const l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
	const m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
	const s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;
	const l_ = Math.cbrt(l), m_ = Math.cbrt(m), s_ = Math.cbrt(s);
	const L = 0.2104542553 * l_ + 0.793617785 * m_ - 0.0040720468 * s_;
	const a = 1.9779984951 * l_ - 2.428592205 * m_ + 0.4505937099 * s_;
	const bb = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.808675766 * s_;
	const C = Math.hypot(a, bb);
	let hd = (Math.atan2(bb, a) * 180) / Math.PI;
	if (hd < 0) hd += 360;
	return { L, C, h: hd };
}
// HSP perceived brightness for the light/dark text decision (matches ui/src/lib/color.ts).
function isLight(hex) {
	const [r, g, b] = hexToRgb(hex);
	return Math.sqrt(0.299 * r * r + 0.587 * g * g + 0.114 * b * b) > 0.6;
}
const cl = (n, lo, hi) => Math.min(hi, Math.max(lo, n));
const ok = ({ L, C, h }) => `oklch(${L.toFixed(4)} ${C.toFixed(4)} ${h.toFixed(2)})`;
const okA = ({ L, C, h }, a) => `oklch(${L.toFixed(4)} ${C.toFixed(4)} ${h.toFixed(2)} / ${a})`;
const shift = (base, dL, kC = 1) => ({ L: cl(base.L + dL, 0, 1), C: base.C * kC, h: base.h });
const ON_DARK = { L: 0.985, C: 0, h: 0 };
const ON_LIGHT = { L: 0.205, C: 0, h: 0 };

// --- theme inputs (read off the brief) --------------------------------------------------------
const THEMES = [
	{ id: 'crimson-premiere', label: 'Crimson Premiere', mode: 'dark', bg: '#0a0a0a', fg: '#ffffff', accent: '#e50914' },
	{ id: 'cinematic-dark', label: 'Cinematic Dark', mode: 'dark', bg: '#0a0a0a', fg: '#f5efe8', accent: '#e8852a' },
	{ id: 'butter-green', label: 'Butter & Forest', mode: 'dark', bg: '#013e37', fg: '#f2f7f2', accent: '#ffefb3' },
	{ id: 'cherry-cola', label: 'Cherry & Vanilla', mode: 'dark', bg: '#1a0305', fg: '#efe6dd', accent: '#efe6dd', accent2: '#b03a4a' },
	{ id: 'bistre-aureolin', label: 'Bistre & Gold', mode: 'dark', bg: '#190e04', fg: '#f7ecd9', accent: '#fbe311' },
	{ id: 'vibrant-lime', label: 'Lime & Black', mode: 'dark', bg: '#0b0e02', fg: '#eaf7d0', accent: '#d3f00a' },
	{ id: 'imperial-violet', label: 'Imperial Violet', mode: 'dark', bg: '#190b24', fg: '#e2cbff', accent: '#e2cbff', accent2: '#a56bd6' },
	{ id: 'midnight-ocean', label: 'Midnight Ocean', mode: 'dark', bg: '#0a1128', fg: '#e6f7f4', accent: '#00f5d4' },
	{ id: 'neon-cyberpunk', label: 'Neon Cyberpunk', mode: 'dark', bg: '#1a0b2e', fg: '#f0eaff', accent: '#05d9e8', accent2: '#ff2a6d' },
	{ id: 'elegant-light', label: 'Elegant Ivory', mode: 'light', bg: '#f5f0e8', fg: '#3e2723', accent: '#3e2723' },
	{ id: 'clean-daylight', label: 'Clean Daylight', mode: 'light', bg: '#ffffff', fg: '#0f172a', accent: '#2563eb' },
	{ id: 'vanilla-cherry', label: 'Vanilla & Cherry', mode: 'light', bg: '#fdfaf7', fg: '#2b1a12', accent: '#9a0002' },
	{ id: 'nordic-frost', label: 'Nordic Frost', mode: 'light', bg: '#f0f4f8', fg: '#0f2233', accent: '#0284c7' },
	{ id: 'matcha-cream', label: 'Matcha & Cream', mode: 'light', bg: '#f4f7f2', fg: '#1e2b22', accent: '#2d6a4f' },
	{ id: 'sunset-rose', label: 'Sunset Rose', mode: 'light', bg: '#fdf6f6', fg: '#3a1220', accent: '#e11d48' }
];

function block(t) {
	const bg = hexToOklch(t.bg);
	const fg = hexToOklch(t.fg);
	const accent = hexToOklch(t.accent);
	const accent2 = t.accent2 ? hexToOklch(t.accent2) : shift(accent, 0, 1);
	const onAccent = isLight(t.accent) ? ON_LIGHT : ON_DARK;
	const dark = t.mode === 'dark';
	// Neutral ramp derived from the background. Dark themes step lighter; light themes step darker,
	// with cards pulled toward paper white. Chroma is kept low so surfaces read as neutral, tinted.
	const nc = Math.min(bg.C, 0.03); // neutral chroma cap
	const s = (dL) => ({ L: cl(bg.L + dL, 0, 1), C: nc, h: bg.h });
	const card = dark ? s(0.045) : { L: cl(bg.L + 0.02, 0, 0.995), C: nc * 0.6, h: bg.h };
	const popover = dark ? s(0.07) : card;
	const secondary = dark ? s(0.11) : s(-0.05);
	const muted = dark ? s(0.09) : s(-0.035);
	const mutedFg = { L: dark ? 0.72 : 0.5, C: Math.min(bg.C, 0.035), h: bg.h };
	const border = dark ? okA(ON_DARK, '12%') : ok(s(-0.09));
	const input = dark ? okA(ON_DARK, '16%') : ok(s(-0.09));
	const sidebar = dark ? s(0.02) : s(-0.015);
	const chart = (n) => ok({ L: cl(accent.L + (dark ? 0.05 : -0.03) * n, 0.35, 0.9), C: accent.C * 0.92, h: (accent.h + n * 42) % 360 });
	const destructive = dark ? 'oklch(0.7040 0.1900 22.20)' : 'oklch(0.5800 0.2400 27.30)';
	const rows = {
		'--background': ok(bg),
		'--foreground': ok(fg),
		'--card': ok(card),
		'--card-foreground': ok(fg),
		'--popover': ok(popover),
		'--popover-foreground': ok(fg),
		'--primary': ok(accent),
		'--primary-foreground': ok(onAccent),
		'--secondary': ok(secondary),
		'--secondary-foreground': ok(fg),
		'--muted': ok(muted),
		'--muted-foreground': ok(mutedFg),
		'--accent': ok(accent),
		'--accent-foreground': ok(onAccent),
		'--destructive': destructive,
		'--border': border,
		'--input': input,
		'--ring': ok(accent),
		'--chart-1': ok(accent),
		'--chart-2': ok(accent2),
		'--chart-3': chart(1),
		'--chart-4': chart(2),
		'--chart-5': chart(3),
		'--sidebar': ok(sidebar),
		'--sidebar-foreground': ok(fg),
		'--sidebar-primary': ok(accent),
		'--sidebar-primary-foreground': ok(onAccent),
		'--sidebar-accent': ok(secondary),
		'--sidebar-accent-foreground': ok(fg),
		'--sidebar-border': border,
		'--sidebar-ring': ok(accent)
	};
	const body = Object.entries(rows).map(([k, v]) => `\t${k}: ${v};`).join('\n');
	// One block, no .dark twin: preset blocks come after .dark in source order and define the whole
	// token set, so the theme paints identically whether or not mode-watcher has toggled .dark.
	return `.theme-${t.id},\n.dark.theme-${t.id} {\n${body}\n}`;
}

const css = THEMES.map(block).join('\n\n');
const list = THEMES.map((t) => {
	const a = hexToOklch(t.accent);
	return `\t{ id: '${t.id}', label: '${t.label}', color: '${ok(a)}' }`;
}).join(',\n');
const union = THEMES.map((t) => `\t| '${t.id}'`).join('\n');

console.log('/* ===THEMES-CSS=== */');
console.log(css);
console.log('/* ===THEMES-LIST=== */');
console.log(list);
console.log('/* ===THEMES-UNION=== */');
console.log(union);
