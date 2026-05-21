enum SubscriptionTier {
  free, premium, vip;

  bool get canCustomize => this != SubscriptionTier.free;

  int get dailyRequestLimit {
    switch (this) {
      case SubscriptionTier.free: return 5;
      case SubscriptionTier.premium: return 50;
      case SubscriptionTier.vip: return 999999;
    }
  }

  bool operator >=(SubscriptionTier other) => index >= other.index;
}
