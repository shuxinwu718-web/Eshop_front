import { defineStore } from "pinia";
import { ref } from "vue";
import { useRouter, useRoute } from "vue-router";

export interface TagView {
  name: string;
  title?: string;
  path: string;
  fullPath: string;
  affix?: boolean;
  keepAlive?: boolean;
  query?: any;
}

export const useTagsViewStore = defineStore("tagsView", () => {
  const visitedViews = ref<TagView[]>([]);
  const cachedViews = ref<string[]>([]);
  const router = useRouter();
  const route = useRoute();

  function addVisitedView(view: TagView) {
    if (view.path.startsWith("/redirect")) return;
    if (visitedViews.value.some((v) => v.path === view.path)) return;
    if (view.affix) {
      visitedViews.value.unshift(view);
    } else {
      visitedViews.value.push(view);
    }
  }

  // 关键修改：使用 name 作为缓存标识
  function addCachedView(view: TagView) {
    // console.log('addCachedView called:', view.name, view.keepAlive);
    const { name, keepAlive } = view;
    if (!name || !keepAlive) return;
    if (cachedViews.value.includes(name)) return;
    cachedViews.value.push(name);
    // console.log('cachedViews now:', cachedViews.value);
  }

  function delVisitedView(view: TagView) {
    return new Promise((resolve) => {
      const index = visitedViews.value.findIndex((v) => v.path === view.path);
      if (index !== -1) visitedViews.value.splice(index, 1);
      resolve([...visitedViews.value]);
    });
  }

  function delCachedView(view: TagView) {
    const { name } = view;
    if (!name) return Promise.resolve([...cachedViews.value]);
    const index = cachedViews.value.indexOf(name);
    if (index !== -1) cachedViews.value.splice(index, 1);
    return Promise.resolve([...cachedViews.value]);
  }

  function delOtherVisitedViews(view: TagView) {
    return new Promise((resolve) => {
      visitedViews.value = visitedViews.value.filter((v) => v.affix || v.path === view.path);
      resolve([...visitedViews.value]);
    });
  }

  function delOtherCachedViews(view: TagView) {
    const { name } = view;
    if (!name) {
      cachedViews.value = [];
      return Promise.resolve([...cachedViews.value]);
    }
    const index = cachedViews.value.indexOf(name);
    if (index !== -1) {
      cachedViews.value = cachedViews.value.slice(index, index + 1);
    } else {
      cachedViews.value = [];
    }
    return Promise.resolve([...cachedViews.value]);
  }

  function updateVisitedView(view: TagView) {
    const target = visitedViews.value.find((v) => v.path === view.path);
    if (target) Object.assign(target, view);
  }

  function updateTagName(fullPath: string, title: string) {
    const tag = visitedViews.value.find((t) => t.fullPath === fullPath);
    if (tag) tag.title = title;
  }

  function addView(view: TagView) {
    addVisitedView(view);
    addCachedView(view);
  }

  function delView(view: TagView) {
    return new Promise((resolve) => {
      delVisitedView(view);
      delCachedView(view);
      resolve({ visitedViews: [...visitedViews.value], cachedViews: [...cachedViews.value] });
    });
  }

  function delOtherViews(view: TagView) {
    return new Promise((resolve) => {
      delOtherVisitedViews(view);
      delOtherCachedViews(view);
      resolve({ visitedViews: [...visitedViews.value], cachedViews: [...cachedViews.value] });
    });
  }

  function delLeftViews(view: TagView) {
    return new Promise((resolve) => {
      const currIndex = visitedViews.value.findIndex((v) => v.path === view.path);
      if (currIndex === -1) return;
      const newVisited: TagView[] = [];
      for (let i = 0; i < visitedViews.value.length; i++) {
        const item = visitedViews.value[i];
        if (i >= currIndex || item.affix) {
          newVisited.push(item);
        } else {
          const cacheIndex = cachedViews.value.indexOf(item.name);
          if (cacheIndex !== -1) cachedViews.value.splice(cacheIndex, 1);
        }
      }
      visitedViews.value = newVisited;
      resolve({ visitedViews: [...visitedViews.value] });
    });
  }

  function delRightViews(view: TagView) {
    return new Promise((resolve) => {
      const currIndex = visitedViews.value.findIndex((v) => v.path === view.path);
      if (currIndex === -1) return;
      const newVisited: TagView[] = [];
      for (let i = 0; i < visitedViews.value.length; i++) {
        const item = visitedViews.value[i];
        if (i <= currIndex || item.affix) {
          newVisited.push(item);
        } else {
          const cacheIndex = cachedViews.value.indexOf(item.name);
          if (cacheIndex !== -1) cachedViews.value.splice(cacheIndex, 1);
        }
      }
      visitedViews.value = newVisited;
      resolve({ visitedViews: [...visitedViews.value] });
    });
  }

  function delAllViews() {
    return new Promise((resolve) => {
      const affixTags = visitedViews.value.filter((tag) => tag.affix);
      visitedViews.value = affixTags;
      cachedViews.value = [];
      resolve({ visitedViews: [...visitedViews.value], cachedViews: [...cachedViews.value] });
    });
  }

  function delAllVisitedViews() {
    return new Promise((resolve) => {
      const affixTags = visitedViews.value.filter((tag) => tag.affix);
      visitedViews.value = affixTags;
      resolve([...visitedViews.value]);
    });
  }

  function delAllCachedViews() {
    return new Promise((resolve) => {
      cachedViews.value = [];
      resolve([...cachedViews.value]);
    });
  }

  function closeCurrentView() {
    const tags: TagView = {
      name: route.name as string,
      title: route.meta.title as string,
      path: route.path,
      fullPath: route.fullPath,
      affix: route.meta?.affix,
      keepAlive: route.meta?.keepAlive,
      query: route.query,
    };
    delView(tags).then((res: any) => {
      if (isActive(tags)) toLastView(res.visitedViews, tags);
    });
  }

  function isActive(tag: TagView) {
    return tag.path === route.path;
  }

  function toLastView(visitedViews: TagView[], view?: TagView) {
    const latestView = visitedViews.slice(-1)[0];
    if (latestView?.fullPath) {
      router.push(latestView.fullPath);
    } else {
      if (view?.name === "Dashboard") {
        router.replace("/redirect" + view.fullPath);
      } else {
        router.push("/");
      }
    }
  }

  return {
    visitedViews,
    cachedViews,
    addVisitedView,
    addCachedView,
    delVisitedView,
    delCachedView,
    delOtherVisitedViews,
    delOtherCachedViews,
    updateVisitedView,
    addView,
    delView,
    delOtherViews,
    delLeftViews,
    delRightViews,
    delAllViews,
    delAllVisitedViews,
    delAllCachedViews,
    closeCurrentView,
    isActive,
    toLastView,
    updateTagName,
  };
});
