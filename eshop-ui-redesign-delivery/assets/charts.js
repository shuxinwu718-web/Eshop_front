(function () {
  const style = getComputedStyle(document.documentElement);
  const accent = style.getPropertyValue("--accent").trim();
  const accent2 = style.getPropertyValue("--accent2").trim();
  const ink = style.getPropertyValue("--ink").trim();
  const muted = style.getPropertyValue("--muted").trim();
  const rule = style.getPropertyValue("--rule").trim();
  const bg2 = style.getPropertyValue("--bg2").trim();

  // --- Chart: 动效时长对比（优化后 vs 框架默认） ---
  const chart = echarts.init(document.getElementById("chart-motion"), null, { renderer: "svg" });
  chart.setOption({
    animation: false,
    tooltip: {
      trigger: "axis",
      appendToBody: true,
      axisPointer: { type: "shadow" },
      formatter(p) {
        const v = p[0].value;
        return p[0].name + "：<b>" + v + "ms</b>";
      },
    },
    grid: { left: 110, right: 40, top: 20, bottom: 30 },
    xAxis: {
      type: "value",
      max: 350,
      axisLine: { lineStyle: { color: rule } },
      axisLabel: { color: muted },
      splitLine: { lineStyle: { color: rule } },
    },
    yAxis: {
      type: "category",
      data: ["页面切换过渡", "商品卡入场淡入", "抽屉滑入（优化后）", "抽屉滑入（默认）"],
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { color: ink },
    },
    series: [
      {
        type: "bar",
        data: [120, 200, 200, 300],
        barWidth: 22,
        itemStyle: {
          color(p) {
            return p.name === "抽屉滑入（默认）" ? muted : accent;
          },
          borderRadius: [0, 6, 6, 0],
        },
        label: {
          show: true,
          position: "right",
          color: muted,
          formatter: "{c}ms",
        },
      },
    ],
  });
  window.addEventListener("resize", function () {
    chart.resize();
  });
})();
