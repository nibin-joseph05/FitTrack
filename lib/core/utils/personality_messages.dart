import 'motivation_utils.dart';

class PersonalityMessages {
  static String greeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'Up at this hour, $name? Either dedicated or insane. Both work.';
    } else if (hour < 12) {
      return 'Morning, $name. Let\'s see what you\'ve got today.';
    } else if (hour < 17) {
      return 'Afternoon, $name. Hope you haven\'t been sitting all day.';
    } else if (hour < 21) {
      return 'Evening session, $name? The best ones happen now.';
    } else {
      return 'Late night grind, $name? Respect. Or get some sleep. Dealer\'s choice.';
    }
  }

  static String weeklyGoalMissed(String name, int goal, int actual) {
    return 'You said $goal days, $name. You showed up $actual. That gap has a name — it\'s called excuses.';
  }

  static String weeklyGoalMet(String name, int days) {
    return 'All $days days, $name. That\'s not luck. That\'s discipline. Rare trait.';
  }

  static String weeklyGoalAhead(String name, int actual, int goal) {
    return '$actual out of $goal already, $name. You\'re not even done yet. Savage.';
  }

  static String workoutLogged(String name) {
    final messages = [
      'Another one in the books, $name. That\'s how you do it.',
      'Workout logged, $name. Your future self is nodding silently.',
      'Done, $name. That session counted. So does the next one.',
      'Nice work, $name. That\'s how progress is made — one rep at a time.',
      'Logged, $name. Now eat. Sleep. Repeat.',
      'Well done, $name. The excuses said no. You said yes.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String weightLoggedFrequently(String name) {
    return 'Checking your weight again, $name? Relax. Progress takes weeks, not hours. Put the scale down.';
  }

  static String weightLogged(String name, double weight) {
    final messages = [
      'Logged ${weight.toStringAsFixed(1)}kg, $name. Numbers don\'t lie.',
      '${weight.toStringAsFixed(1)}kg recorded, $name. Keep tracking, keep growing.',
      'Weight saved, $name. The graph is building itself. Keep feeding it.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String noWorkoutToday(String name) {
    final messages = [
      'No workout today, $name? The iron misses you.',
      'Rest day or lazy day, $name? Be honest.',
      'Today\'s workout status: skipped. That\'s on you, $name.',
      'The gym called, $name. You didn\'t answer.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String workoutToday(String name) {
    final messages = [
      'Already trained today, $name. Good. The rest of the day is yours.',
      'Workout done, $name. The work is behind you. Walk tall.',
      'You showed up today, $name. That\'s half the battle won.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String attendanceCheckedIn(String name) {
    final messages = [
      'Checked in, $name. Love to see it.',
      'You made it today, $name. Some people didn\'t. Remember that.',
      'Present, $name. Your commitment is showing.',
      'Another day, another check-in. You\'re on a roll, $name.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Late night';
    }
  }

  static String progressCelebration(String name) {
    final messages = [
      'You\'re moving, $name. Don\'t stop now.',
      'Look at you, $name. Actually doing the thing.',
      'Solid progress, $name. The lazy version of you is sweating just watching.',
      'Keep stacking those wins, $name.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  static String dailyQuoteWithName(String name) {
    final quote = MotivationUtils.getTodayQuote();
    return '"$quote" — Today\'s reminder for you, $name.';
  }

  static String skipWarning(String name) {
    return 'Don\'t skip today, $name. Yesterday\'s you would be disappointed.';
  }

  static String newPR(String name, String exercise, double weight) {
    return 'NEW PR, $name! $exercise at ${weight.toStringAsFixed(1)}kg. That\'s genuine progress.';
  }
}
