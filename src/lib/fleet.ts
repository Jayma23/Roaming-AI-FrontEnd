export const FLEET_SIZE = 8;
export const MAX_WAITLIST = 2;

export interface Booking {
  id: string;
  vehicleId: number; // 1–8 for confirmed, 0 for waitlist (no vehicle assigned yet)
  dayId: string;
  startMinutes: number; // minutes from midnight (e.g. 10:30 → 630)
  durationMinutes: number;
  fromCode: string;
  toCode: string;
  status: 'confirmed' | 'waitlist';
}

export type AvailabilityStatus = 'available' | 'waitlist' | 'unavailable';

export interface SlotAvailability {
  status: AvailabilityStatus;
  vehiclesFree: number;
  waitlistCount: number;
}

function overlaps(s1: number, d1: number, s2: number, d2: number): boolean {
  return s1 < s2 + d2 && s2 < s1 + d1;
}

/** Check how many vehicles are free and how many are on the waitlist for a given time window. */
export function getSlotAvailability(
  bookings: Booking[],
  dayId: string,
  startMinutes: number,
  durationMinutes: number,
): SlotAvailability {
  const dayBookings = bookings.filter((b) => b.dayId === dayId);

  const usedVehicles = new Set(
    dayBookings
      .filter(
        (b) =>
          b.status === 'confirmed' &&
          overlaps(startMinutes, durationMinutes, b.startMinutes, b.durationMinutes),
      )
      .map((b) => b.vehicleId),
  );

  const waitlistCount = dayBookings.filter(
    (b) =>
      b.status === 'waitlist' &&
      overlaps(startMinutes, durationMinutes, b.startMinutes, b.durationMinutes),
  ).length;

  const vehiclesFree = FLEET_SIZE - usedVehicles.size;

  if (vehiclesFree > 0) return { status: 'available', vehiclesFree, waitlistCount };
  if (waitlistCount < MAX_WAITLIST) return { status: 'waitlist', vehiclesFree: 0, waitlistCount };
  return { status: 'unavailable', vehiclesFree: 0, waitlistCount };
}

/**
 * Creates a confirmed or waitlist booking.
 * Returns null if the slot is completely unavailable.
 */
export function createBooking(
  bookings: Booking[],
  dayId: string,
  startMinutes: number,
  durationMinutes: number,
  fromCode: string,
  toCode: string,
): { booking: Booking; updatedBookings: Booking[] } | null {
  const avail = getSlotAvailability(bookings, dayId, startMinutes, durationMinutes);
  if (avail.status === 'unavailable') return null;

  const id = `bk_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;

  if (avail.status === 'available') {
    const usedVehicles = new Set(
      bookings
        .filter(
          (b) =>
            b.dayId === dayId &&
            b.status === 'confirmed' &&
            overlaps(startMinutes, durationMinutes, b.startMinutes, b.durationMinutes),
        )
        .map((b) => b.vehicleId),
    );
    let vehicleId = 1;
    while (usedVehicles.has(vehicleId)) vehicleId++;

    const booking: Booking = {
      id, vehicleId, dayId, startMinutes, durationMinutes, fromCode, toCode, status: 'confirmed',
    };
    return { booking, updatedBookings: [...bookings, booking] };
  }

  // Waitlist
  const booking: Booking = {
    id, vehicleId: 0, dayId, startMinutes, durationMinutes, fromCode, toCode, status: 'waitlist',
  };
  return { booking, updatedBookings: [...bookings, booking] };
}

/** Remove a booking by id. */
export function cancelBooking(bookings: Booking[], bookingId: string): Booking[] {
  return bookings.filter((b) => b.id !== bookingId);
}
