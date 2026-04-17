import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import {
  AlertCircle,
  ArrowRightLeft,
  BarChart3,
  Building2,
  Car,
  CheckCircle2,
  ChevronRight,
  Clock,
  DollarSign,
  MapPin,
  Shield,
  Sparkles,
  Users as UsersIcon,
  Zap,
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface SurveyLocation {
  code: string;
  name: string;
  category: string;
  note: string;
  region: 'Core 5 km ring' | 'Extended student trip';
}

interface Day {
  id: string;
  label: string;
  short: string;
}

interface TimeSlot {
  id: string;
  label: string;
  compact: string;
}

interface RespondentProfile {
  name: string;
  email: string;
  housing: string;
  year: string;
  cadence: string;
}

interface TripEntry {
  from: string;
  to: string;
  purpose: string;
  note: string;
  flexibility: 'Locked' | 'Flexible';
}

type TripDraft = TripEntry;
type EntryMap = Record<string, TripEntry>;

interface PersistedSurvey {
  entries?: EntryMap;
  respondent?: Partial<RespondentProfile>;
  submittedAt?: string | null;
}

const STORAGE_KEY = 'roamingos-ucd-commercial-research-v1';

const DAYS: Day[] = [
  { id: 'mon', label: 'Monday', short: 'Mon' },
  { id: 'tue', label: 'Tuesday', short: 'Tue' },
  { id: 'wed', label: 'Wednesday', short: 'Wed' },
  { id: 'thu', label: 'Thursday', short: 'Thu' },
  { id: 'fri', label: 'Friday', short: 'Fri' },
  { id: 'sat', label: 'Saturday', short: 'Sat' },
  { id: 'sun', label: 'Sunday', short: 'Sun' },
];

function formatHour(hour: number) {
  const normalized = hour % 24;
  const suffix = normalized < 12 ? 'AM' : 'PM';
  const display = normalized === 0 ? 12 : normalized > 12 ? normalized - 12 : normalized;
  return `${display}:00 ${suffix}`;
}

const TIME_SLOTS: TimeSlot[] = Array.from({ length: 16 }, (_, index) => {
  const hour = 8 + index;
  return {
    id: `${hour}:00`,
    label: `${formatHour(hour)} - ${formatHour(hour + 1)}`,
    compact: formatHour(hour),
  };
});

const LOCATION_CODES: SurveyLocation[] = [
  {
    code: '1',
    name: 'Home / Dorm',
    category: 'Personal anchor',
    note: 'Each student uses 1 for their own residence.',
    region: 'Core 5 km ring',
  },
  {
    code: '2',
    name: 'UC Davis Campus Core',
    category: 'Classes and labs',
    note: 'Lecture halls, library, Memorial Union, and study stops.',
    region: 'Core 5 km ring',
  },
  {
    code: '3',
    name: 'Safeway',
    category: 'Groceries',
    note: 'Everyday grocery run and household refill.',
    region: 'Core 5 km ring',
  },
  {
    code: '4',
    name: "Trader Joe's",
    category: 'Groceries',
    note: 'Short stock-up trip and prepared food stop.',
    region: 'Core 5 km ring',
  },
  {
    code: '5',
    name: 'Target',
    category: 'Essentials',
    note: 'Household goods, school supplies, and basics.',
    region: 'Core 5 km ring',
  },
  {
    code: '6',
    name: 'Downtown Davis',
    category: 'Food and social',
    note: 'Restaurants, errands, meetups, and casual shopping.',
    region: 'Core 5 km ring',
  },
  {
    code: '7',
    name: 'University Mall',
    category: 'Retail cluster',
    note: 'Food, quick services, and near-campus errands.',
    region: 'Core 5 km ring',
  },
  {
    code: '8',
    name: 'ARC / Gym',
    category: 'Fitness',
    note: 'Workout, recreation, and student wellness visits.',
    region: 'Core 5 km ring',
  },
  {
    code: '9',
    name: 'Davis Amtrak Station',
    category: 'Transit',
    note: 'Regional train trips and intercity connection point.',
    region: 'Core 5 km ring',
  },
  {
    code: '10',
    name: 'Sutter Davis / Clinic',
    category: 'Health',
    note: 'Appointments, pharmacy, and medical errands.',
    region: 'Core 5 km ring',
  },
  {
    code: '11',
    name: 'Nugget / Local Market',
    category: 'Groceries',
    note: 'Top-up purchases when students avoid large runs.',
    region: 'Core 5 km ring',
  },
  {
    code: '12',
    name: 'Cafe and Restaurant Cluster',
    category: 'Dining',
    note: 'Flexible code for food-focused trips around central Davis.',
    region: 'Core 5 km ring',
  },
  {
    code: '13',
    name: 'Costco',
    category: 'Bulk shopping',
    note: 'Kept as an extended code because students still mention it often.',
    region: 'Extended student trip',
  },
];

const LOCATION_LOOKUP: Record<string, SurveyLocation> = Object.fromEntries(
  LOCATION_CODES.map((location) => [location.code, location]),
);

const QUICK_ROUTES = [
  { label: 'Dorm -> Campus', from: '1', to: '2', purpose: 'Class commute' },
  { label: 'Dorm -> Safeway', from: '1', to: '3', purpose: 'Grocery run' },
  { label: 'Campus -> Downtown', from: '2', to: '6', purpose: 'Food or social stop' },
  { label: 'Dorm -> Gym', from: '1', to: '8', purpose: 'Workout trip' },
  { label: 'Dorm -> Costco', from: '1', to: '13', purpose: 'Bulk shopping' },
];

const EMPTY_PROFILE: RespondentProfile = {
  name: '',
  email: '',
  housing: 'North / West Davis',
  year: 'Undergraduate',
  cadence: 'Mixed weekly routine',
};

const EMPTY_DRAFT: TripDraft = {
  from: '1',
  to: '',
  purpose: '',
  note: '',
  flexibility: 'Flexible',
};

const FIELD_CLASS =
  'w-full rounded-2xl border border-[#d6cdbd] bg-white/85 px-4 py-3 text-sm text-[#1d342d] shadow-[inset_0_1px_0_rgba(255,255,255,0.7)] outline-none transition focus:border-[#558675] focus:ring-2 focus:ring-[#a7c8bb]/60';

function buildCellKey(dayId: string, slotId: string) {
  return `${dayId}__${slotId}`;
}

function parseCellKey(cellKey: string) {
  const [dayId, slotId] = cellKey.split('__');
  return { dayId, slotId };
}

function getEmptyDraft() {
  return { ...EMPTY_DRAFT };
}

function entryToDraft(entry?: TripEntry): TripDraft {
  return entry ? { ...entry } : getEmptyDraft();
}

function getLocationName(code: string) {
  return LOCATION_LOOKUP[code]?.name ?? `Code ${code}`;
}

function summarizeRoute(entry?: TripEntry) {
  return entry ? `${entry.from} -> ${entry.to}` : 'Add route';
}

function humanizeRoute(entry?: TripEntry) {
  if (!entry) {
    return 'Choose a route for this hour';
  }

  return `${getLocationName(entry.from)} -> ${getLocationName(entry.to)}`;
}

function countMostFrequent(values: string[]) {
  if (values.length === 0) {
    return null;
  }

  const counts = new Map<string, number>();

  values.forEach((value) => {
    counts.set(value, (counts.get(value) ?? 0) + 1);
  });

  let winner = values[0];
  let highest = 0;

  counts.forEach((count, value) => {
    if (count > highest) {
      winner = value;
      highest = count;
    }
  });

  return winner;
}

function sortRows(entries: EntryMap) {
  const dayIndex = Object.fromEntries(DAYS.map((day, index) => [day.id, index]));
  const slotIndex = Object.fromEntries(TIME_SLOTS.map((slot, index) => [slot.id, index]));

  return Object.entries(entries)
    .map(([cellKey, entry]) => {
      const { dayId, slotId } = parseCellKey(cellKey);
      return {
        cellKey,
        dayId,
        slotId,
        day: DAYS[dayIndex[dayId]],
        slot: TIME_SLOTS[slotIndex[slotId]],
        entry,
      };
    })
    .sort(
      (left, right) =>
        dayIndex[left.dayId] - dayIndex[right.dayId] ||
        slotIndex[left.slotId] - slotIndex[right.slotId],
    );
}

function getPlanPreview(totalTrips: number, extendedTrips: number) {
  if (totalTrips === 0) {
    return {
      tier: 'No estimate yet',
      price: 'Need 3+ planned movements',
      summary: 'Fill a few hours in the planner to surface a first-pass weekly price idea.',
      detail: 'We look at movement frequency, peak clustering, and distance mix before shaping a package.',
    };
  }

  if (totalTrips <= 6) {
    return {
      tier: 'Explorer pass',
      price: extendedTrips > 0 ? '$42 - $54 / week' : '$28 - $36 / week',
      summary: 'Best for light grocery, gym, and social trips.',
      detail: 'This looks like a lower-frequency schedule with flexibility between planned stops.',
    };
  }

  if (totalTrips <= 12) {
    return {
      tier: 'Routine pass',
      price: extendedTrips > 0 ? '$58 - $72 / week' : '$44 - $58 / week',
      summary: 'Fits students with recurring weekday movement and several errand loops.',
      detail: 'This is the sweet spot for a recurring weekly subscription with predictable pickup windows.',
    };
  }

  return {
    tier: 'Heavy-use pass',
    price: extendedTrips > 0 ? '$79 - $96 / week' : '$62 - $78 / week',
    summary: 'Designed for dense schedules with repeated campus and non-campus trips.',
    detail: 'A higher-use pattern suggests stronger weekly structure and tighter departure clustering.',
  };
}

function buildPayload(
  respondent: RespondentProfile,
  entries: EntryMap,
  submittedAt: string | null,
  planPreview: ReturnType<typeof getPlanPreview>,
) {
  return {
    surveyVersion: 'ucd-commercial-research-v1',
    geography: {
      center: 'UC Davis',
      primaryRadiusKm: 5,
      numberingRule: '1 = home / dorm',
      note: 'Extended codes can be added when students repeatedly mention trips outside the core ring.',
    },
    respondent,
    submittedAt,
    pricingPreview: {
      tier: planPreview.tier,
      weeklyRange: planPreview.price,
    },
    entries: sortRows(entries).map((row) => ({
      day: row.day.label,
      time: row.slot.label,
      fromCode: row.entry.from,
      fromName: getLocationName(row.entry.from),
      toCode: row.entry.to,
      toName: getLocationName(row.entry.to),
      purpose: row.entry.purpose,
      note: row.entry.note,
      flexibility: row.entry.flexibility,
    })),
  };
}

export default function App() {
  const [entries, setEntries] = useState<EntryMap>({});
  const [respondent, setRespondent] = useState<RespondentProfile>(EMPTY_PROFILE);
  const [submittedAt, setSubmittedAt] = useState<string | null>(null);
  const [activeCell, setActiveCell] = useState(buildCellKey(DAYS[0].id, TIME_SLOTS[0].id));
  const [draft, setDraft] = useState<TripDraft>(getEmptyDraft());
  const [storageReady, setStorageReady] = useState(false);
  const [copyState, setCopyState] = useState<'idle' | 'copied' | 'failed'>('idle');

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem(STORAGE_KEY);

      if (raw) {
        const parsed = JSON.parse(raw) as PersistedSurvey;
        setEntries(parsed.entries ?? {});
        setRespondent({
          ...EMPTY_PROFILE,
          ...parsed.respondent,
        });
        setSubmittedAt(parsed.submittedAt ?? null);
      }
    } catch {
      // Ignore malformed local drafts and continue with the default survey shell.
    }

    setStorageReady(true);
  }, []);

  useEffect(() => {
    if (!storageReady) {
      return;
    }

    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        entries,
        respondent,
        submittedAt,
      }),
    );
  }, [entries, respondent, storageReady, submittedAt]);

  const activeEntry = entries[activeCell];

  useEffect(() => {
    setDraft(entryToDraft(activeEntry));
  }, [activeCell, activeEntry]);

  useEffect(() => {
    if (copyState !== 'copied') {
      return;
    }

    const timeout = window.setTimeout(() => setCopyState('idle'), 2200);
    return () => window.clearTimeout(timeout);
  }, [copyState]);

  const sortedRows = sortRows(entries);
  const totalTrips = sortedRows.length;
  const destinationCodes = sortedRows
    .map((row) => row.entry.to)
    .filter((code) => code !== '1');
  const uniqueDestinations = new Set(destinationCodes).size;
  const topDestinationCode = countMostFrequent(destinationCodes);
  const topRouteKey = countMostFrequent(
    sortedRows.map((row) => `${row.entry.from}->${row.entry.to}`),
  );
  const busiestDayId = countMostFrequent(sortedRows.map((row) => row.dayId));
  const busiestSlotId = countMostFrequent(sortedRows.map((row) => row.slotId));
  const extendedTrips = sortedRows.filter(
    (row) =>
      LOCATION_LOOKUP[row.entry.from]?.region === 'Extended student trip' ||
      LOCATION_LOOKUP[row.entry.to]?.region === 'Extended student trip',
  ).length;
  const planPreview = getPlanPreview(totalTrips, extendedTrips);
  const payload = buildPayload(respondent, entries, submittedAt, planPreview);

  const activeDay = DAYS.find((day) => day.id === parseCellKey(activeCell).dayId) ?? DAYS[0];
  const activeSlot =
    TIME_SLOTS.find((slot) => slot.id === parseCellKey(activeCell).slotId) ?? TIME_SLOTS[0];

  const topRouteLabel = topRouteKey
    ? (() => {
        const [from, to] = topRouteKey.split('->');
        return `${from} -> ${to} · ${getLocationName(from)} to ${getLocationName(to)}`;
      })()
    : 'Not enough data yet';

  const busiestDayLabel =
    DAYS.find((day) => day.id === busiestDayId)?.label ?? 'Waiting for schedule data';
  const busiestTimeLabel =
    TIME_SLOTS.find((slot) => slot.id === busiestSlotId)?.label ?? 'Waiting for schedule data';

  function saveActiveSlot() {
    if (!draft.from || !draft.to) {
      return;
    }

    const nextEntry: TripEntry = {
      from: draft.from,
      to: draft.to,
      purpose: draft.purpose.trim() || 'General trip',
      note: draft.note.trim(),
      flexibility: draft.flexibility,
    };

    setEntries((current) => ({
      ...current,
      [activeCell]: nextEntry,
    }));
    setSubmittedAt(null);
  }

  function clearActiveSlot() {
    setEntries((current) => {
      const next = { ...current };
      delete next[activeCell];
      return next;
    });
    setDraft(getEmptyDraft());
    setSubmittedAt(null);
  }

  function applyQuickRoute(route: (typeof QUICK_ROUTES)[number]) {
    const quickEntry: TripEntry = {
      from: route.from,
      to: route.to,
      purpose: route.purpose,
      note: '',
      flexibility: 'Flexible',
    };

    setDraft(quickEntry);
    setEntries((current) => ({
      ...current,
      [activeCell]: quickEntry,
    }));
    setSubmittedAt(null);
  }

  function markSurveyReady() {
    setSubmittedAt(new Date().toISOString());
  }

  async function copyPayload() {
    try {
      await navigator.clipboard.writeText(JSON.stringify(payload, null, 2));
      setCopyState('copied');
    } catch {
      setCopyState('failed');
    }
  }

  return (
    <div className="relative min-h-screen overflow-hidden text-[#1b332c]">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-[-8%] top-0 h-[30rem] w-[30rem] rounded-full bg-[radial-gradient(circle,_rgba(154,193,175,0.55)_0%,_rgba(154,193,175,0)_70%)]" />
        <div className="absolute bottom-[-8rem] right-[-4rem] h-[28rem] w-[28rem] rounded-full bg-[radial-gradient(circle,_rgba(236,187,103,0.38)_0%,_rgba(236,187,103,0)_70%)]" />
      </div>

      <header className="sticky top-0 z-40 border-b border-[#d7ccb8]/80 bg-[#f8f2e7]/88 backdrop-blur-xl">
        <div className="mx-auto flex max-w-[1440px] items-center justify-between px-4 py-4 sm:px-6 lg:px-10">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#18463b] text-[#f4f0e6] shadow-[0_14px_30px_rgba(24,70,59,0.18)]">
              <Car className="h-5 w-5" />
            </div>
            <div>
              <p className="font-display text-lg font-semibold tracking-[0.02em] text-[#17362f]">
                RoamingOS
              </p>
              <p className="text-xs uppercase tracking-[0.28em] text-[#5d766d]">
                UC Davis Mobility Research
              </p>
            </div>
          </div>

          <nav className="hidden items-center gap-6 text-sm text-[#5b6f68] md:flex">
            <a href="#overview" className="transition hover:text-[#17362f]">
              Overview
            </a>
            <a href="#codes" className="transition hover:text-[#17362f]">
              Place Codes
            </a>
            <a href="#planner" className="transition hover:text-[#17362f]">
              Weekly Planner
            </a>
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-[1440px] px-4 pb-16 pt-8 sm:px-6 lg:px-10">
        <motion.section
          id="overview"
          className="paper-grid relative overflow-hidden rounded-[2rem] border border-[#d8cdb9] bg-[#f7f1e5]/90 px-6 py-8 shadow-[0_32px_90px_rgba(54,77,69,0.11)] sm:px-8 sm:py-10"
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: 'easeOut' }}
        >
          <div className="grid gap-10 xl:grid-cols-[1.05fr_0.95fr]">
            <div className="max-w-3xl">
              <div className="mb-5 flex flex-wrap gap-3">
                <span className="inline-flex items-center gap-2 rounded-full border border-[#c9d9cf] bg-[#edf4ef] px-4 py-2 text-xs font-semibold uppercase tracking-[0.22em] text-[#285647]">
                  <MapPin className="h-3.5 w-3.5" />
                  UC Davis + 5 km research zone
                </span>
                <span className="inline-flex items-center gap-2 rounded-full border border-[#e2d1a7] bg-[#fff5df] px-4 py-2 text-xs font-semibold uppercase tracking-[0.22em] text-[#8b5d19]">
                  <Clock className="h-3.5 w-3.5" />
                  8:00 AM to 12:00 AM weekly planner
                </span>
              </div>

              <h1 className="font-display text-[clamp(2.9rem,7vw,6.3rem)] leading-[0.92] tracking-[-0.04em] text-[#18372f]">
                Map where UC Davis students actually go before we price the network.
              </h1>

              <p className="mt-6 max-w-2xl text-base leading-8 text-[#516760] sm:text-lg">
                This prototype turns weekly travel plans into structured route codes. Students do
                not enter full addresses. They simply use <span className="font-semibold">1</span>{' '}
                for home or dorm, then fill each time block as{' '}
                <span className="font-semibold">from code -&gt; to code</span>. RoamingOS can then
                identify repeating movement patterns, peak windows, and the right early pricing
                bundles.
              </p>

              <div className="mt-8 grid gap-4 sm:grid-cols-3">
                <div className="rounded-[1.6rem] border border-[#d9cdb9] bg-white/70 p-5">
                  <p className="text-xs uppercase tracking-[0.22em] text-[#7a8b84]">Coding rule</p>
                  <p className="mt-3 text-3xl font-semibold text-[#17362f]">1</p>
                  <p className="mt-2 text-sm leading-6 text-[#596d66]">
                    Always means the student&apos;s own home or dorm.
                  </p>
                </div>
                <div className="rounded-[1.6rem] border border-[#d9cdb9] bg-white/70 p-5">
                  <p className="text-xs uppercase tracking-[0.22em] text-[#7a8b84]">Coverage</p>
                  <p className="mt-3 text-3xl font-semibold text-[#17362f]">7 x 16</p>
                  <p className="mt-2 text-sm leading-6 text-[#596d66]">
                    Seven days, sixteen active hourly slots per day.
                  </p>
                </div>
                <div className="rounded-[1.6rem] border border-[#d9cdb9] bg-white/70 p-5">
                  <p className="text-xs uppercase tracking-[0.22em] text-[#7a8b84]">Output</p>
                  <p className="mt-3 text-3xl font-semibold text-[#17362f]">V1</p>
                  <p className="mt-2 text-sm leading-6 text-[#596d66]">
                    Route pattern capture first, pricing engine second.
                  </p>
                </div>
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
              <div className="rounded-[2rem] bg-[#163f36] p-6 text-[#f4efe5] shadow-[0_28px_80px_rgba(22,63,54,0.26)]">
                <div className="flex items-center justify-between">
                  <p className="text-xs uppercase tracking-[0.24em] text-[#bcd4c8]">
                    Research outcome
                  </p>
                  <Sparkles className="h-5 w-5 text-[#f4cb7e]" />
                </div>
                <h2 className="font-display mt-5 text-3xl leading-tight tracking-[-0.03em]">
                  A survey that already thinks like operations software.
                </h2>
                <div className="mt-6 space-y-4 text-sm leading-7 text-[#d4e3db]">
                  <div className="flex gap-3">
                    <Shield className="mt-1 h-4 w-4 flex-none text-[#f4cb7e]" />
                    <p>Students reveal routines without giving exact home addresses.</p>
                  </div>
                  <div className="flex gap-3">
                    <ArrowRightLeft className="mt-1 h-4 w-4 flex-none text-[#f4cb7e]" />
                    <p>Every filled cell creates a directional signal we can aggregate later.</p>
                  </div>
                  <div className="flex gap-3">
                    <DollarSign className="mt-1 h-4 w-4 flex-none text-[#f4cb7e]" />
                    <p>The current page already estimates a first pricing tier from trip density.</p>
                  </div>
                </div>
              </div>

              <div className="rounded-[2rem] border border-[#d7ccb8] bg-white/72 p-6">
                <p className="text-xs uppercase tracking-[0.24em] text-[#6a7e76]">
                  Collection logic
                </p>
                <div className="mt-5 grid gap-4">
                  {[
                    {
                      icon: UsersIcon,
                      title: 'Student profile',
                      detail: 'Housing cluster, year, and weekly cadence.',
                    },
                    {
                      icon: BarChart3,
                      title: 'Weekly route map',
                      detail: 'Time-blocked plan from one code to another.',
                    },
                    {
                      icon: Zap,
                      title: 'Pricing preview',
                      detail: 'Early package idea based on movement frequency.',
                    },
                  ].map((item) => (
                    <div
                      key={item.title}
                      className="flex items-start gap-4 rounded-[1.4rem] border border-[#e2d8c9] bg-[#faf6ee] px-4 py-4"
                    >
                      <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#edf4ef] text-[#215245]">
                        <item.icon className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-[#18372f]">{item.title}</p>
                        <p className="mt-1 text-sm leading-6 text-[#62756e]">{item.detail}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </motion.section>

        <motion.section
          id="codes"
          className="mt-8 grid gap-6 lg:grid-cols-[0.9fr_1.1fr]"
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.55, ease: 'easeOut' }}
          viewport={{ once: true, amount: 0.2 }}
        >
          <div className="rounded-[2rem] border border-[#d7ccb8] bg-[#f5eee1]/85 p-6">
            <p className="text-xs uppercase tracking-[0.22em] text-[#6c8077]">How the system reads the sheet</p>
            <h2 className="font-display mt-4 text-4xl leading-tight tracking-[-0.03em] text-[#19362f]">
              Keep the student task simple. Keep the research output structured.
            </h2>
            <div className="mt-6 space-y-4 text-sm leading-7 text-[#596d66]">
              <div className="flex gap-3">
                <CheckCircle2 className="mt-1 h-4 w-4 flex-none text-[#2d6a59]" />
                <p>Students click a time slot and assign a route instead of typing free-form plans.</p>
              </div>
              <div className="flex gap-3">
                <CheckCircle2 className="mt-1 h-4 w-4 flex-none text-[#2d6a59]" />
                <p>Core codes cover the main 5 km ring around campus, while extended codes catch recurring student trips that fall outside the ring.</p>
              </div>
              <div className="flex gap-3">
                <CheckCircle2 className="mt-1 h-4 w-4 flex-none text-[#2d6a59]" />
                <p>When enough students fill the same windows, RoamingOS can compare frequency, clustering, and likely bundle value.</p>
              </div>
            </div>

            <div className="mt-8 rounded-[1.7rem] bg-[#173f36] p-5 text-[#eef3ec]">
              <p className="text-xs uppercase tracking-[0.24em] text-[#b7d1c5]">
                Quick reminder
              </p>
              <p className="mt-3 text-lg leading-8">
                The strict rule is <span className="font-semibold text-[#f6cc83]">1 = home</span>.
                Everything else is a destination code ranked for survey convenience, not a final product database.
              </p>
            </div>
          </div>

          <div className="rounded-[2rem] border border-[#d7ccb8] bg-white/76 p-6">
            <div className="flex flex-wrap items-end justify-between gap-4">
              <div>
                <p className="text-xs uppercase tracking-[0.22em] text-[#6c8077]">
                  Initial destination codebook
                </p>
                <h3 className="font-display mt-3 text-3xl tracking-[-0.03em] text-[#18372f]">
                  Core Davis destinations plus one extended code
                </h3>
              </div>
              <span className="rounded-full border border-[#d4cfbf] bg-[#f8f3e8] px-4 py-2 text-xs font-semibold uppercase tracking-[0.2em] text-[#7f7051]">
                Editable later
              </span>
            </div>

            <div className="mt-6 grid gap-3 md:grid-cols-2">
              {LOCATION_CODES.map((location) => (
                <div
                  key={location.code}
                  className={cn(
                    'rounded-[1.35rem] border px-4 py-4 transition',
                    location.region === 'Core 5 km ring'
                      ? 'border-[#d8d1c4] bg-[#faf7f0]'
                      : 'border-[#efdcb5] bg-[#fff6e5]',
                  )}
                >
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="text-xs uppercase tracking-[0.18em] text-[#788a83]">
                        Code {location.code}
                      </p>
                      <p className="mt-2 text-lg font-semibold text-[#17362f]">{location.name}</p>
                    </div>
                    <span className="rounded-full bg-[#edf4ef] px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.18em] text-[#2b6456]">
                      {location.category}
                    </span>
                  </div>
                  <p className="mt-3 text-sm leading-6 text-[#60726b]">{location.note}</p>
                  <p className="mt-3 text-[11px] uppercase tracking-[0.18em] text-[#8b7752]">
                    {location.region}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </motion.section>

        <motion.section
          id="planner"
          className="mt-8"
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.55, ease: 'easeOut' }}
          viewport={{ once: true, amount: 0.15 }}
        >
          <div className="mb-6 grid gap-4 lg:grid-cols-4">
            {[
              {
                label: 'Planned movements',
                value: totalTrips.toString().padStart(2, '0'),
                detail: 'Filled time slots across the week',
              },
              {
                label: 'Unique destinations',
                value: uniqueDestinations.toString().padStart(2, '0'),
                detail: 'Distinct non-home destination codes used',
              },
              {
                label: 'Busiest day',
                value: busiestDayLabel,
                detail: 'Current densest day in the draft schedule',
              },
              {
                label: 'Pricing preview',
                value: planPreview.tier,
                detail: planPreview.price,
              },
            ].map((metric) => (
              <div
                key={metric.label}
                className="rounded-[1.7rem] border border-[#d7ccb8] bg-[#f9f4e8]/88 p-5 shadow-[0_14px_30px_rgba(55,76,68,0.06)]"
              >
                <p className="text-xs uppercase tracking-[0.2em] text-[#74867f]">{metric.label}</p>
                <p className="mt-3 text-2xl font-semibold leading-tight text-[#17362f]">
                  {metric.value}
                </p>
                <p className="mt-2 text-sm leading-6 text-[#5d7169]">{metric.detail}</p>
              </div>
            ))}
          </div>

          <div className="grid gap-6 xl:grid-cols-[360px_minmax(0,1fr)]">
            <div className="space-y-6 xl:sticky xl:top-24 xl:self-start">
              <div className="rounded-[2rem] bg-[#173f36] p-6 text-[#f3efe5] shadow-[0_24px_70px_rgba(23,63,54,0.24)]">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs uppercase tracking-[0.24em] text-[#b6d0c4]">
                      Active time block
                    </p>
                    <h2 className="font-display mt-3 text-3xl tracking-[-0.03em]">
                      {activeDay.label}
                    </h2>
                  </div>
                  <div className="rounded-full border border-white/12 bg-white/8 px-3 py-2 text-sm text-[#d8e4dd]">
                    {activeSlot.label}
                  </div>
                </div>

                <div className="mt-6 grid gap-4">
                  <div>
                    <label className="mb-2 block text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                      From code
                    </label>
                    <select
                      className={cn(FIELD_CLASS, 'border-white/10 bg-white/92')}
                      value={draft.from}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          from: event.target.value,
                        }))
                      }
                    >
                      {LOCATION_CODES.map((location) => (
                        <option key={location.code} value={location.code}>
                          {location.code}. {location.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="mb-2 block text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                      To code
                    </label>
                    <select
                      className={cn(FIELD_CLASS, 'border-white/10 bg-white/92')}
                      value={draft.to}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          to: event.target.value,
                        }))
                      }
                    >
                      <option value="">Choose destination</option>
                      {LOCATION_CODES.filter((location) => location.code !== draft.from).map((location) => (
                        <option key={location.code} value={location.code}>
                          {location.code}. {location.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="mb-2 block text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                      Purpose
                    </label>
                    <input
                      className={cn(FIELD_CLASS, 'border-white/10 bg-white/92')}
                      value={draft.purpose}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          purpose: event.target.value,
                        }))
                      }
                      placeholder="Class commute, groceries, social, health..."
                    />
                  </div>

                  <div>
                    <label className="mb-2 block text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                      Notes
                    </label>
                    <textarea
                      className={cn(FIELD_CLASS, 'min-h-28 resize-none border-white/10 bg-white/92')}
                      value={draft.note}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          note: event.target.value,
                        }))
                      }
                      placeholder="Optional detail like returning after class, buying groceries, or meeting friends."
                    />
                  </div>
                </div>

                <div className="mt-5">
                  <p className="text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                    Flexibility
                  </p>
                  <div className="mt-3 grid grid-cols-2 gap-3">
                    {(['Locked', 'Flexible'] as const).map((choice) => (
                      <button
                        key={choice}
                        type="button"
                        onClick={() =>
                          setDraft((current) => ({
                            ...current,
                            flexibility: choice,
                          }))
                        }
                        className={cn(
                          'rounded-2xl border px-4 py-3 text-sm font-medium transition',
                          draft.flexibility === choice
                            ? 'border-[#f4cb7e] bg-[#f4cb7e] text-[#17362f]'
                            : 'border-white/12 bg-white/8 text-[#d6e3db] hover:bg-white/14',
                        )}
                      >
                        {choice}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="mt-6 rounded-[1.4rem] border border-white/10 bg-white/7 px-4 py-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                    Route preview
                  </p>
                  <p className="mt-2 text-lg font-semibold text-[#f7f1e4]">
                    {draft.to ? `${draft.from} -> ${draft.to}` : 'Choose a destination'}
                  </p>
                  <p className="mt-2 text-sm leading-6 text-[#d7e2dc]">
                    {draft.to
                      ? `${getLocationName(draft.from)} to ${getLocationName(draft.to)}`
                      : 'This hour is still empty and will not count toward pricing yet.'}
                  </p>
                </div>

                <div className="mt-6 flex flex-wrap gap-3">
                  <button
                    type="button"
                    onClick={saveActiveSlot}
                    className="inline-flex items-center gap-2 rounded-full bg-[#f4cb7e] px-5 py-3 text-sm font-semibold text-[#17362f] transition hover:bg-[#f0c15e]"
                  >
                    Save slot
                    <ChevronRight className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={clearActiveSlot}
                    className="inline-flex items-center gap-2 rounded-full border border-white/12 bg-white/8 px-5 py-3 text-sm font-semibold text-[#e4ede8] transition hover:bg-white/14"
                  >
                    Clear slot
                  </button>
                </div>

                <div className="mt-6">
                  <p className="text-xs uppercase tracking-[0.18em] text-[#b6d0c4]">
                    Quick route chips
                  </p>
                  <div className="mt-3 flex flex-wrap gap-2">
                    {QUICK_ROUTES.map((route) => (
                      <button
                        key={route.label}
                        type="button"
                        onClick={() => applyQuickRoute(route)}
                        className="rounded-full border border-white/12 bg-white/8 px-4 py-2 text-xs font-semibold uppercase tracking-[0.16em] text-[#d7e2dc] transition hover:bg-white/16"
                      >
                        {route.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="rounded-[2rem] border border-[#d7ccb8] bg-[#fbf6ed]/90 p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#eaf3ed] text-[#27594a]">
                    <UsersIcon className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-xs uppercase tracking-[0.2em] text-[#74867f]">
                      Student profile
                    </p>
                    <h3 className="font-display text-2xl tracking-[-0.03em] text-[#17362f]">
                      Minimal respondent context
                    </h3>
                  </div>
                </div>

                <div className="mt-5 grid gap-4">
                  <input
                    className={FIELD_CLASS}
                    value={respondent.name}
                    onChange={(event) =>
                      setRespondent((current) => ({
                        ...current,
                        name: event.target.value,
                      }))
                    }
                    placeholder="Student name (optional)"
                  />
                  <input
                    className={FIELD_CLASS}
                    type="email"
                    value={respondent.email}
                    onChange={(event) =>
                      setRespondent((current) => ({
                        ...current,
                        email: event.target.value,
                      }))
                    }
                    placeholder="Email (optional)"
                  />
                  <select
                    className={FIELD_CLASS}
                    value={respondent.housing}
                    onChange={(event) =>
                      setRespondent((current) => ({
                        ...current,
                        housing: event.target.value,
                      }))
                    }
                  >
                    {[
                      'North / West Davis',
                      'South Davis',
                      'Downtown Davis',
                      'Near campus housing',
                      'Other off-campus cluster',
                    ].map((option) => (
                      <option key={option} value={option}>
                        {option}
                      </option>
                    ))}
                  </select>
                  <select
                    className={FIELD_CLASS}
                    value={respondent.year}
                    onChange={(event) =>
                      setRespondent((current) => ({
                        ...current,
                        year: event.target.value,
                      }))
                    }
                  >
                    {['Undergraduate', 'Graduate', 'Exchange / Visiting', 'Staff / Other'].map(
                      (option) => (
                        <option key={option} value={option}>
                          {option}
                        </option>
                      ),
                    )}
                  </select>
                  <select
                    className={FIELD_CLASS}
                    value={respondent.cadence}
                    onChange={(event) =>
                      setRespondent((current) => ({
                        ...current,
                        cadence: event.target.value,
                      }))
                    }
                  >
                    {[
                      'Mixed weekly routine',
                      'Mostly class-driven',
                      'Errand-heavy',
                      'Social and weekend-heavy',
                    ].map((option) => (
                      <option key={option} value={option}>
                        {option}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="rounded-[2rem] border border-[#d7ccb8] bg-white/84 p-6">
                <div className="flex items-center justify-between gap-4">
                  <div>
                    <p className="text-xs uppercase tracking-[0.2em] text-[#74867f]">
                      Pricing and export
                    </p>
                    <h3 className="font-display mt-3 text-3xl tracking-[-0.03em] text-[#17362f]">
                      {planPreview.tier}
                    </h3>
                  </div>
                  <div className="rounded-full bg-[#eef5ef] px-4 py-2 text-sm font-semibold text-[#2b5b4d]">
                    {planPreview.price}
                  </div>
                </div>

                <p className="mt-4 text-sm leading-7 text-[#5c7068]">{planPreview.summary}</p>
                <p className="mt-3 text-sm leading-7 text-[#5c7068]">{planPreview.detail}</p>

                <div className="mt-6 rounded-[1.5rem] bg-[#f5efe2] p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-[#7b8865]">
                    Survey snapshot
                  </p>
                  <div className="mt-4 space-y-3 text-sm text-[#5a6e66]">
                    <div className="flex items-center justify-between gap-4">
                      <span>Top destination</span>
                      <span className="font-semibold text-[#18372f]">
                        {topDestinationCode
                          ? `${topDestinationCode}. ${getLocationName(topDestinationCode)}`
                          : 'Need more cells'}
                      </span>
                    </div>
                    <div className="flex items-center justify-between gap-4">
                      <span>Top route</span>
                      <span className="text-right font-semibold text-[#18372f]">
                        {topRouteLabel}
                      </span>
                    </div>
                    <div className="flex items-center justify-between gap-4">
                      <span>Busiest time</span>
                      <span className="text-right font-semibold text-[#18372f]">
                        {busiestTimeLabel}
                      </span>
                    </div>
                  </div>
                </div>

                {submittedAt ? (
                  <div className="mt-6 flex items-start gap-3 rounded-[1.5rem] border border-[#cde2d8] bg-[#edf7f1] px-4 py-4 text-sm text-[#2b5d50]">
                    <CheckCircle2 className="mt-0.5 h-5 w-5 flex-none" />
                    <div>
                      <p className="font-semibold">Survey marked ready for analysis</p>
                      <p className="mt-1 leading-6">
                        Saved on {new Date(submittedAt).toLocaleString()}.
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="mt-6 flex items-start gap-3 rounded-[1.5rem] border border-[#ecd8b2] bg-[#fff6e5] px-4 py-4 text-sm text-[#7d6030]">
                    <AlertCircle className="mt-0.5 h-5 w-5 flex-none" />
                    <div>
                      <p className="font-semibold">This is still a working draft</p>
                      <p className="mt-1 leading-6">
                        Mark it ready after filling the main weekly routes.
                      </p>
                    </div>
                  </div>
                )}

                <div className="mt-6 flex flex-wrap gap-3">
                  <button
                    type="button"
                    onClick={markSurveyReady}
                    className="inline-flex items-center gap-2 rounded-full bg-[#173f36] px-5 py-3 text-sm font-semibold text-[#f4efe5] transition hover:bg-[#204c41]"
                  >
                    Mark ready
                  </button>
                  <button
                    type="button"
                    onClick={copyPayload}
                    className="inline-flex items-center gap-2 rounded-full border border-[#d7ccb8] bg-[#f8f2e7] px-5 py-3 text-sm font-semibold text-[#17362f] transition hover:bg-[#f1ead9]"
                  >
                    Copy JSON payload
                  </button>
                </div>

                {copyState === 'copied' ? (
                  <p className="mt-3 text-sm font-medium text-[#2a604f]">
                    Payload copied. You can paste it into a CRM, sheet, or backend stub.
                  </p>
                ) : null}

                {copyState === 'failed' ? (
                  <p className="mt-3 text-sm font-medium text-[#8c5d22]">
                    Clipboard access failed in this browser session.
                  </p>
                ) : null}
              </div>
            </div>

            <div className="rounded-[2rem] border border-[#d7ccb8] bg-white/84 p-4 sm:p-6">
              <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
                <div>
                  <p className="text-xs uppercase tracking-[0.22em] text-[#74867f]">
                    Weekly route planner
                  </p>
                  <h2 className="font-display mt-3 text-4xl tracking-[-0.03em] text-[#17362f]">
                    One hour at a time, one route at a time
                  </h2>
                </div>
                <div className="rounded-full border border-[#ded1b6] bg-[#fff5df] px-4 py-2 text-xs font-semibold uppercase tracking-[0.18em] text-[#8a5c1a]">
                  Tap any cell to edit
                </div>
              </div>

              <div className="planner-scroll overflow-x-auto">
                <div className="min-w-[980px]">
                  <div className="grid grid-cols-[130px_repeat(7,minmax(110px,1fr))]">
                    <div className="sticky left-0 z-20 border-b border-[#e1d7c7] bg-[#fcf7ee] px-4 py-4 text-left text-xs font-semibold uppercase tracking-[0.2em] text-[#74867f]">
                      Time
                    </div>
                    {DAYS.map((day) => (
                      <div
                        key={day.id}
                        className="border-b border-[#e1d7c7] bg-[#fcf7ee] px-3 py-4 text-center"
                      >
                        <p className="text-xs uppercase tracking-[0.2em] text-[#74867f]">
                          {day.short}
                        </p>
                        <p className="mt-1 text-sm font-semibold text-[#17362f]">{day.label}</p>
                      </div>
                    ))}

                    {TIME_SLOTS.map((slot) => (
                      <React.Fragment key={slot.id}>
                        <div className="sticky left-0 z-10 border-b border-[#ece3d6] bg-[#faf6ee] px-4 py-4">
                          <p className="text-sm font-semibold text-[#17362f]">{slot.compact}</p>
                          <p className="mt-1 text-xs leading-5 text-[#72857d]">{slot.label}</p>
                        </div>

                        {DAYS.map((day) => {
                          const cellKey = buildCellKey(day.id, slot.id);
                          const entry = entries[cellKey];
                          const isActive = cellKey === activeCell;

                          return (
                            <button
                              key={cellKey}
                              type="button"
                              onClick={() => setActiveCell(cellKey)}
                              className={cn(
                                'group min-h-[88px] border-b border-l border-[#ece3d6] px-3 py-3 text-left transition',
                                isActive
                                  ? 'bg-[#edf4ef] shadow-[inset_0_0_0_2px_rgba(43,95,80,0.16)]'
                                  : 'bg-[#fffdf9] hover:bg-[#f7f1e6]',
                              )}
                            >
                              <p
                                className={cn(
                                  'text-sm font-semibold',
                                  entry ? 'text-[#17362f]' : 'text-[#80918a]',
                                )}
                              >
                                {summarizeRoute(entry)}
                              </p>
                              <p className="mt-2 line-clamp-2 text-xs leading-5 text-[#667971]">
                                {entry ? entry.purpose : 'Click to assign a route'}
                              </p>
                              <p className="mt-2 text-[11px] uppercase tracking-[0.18em] text-[#89a096] opacity-0 transition group-hover:opacity-100">
                                {isActive ? 'Editing now' : humanizeRoute(entry)}
                              </p>
                            </button>
                          );
                        })}
                      </React.Fragment>
                    ))}
                  </div>
                </div>
              </div>

              <div className="mt-6 grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
                <div className="rounded-[1.7rem] bg-[#f7f2e7] p-5">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#e9f2ec] text-[#29594c]">
                      <Building2 className="h-5 w-5" />
                    </div>
                    <div>
                      <p className="text-xs uppercase tracking-[0.18em] text-[#74867f]">
                        What this prototype can answer
                      </p>
                      <p className="text-lg font-semibold text-[#17362f]">
                        Early commercial questions, not routing precision yet
                      </p>
                    </div>
                  </div>
                  <div className="mt-4 grid gap-3 text-sm leading-7 text-[#5d7169] sm:grid-cols-2">
                    <p>Which destinations show up repeatedly around the same hours?</p>
                    <p>How much of demand lives inside the 5 km core versus outside it?</p>
                    <p>Which days deserve stronger subscription bundles or scheduled windows?</p>
                    <p>What patterns are stable enough to price before full backend automation?</p>
                  </div>
                </div>

                <div className="rounded-[1.7rem] border border-[#d8cdbb] bg-white p-5">
                  <p className="text-xs uppercase tracking-[0.18em] text-[#74867f]">
                    Payload preview
                  </p>
                  <pre className="mt-4 max-h-48 overflow-auto rounded-[1.3rem] bg-[#173f36] p-4 text-xs leading-6 text-[#d8e4de]">
                    {JSON.stringify(payload, null, 2)}
                  </pre>
                </div>
              </div>
            </div>
          </div>
        </motion.section>
      </main>
    </div>
  );
}
