// src/hooks/useDict.ts
import { ref } from "vue";
import DictAPI from "@/api/system/dict";
import type { DictItemOption } from "@/types/api";

const dictCache = new Map<string, DictItemOption[]>();

export function useDict(typeCode: string) {
  const data = ref<DictItemOption[]>([]);
  const loading = ref(false);
  const loaded = ref(false);

  const getDictData = async () => {
    if (dictCache.has(typeCode)) {
      data.value = dictCache.get(typeCode) ?? [];
      loaded.value = true;
      return;
    }

    loading.value = true;
    try {
      const res = await DictAPI.getDictItems(typeCode);
      data.value = res ?? [];
      dictCache.set(typeCode, data.value);
      loaded.value = true;
    } finally {
      loading.value = false;
    }
  };

  getDictData();

  return { data, loading, loaded };
}
