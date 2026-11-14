enum AssistantMessageRole { user, assistant }

/// Local chat event shape, ready for timestamped and asynchronous responses.
class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.text,
    required this.createdAt,
    this.isLoading = false,
  });

  final AssistantMessageRole role;
  final String text;
  final DateTime createdAt;
  final bool isLoading;
}
