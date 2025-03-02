public class Timer {

  int savedTime;
  int totalTime;
  int currentTime;

  public Timer(int durationInMillis) {
    totalTime = durationInMillis; // PREDETERMINADO
  }

  public void setDuration(int _duration) {
    totalTime = _duration;
  }

  public void setDurationInSeconds(int _durationInSeconds) {
    totalTime = _durationInSeconds * 1000;
  }

  public void start() {
    savedTime = millis();
  }

  public boolean isFinished() {
    currentTime = millis() - savedTime;
    return currentTime > totalTime;
  }

  public int getTotalTime() {
    return totalTime;
  }

  public int getTotalTimeInSeconds() {
      return (int)(totalTime / 1000);
    }

  public int getCurrentTime() {
    return currentTime;
  }

  public int getCurrentTimeInSeconds() {
      return (int)(currentTime / 1000);
    }
}
