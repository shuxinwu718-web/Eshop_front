// E-Shop UI 评审报告图表脚本
(function () {
  const style = getComputedStyle(document.documentElement);
  const accent = style.getPropertyValue("--accent").trim();
  const accent2 = style.getPropertyValue("--accent2").trim();
  const ink = style.getPropertyValue("--ink").trim();
  const muted = style.getPropertyValue("--muted").trim();
  const rule = style.getPropertyValue("--rule").trim();
  const bg2 = style.getPropertyValue("--bg2").trim();

  // --- 雷达图：C 端 / B 端六维评分 ---
  const radar = echarts.init(document.getElementById("chart-radar"), null, { renderer: "svg" });
  radar.setOption({
    animation: false,
    tooltip: { trigger: "item", appendToBody: true },
    legend: {
      data: ["C 端商城", "B 端后台"],
      textStyle: { color: ink, fontSize: 12 },
      bottom: 0,
    },
    radar: {
      indicator: [
        { name: "视觉一致性", max: 10 },
        { name: "品牌辨识度", max: 10 },
        { name: "交互反馈", max: 10 },
        { name: "可用性/信息架构", max: 10 },
        { name: "响应式适配", max: 10 },
        { name: "视觉层次/密度", max: 10 },
      ],
      radius: "62%",
      splitArea: { show: false },
      axisName: { color: muted, fontSize: 12 },
      splitLine: { lineStyle: { color: rule } },
      axisLine: { lineStyle: { color: rule } },
    },
    series: [
      {
        type: "radar",
        data: [
          {
            name: "C 端商城",
            value: [7.5, 6.0, 6.5, 6.5, 6.8, 6.0],
            areaStyle: { opacity: 0.18 },
            lineStyle: { color: accent, width: 2 },
            itemStyle: { color: accent },
          },
          {
            name: "B 端后台",
            value: [7.0, 4.5, 5.5, 6.0, 6.5, 5.5],
            areaStyle: { opacity: 0.12 },
            lineStyle: { color: accent2, width: 2 },
            itemStyle: { color: accent2 },
          },
        ],
      },
    ],
  });
  window.addEventListener("resize", function () {
    radar.resize();
  });
})();
