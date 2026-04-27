// One-way travel times in minutes between Davis, CA location codes
// Index = code - 1 (code 1 → index 0, code 13 → index 12)
const TIMES: number[][] = [
  //  1   2   3   4   5   6   7   8   9  10  11  12  13
  [   0,  8, 10,  9,  9, 11,  7,  8, 13, 11,  9, 10, 22], // 1  Home / Dorm
  [   8,  0, 12, 10, 10,  8,  5,  6, 12, 10, 10,  8, 20], // 2  UC Davis Campus Core
  [  10, 12,  0,  4,  5, 10,  9, 13, 14,  5,  7, 11, 15], // 3  Safeway
  [   9, 10,  4,  0,  4,  9,  8, 11, 12,  5,  6, 10, 16], // 4  Trader Joe's
  [   9, 10,  5,  4,  0, 10,  8, 12, 12,  5,  6, 10, 16], // 5  Target
  [  11,  8, 10,  9, 10,  0,  7,  9,  5,  9,  8,  3, 18], // 6  Downtown Davis
  [   7,  5,  9,  8,  8,  7,  0,  7, 10,  8,  8,  7, 18], // 7  University Mall
  [   8,  6, 13, 11, 12,  9,  7,  0, 12, 11, 10,  9, 22], // 8  ARC / Gym
  [  13, 12, 14, 12, 12,  5, 10, 12,  0, 10, 10,  5, 18], // 9  Davis Amtrak Station
  [  11, 10,  5,  5,  5,  9,  8, 11, 10,  0,  5,  9, 15], // 10 Sutter Davis / Clinic
  [   9, 10,  7,  6,  6,  8,  8, 10, 10,  5,  0,  8, 17], // 11 Nugget / Local Market
  [  10,  8, 11, 10, 10,  3,  7,  9,  5,  9,  8,  0, 18], // 12 Cafe & Restaurant Cluster
  [  22, 20, 15, 16, 16, 18, 18, 22, 18, 15, 17, 18,  0], // 13 Costco
];

/** Returns estimated one-way travel time in minutes between two location codes. */
export function getTravelTime(fromCode: string, toCode: string): number {
  const from = parseInt(fromCode, 10) - 1;
  const to = parseInt(toCode, 10) - 1;
  if (from < 0 || from >= 13 || to < 0 || to >= 13) return 15;
  return TIMES[from][to];
}

/**
 * Rounds up travel time to the nearest 15-minute increment.
 * Minimum block is 15 minutes.
 */
export function getBlockDuration(travelMinutes: number): number {
  return Math.max(15, Math.ceil(travelMinutes / 15) * 15);
}

/**
 * Returns the fraction (0–1) of a 60-minute grid cell covered by the trip block.
 * cellSlotIndex is the row index of the cell; activeSlotIndex is the row index
 * where the block starts; blockDurationMinutes is the total block length.
 */
export function getCellBlockFraction(
  cellSlotIndex: number,
  activeSlotIndex: number,
  blockDurationMinutes: number,
): number {
  const relIndex = cellSlotIndex - activeSlotIndex;
  if (relIndex < 0) return 0;
  const cellStartMin = relIndex * 60;
  const cellEndMin = cellStartMin + 60;
  if (cellStartMin >= blockDurationMinutes) return 0;
  if (cellEndMin <= blockDurationMinutes) return 1;
  return (blockDurationMinutes - cellStartMin) / 60;
}
