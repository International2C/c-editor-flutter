import 'pvz_models.dart';
import 'wave_point_analysis.dart';

/// Point prediction for the LevelEscalationModuleProperties module.
class LevelEscalationPointAnalysis {
  /// Fallback flag cadence when WavesPerFlag is not configured (mirrors the
  /// Wave Manager's flagWaveInterval fallback).
  static const int fallbackWavesPerFlag = 10;

  static int totalWaves(LevelEscalationModuleData data) => data.totalWaves;

  static int flagInterval(LevelEscalationModuleData data) =>
      data.wavesPerFlag <= 0 ? fallbackWavesPerFlag : data.wavesPerFlag;

  static bool isFlagWave(LevelEscalationModuleData data, int waveNumber) {
    if (waveNumber < 1) return false;
    final total = totalWaves(data);
    if (total > 0 && waveNumber == total) return true;
    return waveNumber % flagInterval(data) == 0;
  }

  /// Point budget of a 1-based [waveNumber]: the same progression the Wave
  /// Manager uses (cap before the flag multiplier, flag waves times 2.5).
  static int pointsAtWave(LevelEscalationModuleData data, int waveNumber) {
    if (waveNumber < 1) return 0;
    var basePoints =
        data.startingPoints + (waveNumber - 1) * data.pointIncrementPerWave;
    if (basePoints > WavePointAnalysis.basePointCap) {
      basePoints = WavePointAnalysis.basePointCap;
    }
    if (basePoints < 0) basePoints = 0;
    return isFlagWave(data, waveNumber)
        ? (basePoints * 2.5).toInt()
        : basePoints;
  }

  /// Expected zombie counts of the module pool for one wave, including pool
  /// zombies whose WavePointCost data is missing.
  static WaveExpectation expectationAtWave(
    LevelEscalationModuleData data,
    int waveNumber,
  ) {
    return WavePointAnalysis.analyzePool(
      data.zombiePool,
      pointsAtWave(data, waveNumber),
    );
  }
}
