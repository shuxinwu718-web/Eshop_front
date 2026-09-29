<template>
  <div class="message-page">
    <ConversationChat :as-merchant="false" />
  </div>
</template>

<script setup lang="ts">
import ConversationChat from "@/views/chat/ConversationChat.vue";
</script>

<style scoped>
.message-page {
  height: 100%;
  min-height: 0;
  padding: 12px;
}
</style>
