const EARTH_RADIUS_M = 6_371_000;

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/**
 * Haversine 距離（公尺）。
 */
export function haversineMeters(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(a));
}

/**
 * 以中心點與半徑（公尺）計算經緯度 bounding box，
 * 供 SQL 先做粗過濾，再以 Haversine 精算。
 */
export function boundingBox(
  lat: number,
  lng: number,
  radiusM: number,
): { minLat: number; maxLat: number; minLng: number; maxLng: number } {
  const latDelta = (radiusM / EARTH_RADIUS_M) * (180 / Math.PI);
  const lngDelta =
    (radiusM / (EARTH_RADIUS_M * Math.cos(toRad(lat)))) * (180 / Math.PI);
  return {
    minLat: lat - latDelta,
    maxLat: lat + latDelta,
    minLng: lng - lngDelta,
    maxLng: lng + lngDelta,
  };
}
