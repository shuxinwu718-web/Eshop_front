<template>
  <div class="conversations-page">
    <ConversationChat :as-merchant="true" />
  </div>
</template>

<script setup lang="ts">
import ConversationChat from "@/views/chat/ConversationChat.vue";
</script>

<style scoped>
.conversations-page {
  height: 100%;
  min-height: 0;
}
</style>
