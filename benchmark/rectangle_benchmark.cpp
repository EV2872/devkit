#include <benchmark/benchmark.h>

#include "devkit/rectangle.hpp"

namespace {

void BM_RectangleConstruction(benchmark::State& state) {
    for (auto _ : state) {
        devkit::Rectangle rectangle(3.0, 4.0);
        benchmark::DoNotOptimize(rectangle);
    }
}
BENCHMARK(BM_RectangleConstruction);

void BM_RectangleArea(benchmark::State& state) {
    const devkit::Rectangle kRectangle(3.0, 4.0);
    for (auto _ : state) {
        benchmark::DoNotOptimize(kRectangle.Area());
    }
}
BENCHMARK(BM_RectangleArea);

}  // namespace

//BENCHMARK_MAIN();