// Executes the real TypeScript session and interceptor modules with isolated storage/transport.
// No server, account, or production credential is needed.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const ts = require("typescript");
const vue = require("vue");
function fixture() {
  const local = new Map(),
    session = new Map(),
    events = {},
    timers = new Map();
  let now = 100000,
    nextTimer = 0;
  const keys = { ACCESS_TOKEN: "token", REMEMBER_ME: "remember" };
  const read = (map, k, d) => (map.has(k) ? JSON.parse(map.get(k)) : d);
  const storage = {
    get: (k, d) => read(local, k, d),
    set: (k, v) => local.set(k, JSON.stringify(v)),
    remove: (k) => local.delete(k),
    sessionGet: (k, d) => read(session, k, d),
    sessionSet: (k, v) => session.set(k, JSON.stringify(v)),
    sessionRemove: (k) => session.delete(k),
  };
  const messages = [],
    handlers = {};
  const axios = require("axios");
  const axiosMock = {
    ...axios,
    create: () => ({
      interceptors: {
        request: {
          use(fn) {
            handlers.request = fn;
          },
        },
        response: {
          use(ok, bad) {
            handlers.ok = ok;
            handlers.bad = bad;
          },
        },
      },
    }),
  };
  const modules = {
    vue: vue,
    "./storage": { Storage: storage },
    "@/constants": { STORAGE_KEYS: keys },
    axios: { ...axiosMock, default: axiosMock },
    qs: { default: { stringify() {} } },
    "element-plus": {
      ElLoading: { service: () => ({ close() {} }) },
      ElMessage: { error: (m) => messages.push(m), warning: (m) => messages.push(m) },
    },
  };
  const context = {
    console,
    AbortController,
    AbortSignal,
    atob,
    DOMException,
    Response,
    TextDecoder,
    ref: vue.ref,
    computed: vue.computed,
    readonly: vue.readonly,
    Date: class extends Date {
      static now() {
        return now;
      }
    },
    setTimeout: (fn, ms) => {
      timers.set(++nextTimer, { fn, at: now + ms });
      return nextTimer;
    },
    clearTimeout: (id) => timers.delete(id),
    localStorage: { setItem: (k, v) => local.set(k, v) },
    window: { addEventListener: (name, fn) => (events[name] = fn) },
    document: { hidden: false, addEventListener: (name, fn) => (events[name] = fn) },
  };
  function load(file) {
    const output = {};
    const source = fs
      .readFileSync(file, "utf8")
      .replaceAll("import.meta.env.VITE_APP_BASE_API", '"/test-api"');
    vm.runInNewContext(
      ts.transpileModule(source, {
        compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
      }).outputText,
      {
        ...context,
        exports: output,
        require: (name) => {
          assert.ok(modules[name], name);
          return modules[name];
        },
      }
    );
    return output;
  }
  const state = load("src/utils/session.ts");
  modules["./session"] = state;
  modules["@/utils/session"] = state;
  modules["@/utils/auth"] = { AuthStorage: { getAccessToken: () => state.sessionToken.value } };
  load("src/utils/request.ts");
  const config = () => handlers.request({ url: "/api/orders", headers: {} });
  return {
    state,
    local,
    session,
    events,
    handlers,
    messages,
    config,
    load,
    setContext: (k, v) => (context[k] = v),
    advance(ms) {
      now += ms;
      for (const [id, t] of [...timers])
        if (t.at <= now) {
          timers.delete(id);
          t.fn();
        }
    },
    jwt: (exp) => "x." + Buffer.from(JSON.stringify({ exp })).toString("base64url") + ".x",
  };
}
test("login state is reactive and concurrent invalidation happens only once", () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  const logged = vue.computed(() => !!f.state.sessionToken.value);
  assert.equal(logged.value, true);
  let ended = 0;
  f.state.onSessionEnded(() => ended++);
  f.state.invalidateSession("one");
  f.state.invalidateSession("one");
  assert.equal(logged.value, false);
  assert.equal(ended, 1);
});
test("expires at the JWT deadline without any API request", () => {
  const f = fixture();
  f.state.setSessionTokens(f.jwt(102), false);
  f.advance(1999);
  assert.ok(f.state.sessionToken.value);
  f.advance(1);
  assert.equal(f.state.sessionToken.value, "");
});
test("focus check detects a deadline missed while browser is suspended", () => {
  const f = fixture();
  f.state.setupSessionLifecycle();
  f.state.setSessionTokens(f.jwt(99), false);
  f.events.focus();
  assert.equal(f.state.sessionToken.value, "");
});
test("401 expires login even on a public page", async () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  const config = f.config();
  await assert.rejects(
    f.handlers.bad({ config, response: { status: 401, data: { msg: "expired" } } })
  );
  assert.equal(f.state.sessionToken.value, "");
});
test("403 and 500 do not log out a valid session", async () => {
  for (const status of [403, 500]) {
    const f = fixture();
    f.state.setSessionTokens("one", false);
    await assert.rejects(f.handlers.bad({ config: f.config(), response: { status, data: {} } }));
    assert.equal(f.state.sessionToken.value, "one");
  }
});
test("HTTP 200 with application code 401 expires the associated session", async () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  await assert.rejects(f.handlers.ok({ config: f.config(), data: { code: 401 } }));
  assert.equal(f.state.sessionToken.value, "");
});
test("late 401 and success responses cannot affect a new login", async () => {
  const f = fixture();
  f.state.setSessionTokens("old", false);
  const config = f.config();
  f.state.setSessionTokens("new", false);
  await assert.rejects(f.handlers.bad({ config, response: { status: 401, data: {} } }));
  assert.throws(() => f.handlers.ok({ config, data: { code: 200, data: { username: "old" } } }));
  assert.equal(f.state.sessionToken.value, "new");
  assert.equal(f.messages.length, 0);
});
test("network and cancellation errors preserve the login", async () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  await assert.rejects(f.handlers.bad({ config: f.config() }));
  assert.equal(f.state.sessionToken.value, "one");
});
test("same-session logout is broadcast without placing the token in the message", () => {
  const a = fixture(),
    b = fixture();
  a.state.setSessionTokens("same-secret-token", false);
  b.state.setSessionTokens("same-secret-token", false);
  b.state.setupSessionLifecycle();
  a.state.invalidateSession("same-secret-token");
  const message = a.local.get("eshop:session-ended");
  assert.ok(!message.includes("same-secret-token"));
  b.events.storage({ key: "eshop:session-ended", newValue: message });
  assert.equal(b.state.sessionToken.value, "");
  b.state.setSessionTokens("another-session", false);
  b.events.storage({ key: "eshop:session-ended", newValue: message });
  assert.equal(b.state.sessionToken.value, "another-session");
});
test("in-flight requests are aborted when authentication ends", () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  const pending = f.state.sessionRequest();
  f.state.invalidateSession("one");
  assert.equal(pending.controller.signal.aborted, true);
});
test("login endpoints cannot invalidate a current session on a bad-password 401", async () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  const config = f.handlers.request({ url: "/api/user/login", headers: {} });
  assert.equal(config.headers.Authorization, undefined);
  await assert.rejects(f.handlers.bad({ config, response: { status: 401, data: {} } }));
  assert.equal(f.state.sessionToken.value, "one");
});

test("ending an old tab does not remove a newer remembered session", () => {
  const f = fixture();
  f.state.setSessionTokens("old", false);
  f.local.set("token", JSON.stringify("new"));
  f.local.set("remember", "true");
  f.state.invalidateSession("old");
  assert.equal(JSON.parse(f.local.get("token")), "new");
  assert.equal(JSON.parse(f.local.get("remember")), true);
});

test("SSE authentication event closes the connection and invalidates the session", () => {
  const f = fixture();
  let instance,
    closed = false;
  f.setContext(
    "EventSource",
    class {
      constructor() {
        instance = this;
        this.listeners = {};
      }
      addEventListener(n, fn) {
        this.listeners[n] = fn;
      }
      close() {
        closed = true;
      }
    }
  );
  f.state.setSessionTokens("one", false);
  const sse = f.load("src/composables/sse/useSse.ts").useSse();
  sse.connect();
  instance.onopen();
  instance.listeners["auth-expired"]({});
  assert.equal(closed, true);
  assert.equal(f.state.sessionToken.value, "");
  sse.cleanup();
});
test("an SSE network error retries with backoff without ending the login", () => {
  const f = fixture();
  let instances = [];
  f.setContext(
    "EventSource",
    class {
      constructor() {
        instances.push(this);
      }
      addEventListener() {}
      close() {}
    }
  );
  f.state.setSessionTokens("one", false);
  const sse = f.load("src/composables/sse/useSse.ts").useSse();
  sse.connect();
  instances[0].onerror();
  assert.equal(f.state.sessionToken.value, "one");
  f.advance(1000);
  assert.equal(instances.length, 2);
  sse.cleanup();
});
test("provider key 401 remains AI-only; explicit user-auth 401 expires login", async () => {
  for (const authCode of ["PROVIDER_KEY_INVALID", "TOKEN_EXPIRED"]) {
    const f = fixture();
    f.state.setSessionTokens("one", false);
    f.setContext("fetch", async () => new Response(JSON.stringify({ authCode }), { status: 401 }));
    const ai = f.load("src/api/ai/chat.ts");
    await assert.rejects(ai.sendAiChatStream("test", [], "one", { onDelta() {} }));
    assert.equal(f.state.sessionToken.value, authCode === "TOKEN_EXPIRED" ? "" : "one");
  }
});
test("cancelling an AI stream suppresses late output and completion callbacks", async () => {
  const f = fixture();
  f.state.setSessionTokens("one", false);
  let readResolve;
  f.setContext("fetch", async () => ({
    ok: true,
    body: {
      getReader: () => ({
        read: () => new Promise((resolve) => (readResolve = resolve)),
        cancel: async () => {},
      }),
    },
  }));
  const ai = f.load("src/api/ai/chat.ts");
  let callbacks = 0;
  const pending = ai.sendAiChatStream("test", [], "one", {
    onDelta() {
      callbacks++;
    },
    onDone() {
      callbacks++;
    },
    onError() {
      callbacks++;
    },
  });
  await new Promise((resolve) => setImmediate(resolve));
  f.state.invalidateSession("one");
  readResolve({ done: false, value: new TextEncoder().encode('data: {"delta":"late"}\n\n') });
  await assert.rejects(pending);
  assert.equal(callbacks, 0);
});
