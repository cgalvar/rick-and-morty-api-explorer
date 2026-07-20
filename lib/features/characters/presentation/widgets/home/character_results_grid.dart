part of 'package:soriana_character_explorer/features/characters/presentation/pages/home_page.dart';

class _AnimatedResultsGrid extends StatefulWidget {
  const _AnimatedResultsGrid({
    super.key,
    required this.items,
    required this.query,
    required this.status,
    required this.loading,
    required this.loadingMore,
    required this.paginationError,
    required this.loadingStates,
    required this.onLoadMore,
    required this.onRetry,
    required this.onOpen,
    required this.columns,
  });

  final List<Character> items;
  final String query;
  final CharacterStatus? status;
  final bool loading;
  final bool loadingMore;
  final String? paginationError;
  final Stream<bool> loadingStates;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final ValueChanged<Character> onOpen;
  final int columns;

  @override
  State<_AnimatedResultsGrid> createState() => _AnimatedResultsGridState();
}

class _AnimatedResultsGridState extends State<_AnimatedResultsGrid> {
  List<Character> _activeItems = const [];
  String _activeQuery = '';
  CharacterStatus? _activeStatus;
  _ResultsSnapshot? _pendingReplacement;
  bool _wasLoading = false;
  bool _isExiting = false;
  Timer? _exitTimer;
  late final StreamSubscription<bool> _loadingSubscription;

  @override
  void initState() {
    super.initState();
    _adopt(_snapshot);
    // The reset identity and loading state can be coalesced into one widget
    // update, so observe the complete visual loading lifecycle as well.
    _loadingSubscription = widget.loadingStates.listen((loading) {
      if (!loading) return;
      _wasLoading = true;
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _loadingSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AnimatedResultsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _snapshot;
    if (widget.loading) {
      _wasLoading = true;
      if (_isExiting && !_sameIdentity(next)) {
        // A newer intent arrived before the queued replacement became visible.
        // Let the already-running exit finish into an empty grid instead.
        _pendingReplacement = null;
      }
      return;
    }

    // A filter/search reset first changes its identity while retaining the
    // previous items, then enters loading. Keep that completed set in place
    // until its replacement has arrived.
    if (_wasLoading) {
      _wasLoading = false;
      if (_sameIdentity(next)) {
        _adopt(next);
        return;
      }
      _replaceAfterExit(next);
      return;
    }
    if (_sameIdentity(next)) {
      _adopt(next);
    }
  }

  _ResultsSnapshot get _snapshot => _ResultsSnapshot(
    items: widget.items,
    query: widget.query,
    status: widget.status,
  );

  void _replaceAfterExit(_ResultsSnapshot next) {
    if (_activeItems.isEmpty || MediaQuery.disableAnimationsOf(context)) {
      _exitTimer?.cancel();
      _pendingReplacement = null;
      _isExiting = false;
      _adopt(next);
      return;
    }

    // A later request may complete while this list is leaving. Keep only its
    // newest completed value so an obsolete result can never reappear.
    _pendingReplacement = next;
    if (_isExiting) return;

    _isExiting = true;
    _exitTimer = Timer(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      final replacement = _pendingReplacement;
      setState(() {
        _pendingReplacement = null;
        _isExiting = false;
        if (replacement == null) {
          _activeItems = const [];
        } else {
          _adopt(replacement);
        }
      });
    });
  }

  void _adopt(_ResultsSnapshot state) {
    _activeItems = state.items;
    _activeQuery = state.query;
    _activeStatus = state.status;
  }

  bool _sameIdentity(_ResultsSnapshot state) =>
      state.query == _activeQuery && state.status == _activeStatus;

  @override
  Widget build(BuildContext context) => SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.columns,
      childAspectRatio: widget.columns == 1 ? 2.8 : 2.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        if (index >= _activeItems.length) {
          if (widget.paginationError != null) {
            return _PaginationError(
              message: widget.paginationError!,
              onRetry: widget.onRetry,
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        if (!_isExiting &&
            !widget.loadingMore &&
            widget.paginationError == null &&
            index == _activeItems.length - 1) {
          widget.onLoadMore();
        }
        final character = _activeItems[index];
        return _AnimatedResultSlot(
          key: ValueKey('character-result-slot-$index'),
          index: index,
          identity:
              '${_activeQuery.trim().toLowerCase()}-${_activeStatus?.name ?? 'all'}',
          character: character,
          isExiting: _isExiting,
          onOpen: () => widget.onOpen(character),
        );
      },
      childCount:
          _activeItems.length +
          (!_isExiting && (widget.loadingMore || widget.paginationError != null)
              ? 1
              : 0),
    ),
  );
}

class _ResultsSnapshot {
  const _ResultsSnapshot({
    required this.items,
    required this.query,
    required this.status,
  });

  final List<Character> items;
  final String query;
  final CharacterStatus? status;
}

class _PaginationError extends StatelessWidget {
  const _PaginationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}

class _AnimatedResultSlot extends StatelessWidget {
  const _AnimatedResultSlot({
    super.key,
    required this.index,
    required this.identity,
    required this.character,
    required this.isExiting,
    required this.onOpen,
  });

  final int index;
  final String identity;
  final Character character;
  final bool isExiting;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    // The first eight cards enter in a deliberately noticeable cadence while
    // keeping the leading card under half a second.
    final staggerStart = index.clamp(0, 7) * 0.08;
    final cardKey = ValueKey(
      'character-result-entry-$identity-${character.id}',
    );
    final card = KeyedSubtree(
      key: cardKey,
      child: CharacterCard(character: character, onOpen: onOpen),
    );
    if (isExiting) {
      return _ResultCardExit(
        key: ValueKey('character-result-exit-$identity-${character.id}'),
        animationsDisabled: animationsDisabled,
        child: card,
      );
    }
    return _ResultCardEntry(
      key: ValueKey(
        'character-result-entry-animation-$identity-${character.id}',
      ),
      staggerStart: staggerStart,
      animationsDisabled: animationsDisabled,
      child: card,
    );
  }
}

class _ResultCardEntry extends StatelessWidget {
  const _ResultCardEntry({
    super.key,
    required this.staggerStart,
    required this.animationsDisabled,
    required this.child,
  });

  final double staggerStart;
  final bool animationsDisabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: animationsDisabled
          ? Duration.zero
          : const Duration(milliseconds: 480),
      curve: animationsDisabled
          ? Curves.linear
          : Interval(staggerStart, 1, curve: Curves.easeOutQuart),
      tween: Tween(begin: 0, end: 1),
      child: child,
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, (1 - progress) * 36),
            child: Transform.scale(scale: 0.9 + (progress * 0.1), child: child),
          ),
        );
      },
    );
  }
}

class _ResultCardExit extends StatelessWidget {
  const _ResultCardExit({
    super.key,
    required this.animationsDisabled,
    required this.child,
  });

  final bool animationsDisabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    duration: animationsDisabled
        ? Duration.zero
        : const Duration(milliseconds: 380),
    curve: Curves.easeInQuad,
    tween: Tween(begin: 1, end: 0),
    child: child,
    builder: (context, progress, child) => Opacity(
      opacity: progress,
      alwaysIncludeSemantics: true,
      child: Transform.translate(
        offset: Offset(0, (1 - progress) * 36),
        child: Transform.scale(scale: 0.9 + (progress * 0.1), child: child),
      ),
    ),
  );
}
