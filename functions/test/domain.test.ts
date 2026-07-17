import { describe, expect, test } from "vitest";

import {
  canonicalEventKey,
  isCanonicalFirebaseDownloadUrl,
  parseModerationRequest,
  requireDocumentId,
  requireStableParkId,
} from "../src/domain";

describe("canonicalEventKey", () => {
  test("is deterministic, path-safe, and separates event kinds", () => {
    const key = canonicalEventKey("vote-created", "event/with:unsafe chars");
    expect(key).toMatch(/^vote-created_[a-f0-9]{64}$/);
    expect(key).toBe(
      canonicalEventKey("vote-created", "event/with:unsafe chars"),
    );
    expect(key).not.toBe(
      canonicalEventKey("vote-deleted", "event/with:unsafe chars"),
    );
  });

  test("rejects a missing event ID", () => {
    expect(() => canonicalEventKey("vote-created", "")).toThrow();
  });
});

describe("document IDs", () => {
  test("accepts bounded slash-free IDs", () => {
    expect(requireDocumentId("abc_123-XYZ", "id")).toBe("abc_123-XYZ");
  });

  test("rejects path injection and oversized IDs", () => {
    expect(() => requireDocumentId("one/two", "id")).toThrow();
    expect(() => requireDocumentId("x".repeat(129), "id")).toThrow();
    expect(() => requireDocumentId(null, "id")).toThrow();
  });
});

describe("requireStableParkId", () => {
  test("accepts canonical stable IDs without deriving from display names", () => {
    expect(requireStableParkId("lumpini")).toBe("lumpini");
    expect(requireStableParkId("rama-9-park")).toBe("rama-9-park");
  });

  test("rejects missing, localized, and malformed values", () => {
    expect(() => requireStableParkId(undefined)).toThrow();
    expect(() => requireStableParkId("สวนลุมพินี")).toThrow();
    expect(() => requireStableParkId("Unknown Park")).toThrow();
  });
});

describe("parseModerationRequest", () => {
  test("normalizes a valid request", () => {
    expect(
      parseModerationRequest({
        sightingId: "sighting-1",
        status: "rejected",
        rejectionReason: "  duplicate  ",
      }),
    ).toEqual({
      sightingId: "sighting-1",
      status: "rejected",
      rejectionReason: "duplicate",
    });
  });

  test.each([null, undefined, [], "bad", 4])(
    "rejects malformed payload %j",
    (payload) => {
      expect(() => parseModerationRequest(payload)).toThrow();
    },
  );

  test("rejects invalid IDs, unsupported fields, and invalid statuses", () => {
    expect(() =>
      parseModerationRequest({ sightingId: "a/b", status: "approved" }),
    ).toThrow();
    expect(() =>
      parseModerationRequest({
        sightingId: "a",
        status: "approved",
        extra: true,
      }),
    ).toThrow();
    expect(() =>
      parseModerationRequest({ sightingId: "a", status: "pending" }),
    ).toThrow();
  });

  test("bounds rejection reasons", () => {
    expect(() =>
      parseModerationRequest({
        sightingId: "a",
        status: "rejected",
        rejectionReason: "x".repeat(501),
      }),
    ).toThrow(/500/);
  });

  test("requires a reason only for rejection", () => {
    expect(() =>
      parseModerationRequest({ sightingId: "a", status: "rejected" }),
    ).toThrow(/required/);
    expect(() =>
      parseModerationRequest({
        sightingId: "a",
        status: "approved",
        rejectionReason: "not needed",
      }),
    ).toThrow(/not allowed/);
  });
});

describe("isCanonicalFirebaseDownloadUrl", () => {
  const bucket = "toem-here.appspot.com";
  const objectPath = "sightings/user-1/sighting-1/photo.jpg";
  const encodedPath = encodeURIComponent(objectPath);

  test("accepts the exact HTTPS Firebase bucket and decoded object path", () => {
    expect(
      isCanonicalFirebaseDownloadUrl(
        `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodedPath}?alt=media&token=abc`,
        bucket,
        objectPath,
      ),
    ).toBe(true);
  });

  test.each([
    `http://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodedPath}?alt=media`,
    `https://evil.example/v0/b/${bucket}/o/${encodedPath}?alt=media`,
    `https://firebasestorage.googleapis.com/v0/b/other.appspot.com/o/${encodedPath}?alt=media`,
    `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodeURIComponent("sightings/other/photo.jpg")}?alt=media`,
    `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodedPath}`,
  ])("rejects an unbound URL: %s", (url) => {
    expect(isCanonicalFirebaseDownloadUrl(url, bucket, objectPath)).toBe(false);
  });

  test("rejects malformed and non-string values", () => {
    expect(isCanonicalFirebaseDownloadUrl("not a url", bucket, objectPath)).toBe(
      false,
    );
    expect(isCanonicalFirebaseDownloadUrl(null, bucket, objectPath)).toBe(false);
  });
});
