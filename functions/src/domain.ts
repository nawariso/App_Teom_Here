import { createHash } from "node:crypto";

export type VoteEventKind = "vote-created" | "vote-deleted";
export type ModerationStatus = "approved" | "rejected";

export interface ModerationRequest {
  sightingId: string;
  status: ModerationStatus;
  rejectionReason?: string;
}

export function canonicalEventKey(
  kind: VoteEventKind,
  eventId: string,
): string {
  if (eventId.length < 1) {
    throw new Error("An event ID is required for idempotency.");
  }
  const digest = createHash("sha256").update(eventId, "utf8").digest("hex");
  return `${kind}_${digest}`;
}

export function requireDocumentId(value: unknown, fieldName: string): string {
  if (
    typeof value !== "string" ||
    value.length < 1 ||
    value.length > 128 ||
    value.includes("/") ||
    value === "." ||
    value === ".."
  ) {
    throw new Error(`${fieldName} must be a valid document ID.`);
  }
  return value;
}

export function requireStableParkId(value: unknown): string {
  if (
    typeof value !== "string" ||
    value.length < 1 ||
    value.length > 80 ||
    !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value)
  ) {
    throw new Error("A canonical parkId is required.");
  }
  return value;
}

export function parseModerationRequest(data: unknown): ModerationRequest {
  if (
    typeof data !== "object" ||
    data === null ||
    Array.isArray(data)
  ) {
    throw new Error("The request payload must be an object.");
  }

  const payload = data as Record<string, unknown>;
  const allowedKeys = new Set(["sightingId", "status", "rejectionReason"]);
  if (Object.keys(payload).some((key) => !allowedKeys.has(key))) {
    throw new Error("The request contains unsupported fields.");
  }

  const sightingId = requireDocumentId(payload.sightingId, "sightingId");
  if (payload.status !== "approved" && payload.status !== "rejected") {
    throw new Error("status must be approved or rejected.");
  }

  if (
    payload.rejectionReason !== undefined &&
    typeof payload.rejectionReason !== "string"
  ) {
    throw new Error("rejectionReason must be a string when provided.");
  }

  const rejectionReason = (payload.rejectionReason as string | undefined)?.trim();
  if (rejectionReason !== undefined && rejectionReason.length > 500) {
    throw new Error("rejectionReason must not exceed 500 characters.");
  }
  if (payload.status === "rejected" && !rejectionReason) {
    throw new Error("rejectionReason is required when rejecting a sighting.");
  }
  if (payload.status === "approved" && rejectionReason) {
    throw new Error("rejectionReason is not allowed when approving a sighting.");
  }

  return {
    sightingId,
    status: payload.status,
    rejectionReason: rejectionReason || undefined,
  };
}

export function isCanonicalFirebaseDownloadUrl(
  photoUrl: unknown,
  expectedBucket: string,
  expectedStoragePath: string,
): photoUrl is string {
  if (
    typeof photoUrl !== "string" ||
    photoUrl.length < 1 ||
    photoUrl.length > 2048 ||
    expectedBucket.length < 1 ||
    expectedStoragePath.length < 1
  ) {
    return false;
  }

  try {
    const url = new URL(photoUrl);
    if (
      url.protocol !== "https:" ||
      url.hostname !== "firebasestorage.googleapis.com" ||
      url.port !== "" ||
      url.username !== "" ||
      url.password !== "" ||
      url.hash !== "" ||
      url.searchParams.get("alt") !== "media"
    ) {
      return false;
    }

    const match = /^\/v0\/b\/([^/]+)\/o\/([^/]+)$/.exec(url.pathname);
    if (!match) {
      return false;
    }

    return (
      decodeURIComponent(match[1]) === expectedBucket &&
      decodeURIComponent(match[2]) === expectedStoragePath
    );
  } catch {
    return false;
  }
}
