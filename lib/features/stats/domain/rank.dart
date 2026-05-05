class RankInfo {
  const RankInfo(this.name, this.next, this.progress);
  final String name;
  final int? next;
  final double progress;
}

const ranks = <({String name, int min})>[
  (name: 'Bronze III', min: 0),
  (name: 'Bronze II', min: 10),
  (name: 'Bronze I', min: 20),
  (name: 'Silver III', min: 35),
  (name: 'Silver II', min: 55),
  (name: 'Silver I', min: 80),
  (name: 'Gold III', min: 100),
  (name: 'Gold II', min: 150),
  (name: 'Gold I', min: 200),
  (name: 'Diamond III', min: 250),
  (name: 'Diamond II', min: 350),
  (name: 'Diamond I', min: 450),
  (name: 'Master', min: 600),
];

RankInfo rankFor(int total) {
  var stage = 0;
  for (var i = 0; i < ranks.length; i++) {
    if (total >= ranks[i].min) stage = i;
  }
  final next = stage == ranks.length - 1 ? null : ranks[stage + 1].min;
  final progress = next == null
      ? 1.0
      : ((total - ranks[stage].min) / (next - ranks[stage].min))
            .clamp(0, 1)
            .toDouble();
  return RankInfo(ranks[stage].name, next, progress);
}
