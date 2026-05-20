// src/hooks/useDict.ts
import { ref } from "vue";

const dictCache = new Map();

export function useDict(typeCode: string) {
  const data = ref([]);
  const loading = ref(false);
  const loaded = ref(false);

  const getDictData = async () => {
    if (dictCache.has(typeCode)) {
      data.value = dictCache.get(typeCode);
      loaded.value = true;
      return;
    }

    loading.value = true;
    try {
      const res = await dictApi.getDictByType(typeCode);
      data.value = res;
      dictCache.set(typeCode, res);
      loaded.value = true;
    } finally {
      loading.value = false;
    }
  };

  getDictData();

  return { data, loading, loaded };
}
