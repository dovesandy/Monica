<template>
  <div>
    <CommonHeader />
    <ElementTabs />
  </div>
</template>
<script>
import CommonHeader from "@/components/CommonHeader";
import ElementTabs from "@/components/ElementTabs";
export default {
  name: "test",
  components: { CommonHeader, ElementTabs },
  data() {
    return {
      // activeIndex: "1"
    };
  },
  methods: {
    handleSelect(key, keyPath) {
      console.log(key, keyPath);
    }
  }
};
</script>