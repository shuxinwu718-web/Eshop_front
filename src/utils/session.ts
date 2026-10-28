import { ref } from "vue";
import { Storage } from "./storage";
import { STORAGE_KEYS } from "@/constants";

export type SessionEndReason = "expired" | "invalid" | "replaced" | "logout";
const END_EVENT = "eshop:session-ended";
const readToken = () =>
  Storage.get<boolean>(STORAGE_KEYS.REMEMBER_ME, false)
    ? Storage.get<string>(STORAGE_KEYS.ACCESS_TOKEN, "")
    : Storage.sessionGet<string>(STORAGE_KEYS.ACCESS_TOKEN, "");
export const sessionToken = ref(readToken());
const listeners = new Set<(reason: SessionEndReason) => void>();
const requests = new Set<AbortController>();
let expiryTimer: ReturnType<typeof setTimeout> | undefined;
let initialized = false;

// Non-secret correlation key, used only to match logout events across tabs.
function sessionKey(token: string): string {
  let a = 2166136261,
    b = 5381;
  for (const c of token) {
    a = Math.imul(a ^ c.charCodeAt(0), 16777619);
    b = Math.imul(b, 33) ^ c.charCodeAt(0);
  }
  return `${token.length}:${a >>> 0}:${b >>> 0}`;
}
export function expiresAt(token: string): number | undefined {
  try {
    const payload = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    const exp = JSON.parse(atob(payload)).exp;
    return typeof exp === "number" && Number.isFinite(exp) ? exp * 1000 : undefined;
  } catch {
    return undefined;
  }
}
function armExpiry() {
  clearTimeout(expiryTimer);
  const token = sessionToken.value;
  const deadline = expiresAt(token);
  if (!token || deadline === undefined) return;
  expiryTimer = setTimeout(
    () => {
      if (Date.now() >= deadline) invalidateSession(token, "expired");
      else armExpiry();
    },
    Math.max(0, Math.min(deadline - Date.now(), 2_147_483_647))
  );
}
export function setSessionTokens(token: string, rememberMe: boolean) {
  // Cancel old-session work before a different account/session is installed.
  if (sessionToken.value !== token) abortSessionRequests();
  Storage.set(STORAGE_KEYS.REMEMBER_ME, rememberMe);
  if (rememberMe) {
    Storage.set(STORAGE_KEYS.ACCESS_TOKEN, token);
    Storage.sessionRemove(STORAGE_KEYS.ACCESS_TOKEN);
  } else {
    Storage.sessionSet(STORAGE_KEYS.ACCESS_TOKEN, token);
    Storage.remove(STORAGE_KEYS.ACCESS_TOKEN);
  }
  sessionToken.value = token;
  armExpiry();
}
export function clearSessionTokens() {
  clearTimeout(expiryTimer);
  // Another tab may already have installed a different remembered session.
  // Ending this tab's old session must not erase that new credential.
  const persisted = Storage.get<string>(STORAGE_KEYS.ACCESS_TOKEN, "");
  if (!persisted || persisted === sessionToken.value) {
    Storage.remove(STORAGE_KEYS.ACCESS_TOKEN);
    Storage.remove(STORAGE_KEYS.REMEMBER_ME);
  }
  Storage.sessionRemove(STORAGE_KEYS.ACCESS_TOKEN);
  sessionToken.value = "";
  abortSessionRequests();
}
function abortSessionRequests() {
  requests.forEach((c) => c.abort());
  requests.clear();
}
export function sessionRequest() {
  const controller = new AbortController();
  requests.add(controller);
  return { controller, release: () => requests.delete(controller) };
}
export function invalidateSession(
  expectedToken: string,
  reason: SessionEndReason = "invalid",
  broadcast = true
): boolean {
  if (!expectedToken || expectedToken !== sessionToken.value) return false;
  clearSessionTokens();
  // No token or personal information is sent through localStorage.
  if (broadcast) {
    try {
      localStorage.setItem(
        END_EVENT,
        JSON.stringify({ key: sessionKey(expectedToken), reason, at: Date.now() })
      );
    } catch {
      /* Local cleanup still completes if cross-tab delivery is unavailable. */
    }
  }
  listeners.forEach((listener) => listener(reason));
  return true;
}
export function onSessionEnded(listener: (reason: SessionEndReason) => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}
export function checkSessionExpiry(): boolean {
  const token = sessionToken.value;
  const deadline = expiresAt(token);
  if (token && deadline !== undefined && Date.now() >= deadline) {
    invalidateSession(token, "expired");
    return false;
  }
  return !!token;
}
export function setupSessionLifecycle() {
  if (initialized) return;
  initialized = true;
  window.addEventListener("focus", checkSessionExpiry);
  document.addEventListener("visibilitychange", () => {
    if (!document.hidden) checkSessionExpiry();
  });
  window.addEventListener("storage", (event) => {
    if (event.key !== END_EVENT || !event.newValue) return;
    try {
      const data = JSON.parse(event.newValue);
      if (data.key === sessionKey(sessionToken.value))
        invalidateSession(sessionToken.value, data.reason, false);
    } catch {
      /* Ignore unrelated/malformed cross-tab events. */
    }
  });
  checkSessionExpiry();
  armExpiry();
}
