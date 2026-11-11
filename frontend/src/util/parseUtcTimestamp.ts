/**
 * Parse a timestamp sent by the backend as UTC.
 *
 * The Postgres columns (jobs.created_at/started_at/finished_at,
 * result_videos.created_at, workers.last_activity) are `timestamp without time
 * zone`, filled with `current_timestamp` on a server running in UTC. The API
 * therefore sends naive ISO strings such as "2026-11-11T10:00:00.123456" with no
 * "Z" or offset, and `new Date(str)` would read them as the browser's LOCAL time,
 * shifting every value by the viewer's UTC offset (e.g. elapsed times starting at
 * "1h 0m 0s" in UTC+1).
 *
 * Strings that already carry "Z" or a "+hh:mm"/"-hh:mm" offset are left as-is.
 */
export const parseUtcTimestamp = (value: string): Date => {
    let iso = value.trim().replace(' ', 'T');

    // JS Date only guarantees millisecond precision; Python sends microseconds.
    iso = iso.replace(/(\.\d{3})\d+/, '$1');

    const hasZone = /(Z|[+-]\d{2}:?\d{2})$/i.test(iso);
    return new Date(hasZone ? iso : `${iso}Z`);
};

export const parseOptionalUtcTimestamp = (value: string | null | undefined): Date | undefined =>
    value ? parseUtcTimestamp(value) : undefined;
