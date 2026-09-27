import type { ReactNode } from 'react'
import { HugeiconsIcon } from '@hugeicons/react'
import {
  MusicNote01Icon,
  DashboardSpeed01Icon,
  AudioWave01Icon,
  QuoteDownIcon,
  UserMultiple02Icon,
  LibraryIcon,
  Folder01Icon,
  PaintBoardIcon,
  TranslateIcon,
  KeyboardIcon,
  LastFmIcon,
  DiscordIcon,
  Video01Icon,
  Minimize01Icon,
  MaximizeScreenIcon,
  ComputerIcon,
  HistoryIcon,
  RefreshIcon,
  PackageIcon,
  WindowsOldIcon,
  Apple01Icon,
  GithubIcon,
  StarIcon,
  SourceCodeIcon,
  ArrowUpRight01Icon,
} from '@hugeicons/core-free-icons'

import SplitText from '@/components/SplitText'
import AnimatedContent from '@/components/AnimatedContent'
import FadeContent from '@/components/FadeContent'
import { useGitHub, detectOS, REPO_URL, RELEASES_URL } from '@/lib/github'


import logo from '@/assets/logo.png'
import screenPlaylist from '@/assets/screen-playlist.png'
import screenLyrics from '@/assets/screen-lyrics.png'
import screenAlbum from '@/assets/screen-album.png'
import screenQueue from '@/assets/screen-queue.png'
import screenTogether from '@/assets/screen-listen-together.png'
import screenMini from '@/assets/screen-mini.png'

const BUILD_DOCS_URL = `${REPO_URL}/blob/master/docs/BUILD-PLATFORMS.md`

const FEATURES = [
  {
    icon: MusicNote01Icon,
    title: 'No ads, ever',
    body: 'Raaga plays the audio stream directly, so there is nothing to interrupt. No ad breaks, no premium tier, no waiting on a countdown before the next song.',
  },
  {
    icon: DashboardSpeed01Icon,
    title: 'Light on your machine',
    body: 'A native Rust core instead of a bundled browser. Opens fast, sips memory, keeps the fans quiet.',
  },
  {
    icon: AudioWave01Icon,
    title: 'Gapless, tuned sound',
    body: 'mpv under the hood: gapless transitions, loudness normalization from YouTube’s own metadata, and a quality setting for lighter data.',
  },
  {
    icon: QuoteDownIcon,
    title: 'Lyrics that follow along',
    body: 'Synced lyrics scroll with the song, and where the source has word timings the line lights up as it is sung. Translations sit under each line.',
  },
  {
    icon: UserMultiple02Icon,
    title: 'Listen Together',
    body: 'Host a session, share one invite code, and play in perfect sync with friends.',
  },
  {
    icon: LibraryIcon,
    title: 'Your library, intact',
    body: 'Sign in and your playlists, likes, albums, uploads and history are all there. Every change writes back to YouTube Music.',
  },
  {
    icon: Folder01Icon,
    title: 'Your own files too',
    body: 'Point Raaga at a folder and your local music sits beside the rest, artwork and tags intact, playable offline.',
  },
  {
    icon: PaintBoardIcon,
    title: 'Make it yours',
    body: 'Accent palettes, custom colors, your own fonts, corner roundness, even the app icon. Or let all of it follow the album cover that is playing.',
  },
  {
    icon: TranslateIcon,
    title: 'Speaks your language',
    body: 'English, Spanish, French, Turkish, Brazilian Portuguese and Indonesian ship today, with more on the way. Numbers, dates and lyrics localize with the interface.',
  },
]

const EXTRAS = [
  { icon: KeyboardIcon, label: 'Media keys & shortcuts' },
  { icon: LastFmIcon, label: 'Last.fm scrobbling' },
  { icon: DiscordIcon, label: 'Discord Rich Presence' },
  { icon: Video01Icon, label: 'Music videos' },
  { icon: MaximizeScreenIcon, label: 'Theater mode' },
  { icon: Minimize01Icon, label: 'Mini player' },
  { icon: ComputerIcon, label: 'System tray' },
  { icon: HistoryIcon, label: 'Play history' },
  { icon: RefreshIcon, label: 'Auto-updates' },
]

const SCREENS = [
  {
    eyebrow: 'Lyrics',
    title: 'Sing every word',
    body: 'Synced lyrics stay locked to the music, word by word where the source has the timings. Six providers are tried in order, so coming up empty is rare, and matching goes by the track’s exact length rather than its title.',
    img: screenLyrics,
    alt: 'Raaga showing word-by-word synced lyrics beside the album cover',
  },
  {
    eyebrow: 'Browse',
    title: 'Go down the rabbit hole',
    body: 'Albums, artists, singles, moods and mixes: the whole YouTube Music catalog in a native window. Results preview as you type, Ctrl+K searches from any page, and the colors follow whatever is playing.',
    img: screenAlbum,
    alt: 'An album page in Raaga with the track list and play counts',
  },
  {
    eyebrow: 'Queue',
    title: 'See what’s coming up',
    body: 'The full queue sits beside the artwork — reorder it, jump ahead, or peek at the radio it built from the last thing you played. History is one click away when you want a track you skipped past.',
    img: screenQueue,
    alt: 'The Raaga now-playing view with the up-next queue alongside the album cover',
  },
  {
    eyebrow: 'Together',
    title: 'Press play with friends',
    body: 'Start a Listen Together session and send one invite code. Every play, skip and queue change stays in sync, and everyone streams their own audio, so the room only relays the controls.',
    img: screenTogether,
    alt: 'The Listen Together dialog in Raaga',
  },
  {
    eyebrow: 'Mini player',
    title: 'Out of the way, still there',
    body: 'Shrink the window to a strip with the artwork, the transport and the lyrics, and keep it on top while you work. Or go the other way with theater mode: fullscreen cover on one side, lyrics on the other.',
    img: screenMini,
    alt: 'The Raaga mini player floating over a desktop, showing lyrics',
    narrow: true,
  },
]

// PLACEHOLDER_COMPONENTS

/* Gold mark on a small espresso disc so it reads on ivory. */
function Mark({ className = 'size-8' }: { className?: string }) {
  return (
    <span className={`grid place-items-center rounded-full bg-ink ${className}`}>
      <img src={logo} alt="" className="size-[62%]" />
    </span>
  )
}

const EASE = 'transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]'

function Nav({ stars }: { stars: number | null }) {
  return (
    <header className="fixed inset-x-0 top-0 z-50 flex justify-center px-4 pt-4 sm:pt-5">
      <nav className="flex w-full max-w-4xl items-center gap-2 rounded-full bg-paper/80 px-2.5 py-2 pl-3 backdrop-blur-xl gold-hairline shadow-[0_12px_40px_-20px_oklch(0.19_0.024_44/0.5)]">
        <a href="#top" className="flex items-center gap-2.5">
          <Mark className="size-8" />
          <span className="font-display text-lg font-semibold tracking-tight">Raaga</span>
        </a>
        <div className="mx-auto hidden items-center gap-1 text-sm text-muted-foreground sm:flex">
          {[
            ['Features', '#features'],
            ['Screens', '#screens'],
            ['Download', '#download'],
          ].map(([label, href]) => (
            <a
              key={href}
              href={href}
              className={`rounded-full px-3.5 py-1.5 hover:bg-surface-2 hover:text-foreground ${EASE}`}
            >
              {label}
            </a>
          ))}
        </div>
        <a
          href={REPO_URL}
          target="_blank"
          rel="noreferrer"
          className={`group ml-auto flex items-center gap-2 rounded-full bg-ink px-4 py-2 text-sm font-medium text-background hover:bg-primary sm:ml-0 ${EASE}`}
        >
          <HugeiconsIcon icon={GithubIcon} size={16} strokeWidth={1.8} />
          <span className="hidden sm:inline">Star</span>
          {stars !== null && (
            <span className="flex items-center gap-1 text-xs opacity-80">
              <HugeiconsIcon icon={StarIcon} size={12} strokeWidth={2} fill="currentColor" />
              {stars}
            </span>
          )}
        </a>
      </nav>
    </header>
  )
}

/* Primary CTA with the nested "button-in-button" trailing icon. */
function Cta({ href, children, target }: { href: string; children: ReactNode; target?: string }) {
  return (
    <a
      href={href}
      target={target}
      rel={target ? 'noreferrer' : undefined}
      className={`group inline-flex items-center gap-3 rounded-full bg-primary py-2 pr-2 pl-6 font-semibold text-primary-foreground shadow-[0_16px_36px_-14px_oklch(0.53_0.204_21/0.7)] hover:bg-primary-bright active:scale-[0.98] ${EASE}`}
    >
      {children}
      <span className={`grid size-9 place-items-center rounded-full bg-primary-foreground/15 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 ${EASE}`}>
        <HugeiconsIcon icon={ArrowUpRight01Icon} size={18} strokeWidth={2} />
      </span>
    </a>
  )
}

function Hero({ version, downloadHref, osLabel }: { version: string | null; downloadHref: string; osLabel: string }) {
  return (
    <section id="top" className="relative overflow-hidden px-4 pt-32 pb-16 sm:px-6 sm:pt-40">
      <div className="pointer-events-none absolute -top-32 right-[-10%] h-[36rem] w-[36rem] rounded-full bg-[radial-gradient(circle,oklch(0.78_0.09_80/0.35),transparent_65%)] blur-2xl" aria-hidden />
      <div className="relative mx-auto max-w-6xl">
        <FadeContent duration={800}>
          <span className="inline-flex items-center gap-2 rounded-full bg-surface px-3.5 py-1.5 text-[11px] font-medium tracking-[0.2em] text-muted-foreground uppercase gold-hairline">
            <span className="size-1.5 rounded-full bg-primary-bright" />
            Free · Open source · Linux, Windows &amp; macOS
          </span>
        </FadeContent>

        <div className="mt-7 grid items-end gap-8 lg:grid-cols-[1.15fr_0.85fr]">
          <SplitText
            text="A record player for the whole internet."
            tag="h1"
            splitType="words"
            delay={90}
            duration={1}
            className="font-display text-5xl font-semibold text-balance sm:text-6xl md:text-[5.2rem]"
          />
          <FadeContent duration={900} delay={400}>
            <p className="max-w-md text-lg leading-relaxed text-muted-foreground lg:pb-3">
              Raaga is a lightweight desktop player for YouTube Music. Search anything, press play, and
              listen without ads — your playlists, your own files, synced lyrics and friends listening
              along, in a window that opens instantly.
            </p>
          </FadeContent>
        </div>

        <FadeContent duration={900} delay={600}>
          <div className="mt-9 flex flex-wrap items-center gap-4">
            <Cta href={downloadHref}>Download for {osLabel}</Cta>
            <a
              href={REPO_URL}
              target="_blank"
              rel="noreferrer"
              className={`inline-flex items-center gap-2.5 rounded-full px-6 py-3 font-medium hover:bg-surface-2 gold-hairline ${EASE}`}
            >
              <HugeiconsIcon icon={GithubIcon} size={20} strokeWidth={1.8} />
              View source
            </a>
            <p className="text-sm text-muted-foreground">
              {version ? `${version} · ` : ''}three platforms, one build
            </p>
          </div>
        </FadeContent>

        <AnimatedContent distance={90} duration={1.1} delay={0.25} scale={0.97} threshold={0}>
          <figure className="mt-14 rounded-[2.2rem] bg-surface/70 p-2 backdrop-blur gold-hairline">
            <img
              src={screenPlaylist}
              alt="Raaga playing a playlist, with the sidebar and track list open"
              width={1600}
              height={867}
              className="w-full rounded-[1.8rem] shadow-[0_50px_120px_-40px_oklch(0.19_0.024_44/0.6)] ring-1 ring-ink/10"
            />
          </figure>
        </AnimatedContent>
      </div>
    </section>
  )
}

function Marquee() {
  const items = [...EXTRAS, ...EXTRAS]
  return (
    <div className="marquee relative overflow-hidden border-y border-border py-4">
      <div className="marquee-track flex w-max items-center gap-10 pr-10">
        {items.map((e, i) => (
          <span key={i} className="flex shrink-0 items-center gap-2.5 text-sm font-medium text-muted-foreground">
            <HugeiconsIcon icon={e.icon} size={17} strokeWidth={1.6} className="text-gold" />
            {e.label}
            <span className="ml-10 text-gold/50">✦</span>
          </span>
        ))}
      </div>
      <div className="pointer-events-none absolute inset-y-0 left-0 w-24 bg-gradient-to-r from-background to-transparent" />
      <div className="pointer-events-none absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-background to-transparent" />
    </div>
  )
}

// col-span map for the asymmetric bento (lg, 12-col grid)
const SPANS = [
  'lg:col-span-6',
  'lg:col-span-6',
  'lg:col-span-4',
  'lg:col-span-4',
  'lg:col-span-4',
  'lg:col-span-4',
  'lg:col-span-4',
  'lg:col-span-4',
  'lg:col-span-12',
]

function Features() {
  return (
    <section id="features" className="mx-auto max-w-6xl scroll-mt-24 px-4 py-24 sm:px-6 sm:py-32">
      <FadeContent duration={800}>
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-xs font-semibold tracking-[0.22em] text-gold uppercase">Why Raaga</p>
            <h2 className="mt-3 max-w-xl font-display text-4xl font-semibold text-balance sm:text-5xl">
              Everything the web player should have been
            </h2>
          </div>
          <p className="max-w-xs text-sm leading-relaxed text-muted-foreground text-pretty">
            One quiet native window that does the obvious things well, and a few the browser never could.
          </p>
        </div>
      </FadeContent>

      <div className="mt-14 grid gap-4 lg:grid-cols-12">
        {FEATURES.map((f, i) => (
          <AnimatedContent key={f.title} className={`${SPANS[i]} h-full`} distance={44} duration={0.8} delay={(i % 3) * 0.08} threshold={0.12}>
            <article
              className={`group relative flex h-full flex-col rounded-[1.7rem] bg-card p-1.5 gold-hairline ${EASE} hover:-translate-y-1`}
            >
              <div className="flex h-full flex-col rounded-[1.35rem] bg-paper p-6 shadow-[inset_0_1px_0_0_oklch(1_0_0/0.6)]">
                <span className={`mb-5 grid size-11 place-items-center rounded-xl bg-surface-2 text-primary group-hover:bg-primary group-hover:text-primary-foreground ${EASE}`}>
                  <HugeiconsIcon icon={f.icon} size={22} strokeWidth={1.5} />
                </span>
                <h3 className="font-display text-xl font-semibold">{f.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted-foreground text-pretty">{f.body}</p>
              </div>
            </article>
          </AnimatedContent>
        ))}
      </div>
    </section>
  )
}

function Screens() {
  return (
    <section id="screens" className="scroll-mt-24 px-4 py-8 sm:px-6">
      <div className="mx-auto max-w-6xl space-y-24 sm:space-y-32">
        {SCREENS.map((s, i) => (
          <AnimatedContent key={s.title} distance={64} duration={0.9} threshold={0.12}>
            <div className={`flex flex-col items-center gap-8 lg:gap-16 ${i % 2 ? 'lg:flex-row-reverse' : 'lg:flex-row'}`}>
              <div className="lg:w-[38%]">
                <div className="flex items-center gap-3">
                  <span className="font-display text-3xl font-semibold text-gold/70">
                    {String(i + 1).padStart(2, '0')}
                  </span>
                  <span className="h-px flex-1 bg-gradient-to-r from-gold/40 to-transparent" />
                </div>
                <p className="mt-4 text-xs font-semibold tracking-[0.22em] text-primary uppercase">{s.eyebrow}</p>
                <h3 className="mt-2 font-display text-3xl font-semibold text-balance sm:text-4xl">{s.title}</h3>
                <p className="mt-4 leading-relaxed text-muted-foreground text-pretty">{s.body}</p>
              </div>
              <div className="lg:w-[62%]">
                <figure className={`rounded-[1.9rem] bg-surface/70 p-2 backdrop-blur gold-hairline ${s.narrow ? 'mx-auto w-full max-w-md' : 'w-full'}`}>
                  <img
                    src={s.img}
                    alt={s.alt}
                    loading="lazy"
                    className="w-full rounded-[1.5rem] shadow-[0_40px_90px_-40px_oklch(0.19_0.024_44/0.55)] ring-1 ring-ink/10"
                  />
                </figure>
              </div>
            </div>
          </AnimatedContent>
        ))}
      </div>
    </section>
  )
}

interface DownloadCard {
  os: string
  icon: typeof PackageIcon
  detected: boolean
  links: { label: string; href: string | null }[]
  note?: ReactNode
}

function Download({ info, os }: { info: ReturnType<typeof useGitHub>; os: string }) {
  const cards: DownloadCard[] = [
    {
      os: 'Linux',
      icon: PackageIcon,
      detected: os === 'linux',
      links: [
        { label: '.AppImage, any distro', href: info.appimage },
        { label: '.deb, Ubuntu and Debian', href: info.deb },
        { label: '.rpm, Fedora and RHEL', href: info.rpm },
      ],
      note: 'Only the AppImage updates itself. All builds need glibc 2.39 or newer (Ubuntu 24.04+, Debian 13+, Fedora 40+), and the rpm needs mpv-libs installed.',
    },
    {
      os: 'Windows',
      icon: WindowsOldIcon,
      detected: os === 'windows',
      links: [
        { label: 'Installer (.exe)', href: info.exe },
        { label: 'MSI package', href: info.msi },
      ],
      note: 'The installer updates itself. The MSI is a plain install with no auto-update.',
    },
    {
      os: 'macOS',
      icon: Apple01Icon,
      detected: os === 'mac',
      links: [
        { label: '.dmg, Apple Silicon', href: info.dmg },
        { label: 'Intel Mac: build from source', href: BUILD_DOCS_URL },
      ],
      note: (
        <>
          The app updates itself, but it is not signed with an Apple certificate, so the first launch
          needs one Terminal command:{' '}
          <code className="rounded bg-surface-2 px-1 py-0.5 text-[11px] break-all">
            xattr -dr com.apple.quarantine /Applications/raaga.app
          </code>
        </>
      ),
    },
  ]

  return (
    <section id="download" className="mx-auto max-w-6xl scroll-mt-24 px-4 py-24 sm:px-6 sm:py-32">
      <FadeContent duration={800}>
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-xs font-semibold tracking-[0.22em] text-gold uppercase">Download</p>
          <h2 className="mt-3 font-display text-4xl font-semibold text-balance sm:text-5xl">Get Raaga</h2>
          <p className="mx-auto mt-4 max-w-lg text-muted-foreground text-pretty">
            Free and open source. Install it, sign in with your YouTube account if you want your
            library, and press play.
          </p>
        </div>
      </FadeContent>

      <div className="mt-14 grid gap-4 md:grid-cols-3">
        {cards.map((c, i) => (
          <AnimatedContent key={c.os} distance={44} duration={0.8} delay={i * 0.09} threshold={0.12}>
            <div
              className={`flex h-full flex-col rounded-[1.7rem] p-1.5 ${EASE} ${
                c.detected ? 'bg-primary/12' : 'bg-card'
              } gold-hairline`}
            >
              <div className="flex h-full flex-col rounded-[1.35rem] bg-paper p-6 shadow-[inset_0_1px_0_0_oklch(1_0_0/0.6)]">
                <div className="flex items-center gap-3">
                  <span className="grid size-10 place-items-center rounded-xl bg-surface-2 text-primary">
                    <HugeiconsIcon icon={c.icon} size={22} strokeWidth={1.5} />
                  </span>
                  <h3 className="font-display text-xl font-semibold">{c.os}</h3>
                  {c.detected && (
                    <span className="ml-auto rounded-full bg-primary px-2.5 py-0.5 text-xs font-medium text-primary-foreground">
                      Your system
                    </span>
                  )}
                </div>
                <div className="mt-5 flex flex-1 flex-col gap-2">
                  {c.links.map(l => (
                    <a
                      key={l.label}
                      href={l.href ?? RELEASES_URL}
                      className={`rounded-xl bg-surface px-4 py-2.5 text-center text-sm font-medium hover:bg-primary hover:text-primary-foreground ${EASE}`}
                    >
                      {l.label}
                    </a>
                  ))}
                </div>
                {c.note && <p className="mt-4 text-xs leading-relaxed text-muted-foreground text-pretty">{c.note}</p>}
              </div>
            </div>
          </AnimatedContent>
        ))}
      </div>

      <p className="mt-8 text-center text-sm text-muted-foreground">
        {info.version && <>Latest release <span className="text-foreground">{info.version}</span> · </>}
        <a href={`${REPO_URL}/releases`} target="_blank" rel="noreferrer" className="underline decoration-gold/50 underline-offset-4 hover:text-foreground">
          All releases
        </a>
      </p>
    </section>
  )
}

function Footer() {
  return (
    <footer className="border-t border-border">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-5 px-4 py-14 text-center text-sm text-muted-foreground sm:px-6">
        <div className="flex items-center gap-2.5">
          <Mark className="size-7" />
          <span className="font-display text-base font-semibold text-foreground">Raaga</span>
        </div>
        <p className="max-w-2xl text-xs leading-relaxed text-pretty">
          Raaga is an unofficial, open-source client and is not affiliated with or endorsed by
          YouTube or Google. YouTube Music is a trademark of Google LLC.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-5">
          <a href={REPO_URL} target="_blank" rel="noreferrer" className={`flex items-center gap-1.5 hover:text-foreground ${EASE}`}>
            <HugeiconsIcon icon={GithubIcon} size={15} strokeWidth={1.8} /> Source
          </a>
          <a href={`${REPO_URL}/blob/master/LICENSE`} target="_blank" rel="noreferrer" className={`flex items-center gap-1.5 hover:text-foreground ${EASE}`}>
            <HugeiconsIcon icon={SourceCodeIcon} size={15} strokeWidth={1.8} /> GPL-3.0
          </a>
        </div>
      </div>
    </footer>
  )
}

export default function App() {
  const info = useGitHub()
  const os = detectOS()
  const osLabel = os === 'windows' ? 'Windows' : os === 'mac' ? 'macOS' : 'Linux'
  const downloadHref =
    (os === 'windows' ? info.exe : os === 'mac' ? info.dmg : info.appimage) ?? '#download'

  return (
    <>
      <div className="grain" aria-hidden />
      <Nav stars={info.stars} />
      <main>
        <Hero version={info.version} downloadHref={downloadHref} osLabel={osLabel} />
        <Marquee />
        <Features />
        <Screens />
        <Download info={info} os={os} />
      </main>
      <Footer />
    </>
  )
}




